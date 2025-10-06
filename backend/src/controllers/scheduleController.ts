import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import logger from '@/utils/logger';

const prisma = new PrismaClient();

/**
 * @route GET /api/admin/schedule
 * @description Get restaurant schedule configuration
 * @access Admin only
 */
export const getScheduleConfig = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    // Pour l'instant, on utilise le premier restaurant
    // TODO: Récupérer le restaurantId depuis l'utilisateur ou les paramètres
    const restaurant = await prisma.restaurant.findFirst({
      where: { isActive: true },
    });

    if (!restaurant) {
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

    const scheduleConfig = await prisma.scheduleConfig.findUnique({
      where: { restaurantId: restaurant.id },
      include: {
        daySchedules: {
          include: {
            timeSlots: {
              orderBy: { time: 'asc' },
            },
          },
          orderBy: { dayOfWeek: 'asc' },
        },
      },
    });

    if (!scheduleConfig) {
      // Créer une configuration par défaut si elle n'existe pas
      const defaultConfig = await createDefaultScheduleConfig(restaurant.id);
      res.status(200).json({
        success: true,
        data: defaultConfig,
      });
      return;
    }

    logger.info('Schedule config retrieved', {
      userId: user.id,
      restaurantId: restaurant.id,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: scheduleConfig,
    });
  } catch (error) {
    logger.error('Failed to get schedule config', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to get schedule configuration',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route POST /api/admin/schedule
 * @description Create or update restaurant schedule configuration
 * @access Admin only
 */
export const createOrUpdateScheduleConfig = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const {
      slotDurationMinutes,
      bufferTimeMinutes,
      maxAdvanceBookingDays,
      minAdvanceBookingHours,
      allowSameDayBooking,
      allowWeekendBooking,
      daySchedules,
    } = req.body;

    // Validation des données
    if (!daySchedules || !Array.isArray(daySchedules)) {
      res.status(400).json({
        success: false,
        message: 'Day schedules are required',
      });
      return;
    }

    // Récupérer le restaurant
    const restaurant = await prisma.restaurant.findFirst({
      where: { isActive: true },
    });

    if (!restaurant) {
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

    // Vérifier si une configuration existe déjà
    const existingConfig = await prisma.scheduleConfig.findUnique({
      where: { restaurantId: restaurant.id },
    });

    let scheduleConfig;

    if (existingConfig) {
      // Mettre à jour la configuration existante
      scheduleConfig = await prisma.scheduleConfig.update({
        where: { id: existingConfig.id },
        data: {
          slotDurationMinutes: slotDurationMinutes || 30,
          bufferTimeMinutes: bufferTimeMinutes || 15,
          maxAdvanceBookingDays: maxAdvanceBookingDays || 30,
          minAdvanceBookingHours: minAdvanceBookingHours || 2,
          allowSameDayBooking: allowSameDayBooking !== undefined ? allowSameDayBooking : true,
          allowWeekendBooking: allowWeekendBooking !== undefined ? allowWeekendBooking : true,
        },
        include: {
          daySchedules: {
            include: {
              timeSlots: true,
            },
          },
        },
      });

      // Supprimer les anciens horaires et créneaux
      await prisma.timeSlot.deleteMany({
        where: {
          daySchedule: {
            scheduleConfigId: scheduleConfig.id,
          },
        },
      });

      await prisma.daySchedule.deleteMany({
        where: {
          scheduleConfigId: scheduleConfig.id,
        },
      });
    } else {
      // Créer une nouvelle configuration
      scheduleConfig = await prisma.scheduleConfig.create({
        data: {
          restaurantId: restaurant.id,
          slotDurationMinutes: slotDurationMinutes || 30,
          bufferTimeMinutes: bufferTimeMinutes || 15,
          maxAdvanceBookingDays: maxAdvanceBookingDays || 30,
          minAdvanceBookingHours: minAdvanceBookingHours || 2,
          allowSameDayBooking: allowSameDayBooking !== undefined ? allowSameDayBooking : true,
          allowWeekendBooking: allowWeekendBooking !== undefined ? allowWeekendBooking : true,
        },
        include: {
          daySchedules: {
            include: {
              timeSlots: true,
            },
          },
        },
      });
    }

    // Créer les nouveaux horaires et créneaux
    for (const daySchedule of daySchedules) {
      const createdDaySchedule = await prisma.daySchedule.create({
        data: {
          scheduleConfigId: scheduleConfig.id,
          dayOfWeek: daySchedule.dayOfWeek,
          isOpen: daySchedule.isOpen,
          notes: daySchedule.notes || null,
        },
      });

      // Créer les créneaux pour ce jour
      if (daySchedule.timeSlots && Array.isArray(daySchedule.timeSlots)) {
        for (const timeSlot of daySchedule.timeSlots) {
          await prisma.timeSlot.create({
            data: {
              dayScheduleId: createdDaySchedule.id,
              time: timeSlot.time,
              isAvailable: timeSlot.isAvailable,
              capacity: timeSlot.capacity || 20,
              isRecommended: timeSlot.isRecommended || false,
            },
          });
        }
      }
    }

    // Récupérer la configuration complète
    const updatedConfig = await prisma.scheduleConfig.findUnique({
      where: { id: scheduleConfig.id },
      include: {
        daySchedules: {
          include: {
            timeSlots: {
              orderBy: { time: 'asc' },
            },
          },
          orderBy: { dayOfWeek: 'asc' },
        },
      },
    });

    logger.info('Schedule config updated', {
      userId: user.id,
      restaurantId: restaurant.id,
      configId: scheduleConfig.id,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: updatedConfig,
      message: existingConfig ? 'Schedule configuration updated' : 'Schedule configuration created',
    });
  } catch (error) {
    logger.error('Failed to create/update schedule config', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to save schedule configuration',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route DELETE /api/admin/schedule
 * @description Delete schedule configuration
 * @access Admin only
 */
export const deleteScheduleConfig = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const restaurant = await prisma.restaurant.findFirst({
      where: { isActive: true },
    });

    if (!restaurant) {
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

    const scheduleConfig = await prisma.scheduleConfig.findUnique({
      where: { restaurantId: restaurant.id },
    });

    if (!scheduleConfig) {
      res.status(404).json({
        success: false,
        message: 'Schedule configuration not found',
      });
      return;
    }

    // Supprimer la configuration (les relations seront supprimées en cascade)
    await prisma.scheduleConfig.delete({
      where: { id: scheduleConfig.id },
    });

    logger.info('Schedule config deleted', {
      userId: user.id,
      restaurantId: restaurant.id,
      configId: scheduleConfig.id,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Schedule configuration deleted successfully',
    });
  } catch (error) {
    logger.error('Failed to delete schedule config', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to delete schedule configuration',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * Fonction utilitaire pour créer une configuration par défaut
 */
async function createDefaultScheduleConfig(restaurantId: string) {
  const scheduleConfig = await prisma.scheduleConfig.create({
    data: {
      restaurantId,
      slotDurationMinutes: 30,
      bufferTimeMinutes: 15,
      maxAdvanceBookingDays: 30,
      minAdvanceBookingHours: 2,
      allowSameDayBooking: true,
      allowWeekendBooking: true,
    },
  });

  const daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  
  for (const dayOfWeek of daysOfWeek) {
    const isOpen = dayOfWeek !== 'sunday';
    const daySchedule = await prisma.daySchedule.create({
      data: {
        scheduleConfigId: scheduleConfig.id,
        dayOfWeek,
        isOpen,
        notes: dayOfWeek === 'sunday' ? 'Fermé le dimanche' : null,
      },
    });

    if (isOpen) {
      // Créneaux du déjeuner (12h-14h)
      for (let hour = 12; hour < 14; hour++) {
        for (let minute = 0; minute < 60; minute += 30) {
          await prisma.timeSlot.create({
            data: {
              dayScheduleId: daySchedule.id,
              time: `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`,
              isAvailable: true,
              capacity: 20,
              isRecommended: hour === 12 && minute === 30,
            },
          });
        }
      }

      // Créneaux du dîner (19h-22h)
      for (let hour = 19; hour < 22; hour++) {
        for (let minute = 0; minute < 60; minute += 30) {
          await prisma.timeSlot.create({
            data: {
              dayScheduleId: daySchedule.id,
              time: `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`,
              isAvailable: true,
              capacity: 20,
              isRecommended: hour === 19 && minute === 30,
            },
          });
        }
      }
    }
  }

  return await prisma.scheduleConfig.findUnique({
    where: { id: scheduleConfig.id },
    include: {
      daySchedules: {
        include: {
          timeSlots: {
            orderBy: { time: 'asc' },
          },
        },
        orderBy: { dayOfWeek: 'asc' },
      },
    },
  });
}
