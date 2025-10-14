import { Router } from 'express';
import { ScheduleControllerNew } from '../controllers/scheduleControllerNew';
import { Container } from '../infrastructure/container/Container';
import { authenticateToken, requireAdmin } from '@/middleware/auth';
import { adminLimiter } from '@/middleware/rateLimit';

const router = Router();

// Récupérer le controller depuis le container DI
let scheduleController;
try {
  scheduleController = Container.getInstance().getScheduleController();
  console.log('🔍 ScheduleController in route file:', !!scheduleController);
  console.log('🔍 ScheduleController type:', typeof scheduleController);
  console.log('🔍 ScheduleController methods:', scheduleController ? Object.getOwnPropertyNames(Object.getPrototypeOf(scheduleController)) : 'N/A');
} catch (error) {
  console.error('❌ Error getting ScheduleController:', error);
  scheduleController = null;
}

/**
 * @route GET /api/admin/schedule
 * @description Get restaurant schedule configuration
 * @access Admin only
 */
router.get('/', adminLimiter, authenticateToken, requireAdmin, async (req, res) => {
  try {
    console.log('🔍 Schedule GET route called');
    
    // Récupérer le restaurantId depuis la base de données
    const { PrismaClient } = await import('@prisma/client');
    const prisma = new PrismaClient();
    const restaurant = await prisma.restaurant.findFirst();
    const restaurantId = restaurant?.id;
    
    if (!restaurantId) {
      res.status(404).json({
        success: false,
        message: 'No restaurant found',
      });
      return;
    }

    // Récupérer la configuration des créneaux avec les daySchedules et timeSlots
    console.log('🔍 Querying scheduleConfig for restaurantId:', restaurantId);
    
    // D'abord, vérifions s'il y a des daySchedules dans la base
    const daySchedulesCount = await prisma.daySchedule.count();
    console.log('🔍 Total daySchedules in database:', daySchedulesCount);
    
    // Vérifions les daySchedules pour ce restaurant spécifiquement
    const directDaySchedules = await prisma.daySchedule.findMany({
      where: {
        scheduleConfig: {
          restaurantId: restaurantId
        }
      },
      include: {
        timeSlots: true
      }
    });
    console.log('🔍 Direct daySchedules query for restaurant:', directDaySchedules.length);
    console.log('🔍 Direct daySchedules data:', directDaySchedules.map(d => ({
      day: d.dayOfWeek,
      isOpen: d.isOpen,
      slots: d.timeSlots.length
    })));
    
    const scheduleConfig = await prisma.scheduleConfig.findFirst({
      where: { restaurantId },
      include: {
        daySchedules: {
          include: {
            timeSlots: true
          }
        }
      }
    });

    console.log('🔍 Prisma query result:', {
      found: !!scheduleConfig,
      id: scheduleConfig?.id,
      daySchedulesCount: scheduleConfig?.daySchedules?.length || 0,
      daySchedules: scheduleConfig?.daySchedules?.map(d => ({
        day: d.dayOfWeek,
        isOpen: d.isOpen,
        slots: d.timeSlots?.length || 0
      }))
    });

    if (!scheduleConfig) {
      res.status(404).json({
        success: false,
        message: 'No schedule configuration found',
      });
      return;
    }

    console.log('✅ Schedule config retrieved:', scheduleConfig.id);
    console.log('🔍 daySchedules count:', scheduleConfig.daySchedules?.length || 0);
    console.log('🔍 daySchedules:', scheduleConfig.daySchedules?.map(d => ({ day: d.dayOfWeek, isOpen: d.isOpen, slots: d.timeSlots?.length || 0 })));

    res.json({
      success: true,
      data: scheduleConfig
    });

  } catch (error) {
    console.error('❌ Error getting schedule config:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get schedule configuration',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * @route POST /api/admin/schedule
 * @description Create or update restaurant schedule configuration
 * @access Admin only
 */
router.post('/', adminLimiter, authenticateToken, requireAdmin, async (req, res) => {
  try {
    console.log('🔍 Schedule POST route called');
    console.log('🔍 Request body:', req.body);
    
    const {
      slotDurationMinutes,
      bufferTimeMinutes,
      maxAdvanceBookingDays,
      minAdvanceBookingHours,
      allowSameDayBooking,
      allowWeekendBooking,
      defaultCapacityPerSlot,
      daySchedules
    } = req.body;

    // Récupérer le restaurantId depuis la base de données
    const { PrismaClient } = await import('@prisma/client');
    const prisma = new PrismaClient();
    const restaurant = await prisma.restaurant.findFirst();
    const restaurantId = restaurant?.id;
    
    if (!restaurantId) {
      res.status(404).json({
        success: false,
        message: 'No restaurant found',
      });
      return;
    }

    // Mettre à jour ou créer la configuration des créneaux
    const scheduleConfig = await prisma.scheduleConfig.upsert({
      where: { restaurantId },
      update: {
        slotDurationMinutes,
        bufferTimeMinutes,
        maxAdvanceBookingDays,
        minAdvanceBookingHours,
        allowSameDayBooking,
        allowWeekendBooking,
        defaultCapacityPerSlot,
      },
      create: {
        restaurantId,
        slotDurationMinutes,
        bufferTimeMinutes,
        maxAdvanceBookingDays,
        minAdvanceBookingHours,
        allowSameDayBooking,
        allowWeekendBooking,
        defaultCapacityPerSlot,
      },
    });

    // Gérer les daySchedules si fournis
    if (daySchedules && Array.isArray(daySchedules)) {
      console.log('🔍 Processing daySchedules:', daySchedules.length);
      
      // Supprimer les anciens daySchedules
      await prisma.daySchedule.deleteMany({
        where: { scheduleConfigId: scheduleConfig.id }
      });

      // Créer les nouveaux daySchedules
      for (const daySchedule of daySchedules) {
        const createdDaySchedule = await prisma.daySchedule.create({
          data: {
            scheduleConfigId: scheduleConfig.id,
            dayOfWeek: daySchedule.dayOfWeek,
            isOpen: daySchedule.isOpen || false,
            openingTime: daySchedule.openingTime || '09:00',
            closingTime: daySchedule.closingTime || '22:00',
            notes: daySchedule.notes || null,
          }
        });

        // Gérer les timeSlots si fournis
        if (daySchedule.timeSlots && Array.isArray(daySchedule.timeSlots)) {
          console.log(`🔍 Processing timeSlots for ${daySchedule.dayOfWeek}:`, daySchedule.timeSlots.length);
          
          for (const timeSlot of daySchedule.timeSlots) {
            await prisma.timeSlot.create({
              data: {
                dayScheduleId: createdDaySchedule.id,
                time: timeSlot.time,
                isAvailable: timeSlot.isAvailable || true,
                capacity: timeSlot.capacity || defaultCapacityPerSlot,
                isRecommended: timeSlot.isRecommended || false,
              }
            });
          }
        }
      }
    }

    console.log('✅ Schedule config updated:', scheduleConfig.id);

    res.json({
      success: true,
      message: 'Schedule configuration updated successfully',
      data: scheduleConfig
    });

  } catch (error) {
    console.error('❌ Error updating schedule config:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update schedule configuration',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * @route DELETE /api/admin/schedule
 * @description Delete schedule configuration
 * @access Admin only
 */
router.delete('/', adminLimiter, authenticateToken, requireAdmin, (req, res) => {
  if (scheduleController && typeof scheduleController.deleteScheduleConfig === 'function') {
    scheduleController.deleteScheduleConfig(req, res);
  } else {
    res.status(500).json({
      success: false,
      message: 'ScheduleController not available'
    });
  }
});

/**
 * @route GET /api/admin/schedule/availability
 * @description Get available time slots for a specific date
 * @access Admin only
 */
router.get('/availability', adminLimiter, authenticateToken, requireAdmin, (req, res) => {
  if (scheduleController && typeof scheduleController.getAvailableSlots === 'function') {
    scheduleController.getAvailableSlots(req, res);
  } else {
    res.status(500).json({
      success: false,
      message: 'ScheduleController not available'
    });
  }
});

/**
 * @route POST /api/admin/schedule/validate
 * @description Validate if a reservation is possible
 * @access Admin only
 */
router.post('/validate', adminLimiter, authenticateToken, requireAdmin, (req, res) => {
  if (scheduleController && typeof scheduleController.validateReservation === 'function') {
    scheduleController.validateReservation(req, res);
  } else {
    res.status(500).json({
      success: false,
      message: 'ScheduleController not available'
    });
  }
});

export default router;
