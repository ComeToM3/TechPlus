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

    // Extraire les paramètres, en priorisant les paramètres directs sur timeSlotSettings
    const {
      slotDurationMinutes: directSlotDuration,
      bufferTimeMinutes: directBufferTime,
      maxAdvanceBookingDays: directMaxAdvance,
      minAdvanceBookingHours: directMinAdvance,
      allowSameDayBooking: directSameDay,
      allowWeekendBooking: directWeekend,
      defaultCapacityPerSlot: directCapacity,
      timeSlotSettings,
      daySchedules,
      id,
      restaurantId: frontendRestaurantId,
    } = req.body;

    // Utiliser les paramètres directs en priorité, sinon ceux de timeSlotSettings, sinon les valeurs par défaut
    const slotDurationMinutes = directSlotDuration ?? timeSlotSettings?.slotDurationMinutes ?? 30;
    const bufferTimeMinutes = directBufferTime ?? timeSlotSettings?.bufferTimeMinutes ?? 15;
    const maxAdvanceBookingDays = directMaxAdvance ?? timeSlotSettings?.maxAdvanceBookingDays ?? 30;
    const minAdvanceBookingHours = directMinAdvance ?? timeSlotSettings?.minAdvanceBookingHours ?? 2;
    const allowSameDayBooking = directSameDay ?? timeSlotSettings?.allowSameDayBooking ?? true;
    const allowWeekendBooking = directWeekend ?? timeSlotSettings?.allowWeekendBooking ?? true;
    const defaultCapacityPerSlot = directCapacity ?? timeSlotSettings?.defaultCapacityPerSlot ?? 20;


    // Validation des données
    if (!daySchedules || !Array.isArray(daySchedules)) {
      res.status(400).json({
        success: false,
        message: 'Day schedules are required',
      });
      return;
    }

    // Utiliser directement les paramètres reçus (plus simple)
    const finalSlotDuration = slotDurationMinutes;
    const finalBufferTime = bufferTimeMinutes;
    const finalMaxAdvance = maxAdvanceBookingDays;
    const finalMinAdvance = minAdvanceBookingHours;
    const finalSameDay = allowSameDayBooking;
    const finalWeekend = allowWeekendBooking;
    const finalCapacity = defaultCapacityPerSlot;

    console.log('🔧 [ScheduleController] createOrUpdateScheduleConfig - Paramètres finaux:', {
      finalSlotDuration,
      finalBufferTime,
      finalMaxAdvance,
      finalMinAdvance,
      finalSameDay,
      finalWeekend,
      finalCapacity
    });

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
      console.log('🔧 [ScheduleController] Configuration existante trouvée, mise à jour en cours...');
      // Utiliser une transaction pour garantir la cohérence des données
      scheduleConfig = await prisma.$transaction(async (tx) => {
        console.log('🔧 [ScheduleController] Début de la transaction');
        // Mettre à jour la configuration existante
        const updatedConfig = await tx.scheduleConfig.update({
          where: { id: existingConfig.id },
          data: {
            slotDurationMinutes: finalSlotDuration,
            bufferTimeMinutes: finalBufferTime,
            maxAdvanceBookingDays: finalMaxAdvance,
            minAdvanceBookingHours: finalMinAdvance,
            allowSameDayBooking: finalSameDay,
            allowWeekendBooking: finalWeekend,
            defaultCapacityPerSlot: finalCapacity,
          },
        });
        console.log('🔧 [ScheduleController] Configuration mise à jour:', updatedConfig.id);

        // Supprimer les anciens horaires et créneaux
        await tx.timeSlot.deleteMany({
          where: {
            daySchedule: {
              scheduleConfigId: updatedConfig.id,
            },
          },
        });

        await tx.daySchedule.deleteMany({
          where: {
            scheduleConfigId: updatedConfig.id,
          },
        });

        return updatedConfig;
      });
    } else {
      // Créer une nouvelle configuration
      scheduleConfig = await prisma.scheduleConfig.create({
        data: {
          restaurantId: restaurant.id,
          slotDurationMinutes: finalSlotDuration,
          bufferTimeMinutes: finalBufferTime,
          maxAdvanceBookingDays: finalMaxAdvance,
          minAdvanceBookingHours: finalMinAdvance,
          allowSameDayBooking: finalSameDay,
          allowWeekendBooking: finalWeekend,
          defaultCapacityPerSlot: finalCapacity,
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
          openingTime: daySchedule.openingTime || null,
          closingTime: daySchedule.closingTime || null,
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
        openingTime: isOpen ? '09:00' : null,
        closingTime: isOpen ? '22:00' : null,
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

/**
 * @route GET /api/admin/schedule/availability
 * @description Get available time slots for a specific date
 * @access Admin only
 */
export const getAvailableSlots = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { date, partySize = 1 } = req.query;

    if (!date) {
      res.status(400).json({
        success: false,
        message: 'Date parameter is required',
      });
      return;
    }

    const targetDate = new Date(date as string);
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
              where: { isAvailable: true },
              orderBy: { time: 'asc' },
            },
          },
        },
      },
    });

    if (!scheduleConfig) {
      res.status(404).json({
        success: false,
        message: 'Schedule configuration not found',
      });
      return;
    }

    const dayOfWeek = getDayOfWeek(targetDate);
    const daySchedule = scheduleConfig.daySchedules.find(d => d.dayOfWeek === dayOfWeek);

    if (!daySchedule || !daySchedule.isOpen) {
      res.status(200).json({
        success: true,
        data: {
          date: targetDate,
          partySize: parseInt(partySize as string),
          slots: [],
          totalSlots: 0,
        },
      });
      return;
    }

    // Si des créneaux spécifiques existent, les utiliser
    if (daySchedule.timeSlots.length > 0) {
      const availableSlots = daySchedule.timeSlots.filter(slot => 
        slot.capacity >= parseInt(partySize as string)
      );

      res.status(200).json({
        success: true,
        data: {
          date: targetDate,
          partySize: parseInt(partySize as string),
          slots: availableSlots,
          totalSlots: availableSlots.length,
        },
      });
      return;
    }

    // Sinon, générer des créneaux automatiquement
    const generatedSlots = generateTimeSlots(
      daySchedule.openingTime || '09:00',
      daySchedule.closingTime || '22:00',
      scheduleConfig.slotDurationMinutes,
      scheduleConfig.defaultCapacityPerSlot || 20
    );

    const availableSlots = generatedSlots.filter(slot => 
      slot.capacity >= parseInt(partySize as string)
    );

    logger.info('Available slots retrieved', {
      userId: user.id,
      restaurantId: restaurant.id,
      date: targetDate,
      partySize,
      slotsCount: availableSlots.length,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: {
        date: targetDate,
        partySize: parseInt(partySize as string),
        slots: availableSlots,
        totalSlots: availableSlots.length,
      },
    });
  } catch (error) {
    logger.error('Failed to get available slots', {
      error: error instanceof Error ? error.message : 'Unknown error',
      ip: req.ip,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to retrieve available slots',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route POST /api/admin/schedule/validate
 * @description Validate if a reservation is possible
 * @access Admin only
 */
export const validateReservation = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { date, time, partySize = 1 } = req.body;

    if (!date || !time) {
      res.status(400).json({
        success: false,
        message: 'Date and time parameters are required',
      });
      return;
    }

    const targetDate = new Date(date);
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
              where: { isAvailable: true },
            },
          },
        },
      },
    });

    if (!scheduleConfig) {
      res.status(404).json({
        success: false,
        message: 'Schedule configuration not found',
      });
      return;
    }

    const dayOfWeek = getDayOfWeek(targetDate);
    const daySchedule = scheduleConfig.daySchedules.find(d => d.dayOfWeek === dayOfWeek);

    if (!daySchedule || !daySchedule.isOpen) {
      res.status(200).json({
        success: true,
        data: {
          canReserve: false,
          date: targetDate,
          time,
          partySize: parseInt(partySize),
          message: 'Restaurant is closed on this day',
        },
      });
      return;
    }

    // Vérifier les heures d'ouverture
    const openTime = daySchedule.openingTime || '09:00';
    const closeTime = daySchedule.closingTime || '22:00';
    
    if (time < openTime || time >= closeTime) {
      res.status(200).json({
        success: true,
        data: {
          canReserve: false,
          date: targetDate,
          time,
          partySize: parseInt(partySize),
          message: 'Time is outside opening hours',
        },
      });
      return;
    }

    // Vérifier les règles de réservation
    const now = new Date();
    const reservationDateTime = new Date(targetDate);
    const [hours, minutes] = time.split(':').map(Number);
    reservationDateTime.setHours(hours, minutes, 0, 0);

    // Vérifier le délai minimum
    const minAdvanceHours = scheduleConfig.minAdvanceBookingHours;
    const minDateTime = new Date(now.getTime() + minAdvanceHours * 60 * 60 * 1000);
    
    if (reservationDateTime < minDateTime) {
      res.status(200).json({
        success: true,
        data: {
          canReserve: false,
          date: targetDate,
          time,
          partySize: parseInt(partySize),
          message: `Reservation must be made at least ${minAdvanceHours} hours in advance`,
        },
      });
      return;
    }

    // Vérifier le délai maximum
    const maxAdvanceDays = scheduleConfig.maxAdvanceBookingDays;
    const maxDateTime = new Date(now.getTime() + maxAdvanceDays * 24 * 60 * 60 * 1000);
    
    if (reservationDateTime > maxDateTime) {
      res.status(200).json({
        success: true,
        data: {
          canReserve: false,
          date: targetDate,
          time,
          partySize: parseInt(partySize),
          message: `Reservation cannot be made more than ${maxAdvanceDays} days in advance`,
        },
      });
      return;
    }

    // Vérifier les règles spéciales
    if (!scheduleConfig.allowSameDayBooking && isSameDay(targetDate, now)) {
      res.status(200).json({
        success: true,
        data: {
          canReserve: false,
          date: targetDate,
          time,
          partySize: parseInt(partySize),
          message: 'Same day booking is not allowed',
        },
      });
      return;
    }

    if (!scheduleConfig.allowWeekendBooking && isWeekend(targetDate)) {
      res.status(200).json({
        success: true,
        data: {
          canReserve: false,
          date: targetDate,
          time,
          partySize: parseInt(partySize),
          message: 'Weekend booking is not allowed',
        },
      });
      return;
    }

    logger.info('Reservation validation completed', {
      userId: user.id,
      restaurantId: restaurant.id,
      date: targetDate,
      time,
      partySize,
      canReserve: true,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: {
        canReserve: true,
        date: targetDate,
        time,
        partySize: parseInt(partySize),
        message: 'Reservation is possible',
      },
    });
  } catch (error) {
    logger.error('Failed to validate reservation', {
      error: error instanceof Error ? error.message : 'Unknown error',
      ip: req.ip,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to validate reservation',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

// ==================== FONCTIONS UTILITAIRES ====================

/**
 * Génère des créneaux horaires automatiquement
 */
function generateTimeSlots(openTime: string, closeTime: string, slotDuration: number, capacity: number) {
  const slots: any[] = [];
  const openParts = openTime.split(':');
  const closeParts = closeTime.split(':');
  
  if (openParts.length !== 2 || closeParts.length !== 2) {
    return slots;
  }
  
  const openHour = parseInt(openParts[0] || '0');
  const openMinute = parseInt(openParts[1] || '0');
  const closeHour = parseInt(closeParts[0] || '0');
  const closeMinute = parseInt(closeParts[1] || '0');
  
  // Vérification des valeurs
  if (isNaN(openHour) || isNaN(openMinute) || isNaN(closeHour) || isNaN(closeMinute)) {
    return slots;
  }
  
  const openMinutes = openHour * 60 + openMinute;
  const closeMinutes = closeHour * 60 + closeMinute;
  
  for (let minutes = openMinutes; minutes < closeMinutes; minutes += slotDuration) {
    const hour = Math.floor(minutes / 60);
    const minute = minutes % 60;
    const time = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
    
    slots.push({
      time,
      isAvailable: true,
      capacity,
      isRecommended: isRecommendedTime(time),
    });
  }
  
  return slots;
}

/**
 * Détermine si une heure est recommandée
 */
function isRecommendedTime(time: string): boolean {
  const timeParts = time.split(':');
  if (timeParts.length !== 2) return false;
  
  const hour = parseInt(timeParts[0] || '0');
  if (isNaN(hour)) return false;
  
  return (hour >= 12 && hour <= 13) || (hour >= 19 && hour <= 20);
}

/**
 * Obtient le jour de la semaine
 */
function getDayOfWeek(date: Date): string {
  const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  return days[date.getDay()] || 'sunday';
}

/**
 * Vérifie si deux dates sont le même jour
 */
function isSameDay(date1: Date, date2: Date): boolean {
  return date1.toDateString() === date2.toDateString();
}

/**
 * Vérifie si une date est un weekend
 */
function isWeekend(date: Date): boolean {
  const day = date.getDay();
  return day === 0 || day === 6; // Dimanche ou Samedi
}
