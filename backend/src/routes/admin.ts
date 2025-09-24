import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticateToken } from '@/middleware/auth';
import { adminLimiter } from '@/middleware/rateLimit';
import logger from '@/utils/logger';

const router = Router();
const prisma = new PrismaClient();

/**
 * @route GET /api/admin/dashboard/metrics
 * @description Get admin dashboard metrics
 * @access Admin only
 */
router.get('/dashboard/metrics', adminLimiter, authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    // Vérifier que l'utilisateur est admin
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    // Récupérer les métriques de base de données
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Métriques des réservations
    const [
      totalReservations,
      todayReservations,
      pendingReservations,
      confirmedReservations,
      cancelledReservations,
      totalRevenue,
      todayRevenue,
      averagePartySize,
      topTimeSlots,
      tableOccupancy
    ] = await Promise.all([
      // Total des réservations
      prisma.reservation.count(),
      
      // Réservations d'aujourd'hui
      prisma.reservation.count({
        where: {
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
      }),
      
      // Réservations en attente
      prisma.reservation.count({
        where: { status: 'PENDING' },
      }),
      
      // Réservations confirmées
      prisma.reservation.count({
        where: { status: 'CONFIRMED' },
      }),
      
      // Réservations annulées
      prisma.reservation.count({
        where: { status: 'CANCELLED' },
      }),
      
      // Revenus totaux
      prisma.reservation.aggregate({
        where: {
          status: 'CONFIRMED',
          paymentStatus: 'COMPLETED',
        },
        _sum: {
          estimatedAmount: true,
        },
      }),
      
      // Revenus d'aujourd'hui
      prisma.reservation.aggregate({
        where: {
          status: 'CONFIRMED',
          paymentStatus: 'COMPLETED',
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
        _sum: {
          estimatedAmount: true,
        },
      }),
      
      // Taille moyenne des groupes
      prisma.reservation.aggregate({
        where: {
          status: 'CONFIRMED',
        },
        _avg: {
          partySize: true,
        },
      }),
      
      // Créneaux horaires populaires
      prisma.reservation.groupBy({
        by: ['time'],
        where: {
          status: 'CONFIRMED',
          date: {
            gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 derniers jours
          },
        },
        _count: {
          id: true,
        },
        orderBy: {
          _count: {
            id: 'desc',
          },
        },
        take: 5,
      }),
      
      // Occupation des tables (simulation - à adapter selon votre modèle)
      prisma.reservation.count({
        where: {
          status: 'CONFIRMED',
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
      }),
    ]);

    // Calculer le taux d'occupation (simulation)
    const totalTables = 20; // Nombre total de tables (à configurer)
    const occupiedTables = Math.min(tableOccupancy, totalTables);
    const occupancyRate = totalTables > 0 ? (occupiedTables / totalTables) * 100 : 0;

    // Métriques des 7 derniers jours
    const last7Days = new Date();
    last7Days.setDate(last7Days.getDate() - 7);
    
    const [
      last7DaysReservations,
      last7DaysRevenue,
      weeklyTrends
    ] = await Promise.all([
      prisma.reservation.count({
        where: {
          date: {
            gte: last7Days,
          },
        },
      }),
      
      prisma.reservation.aggregate({
        where: {
          status: 'CONFIRMED',
          paymentStatus: 'COMPLETED',
          date: {
            gte: last7Days,
          },
        },
        _sum: {
          estimatedAmount: true,
        },
      }),
      
      // Tendances par jour (7 derniers jours)
      prisma.reservation.groupBy({
        by: ['date'],
        where: {
          date: {
            gte: last7Days,
          },
        },
        _count: {
          id: true,
        },
        _sum: {
          estimatedAmount: true,
        },
        orderBy: {
          date: 'asc',
        },
      }),
    ]);

    // Calculer les tendances
    const currentWeekReservations = last7DaysReservations;
    const previousWeekStart = new Date(last7Days);
    previousWeekStart.setDate(previousWeekStart.getDate() - 7);
    const previousWeekEnd = new Date(last7Days);
    
    const previousWeekReservations = await prisma.reservation.count({
      where: {
        date: {
          gte: previousWeekStart,
          lt: previousWeekEnd,
        },
      },
    });

    const reservationGrowth = previousWeekReservations > 0 
      ? ((currentWeekReservations - previousWeekReservations) / previousWeekReservations) * 100 
      : 0;

    const metrics = {
      overview: {
        totalReservations,
        todayReservations,
        pendingReservations,
        confirmedReservations,
        cancelledReservations,
        totalRevenue: totalRevenue._sum.estimatedAmount || 0,
        todayRevenue: todayRevenue._sum.estimatedAmount || 0,
        averagePartySize: averagePartySize._avg.partySize || 0,
        occupancyRate: Math.round(occupancyRate * 100) / 100,
        occupiedTables,
        totalTables,
      },
      trends: {
        reservationGrowth: Math.round(reservationGrowth * 100) / 100,
        weeklyReservations: currentWeekReservations,
        weeklyRevenue: last7DaysRevenue._sum.estimatedAmount || 0,
        dailyTrends: weeklyTrends.map(day => ({
          date: day.date,
          reservations: day._count.id,
          revenue: day._sum.estimatedAmount || 0,
        })),
      },
      popularTimeSlots: topTimeSlots.map(slot => ({
        timeSlot: slot.time,
        count: slot._count.id,
      })),
      performance: {
        confirmationRate: totalReservations > 0 ? (confirmedReservations / totalReservations) * 100 : 0,
        cancellationRate: totalReservations > 0 ? (cancelledReservations / totalReservations) * 100 : 0,
        averageRevenuePerReservation: confirmedReservations > 0 ? Number(totalRevenue._sum.estimatedAmount || 0) / confirmedReservations : 0,
      },
      lastUpdated: new Date().toISOString(),
    };

    logger.info('Admin dashboard metrics requested', { 
      userId: user.id, 
      ip: req.ip 
    });

    res.status(200).json({
      success: true,
      data: metrics,
    });

  } catch (error) {
    logger.error('Failed to fetch admin dashboard metrics', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard metrics',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route GET /api/admin/dashboard/analytics
 * @description Get detailed analytics for admin dashboard
 * @access Admin only
 */
router.get('/dashboard/analytics', adminLimiter, authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { period = '30d', startDate, endDate } = req.query;
    
    // Calculer les dates selon la période
    let start: Date;
    let end: Date = new Date();
    
    if (startDate && endDate) {
      start = new Date(startDate as string);
      end = new Date(endDate as string);
    } else {
      start = new Date();
      switch (period) {
        case '7d':
          start.setDate(start.getDate() - 7);
          break;
        case '30d':
          start.setDate(start.getDate() - 30);
          break;
        case '90d':
          start.setDate(start.getDate() - 90);
          break;
        default:
          start.setDate(start.getDate() - 30);
      }
    }

    // Analytics détaillées
    const [
      reservationTrends,
      revenueTrends,
      customerSegments,
      timeSlotAnalysis,
      tableUtilization
    ] = await Promise.all([
      // Tendances des réservations
      prisma.reservation.groupBy({
        by: ['date'],
        where: {
          date: {
            gte: start,
            lte: end,
          },
        },
        _count: {
          id: true,
        },
        _sum: {
          estimatedAmount: true,
        },
        orderBy: {
          date: 'asc',
        },
      }),
      
      // Analyse des revenus
      prisma.reservation.aggregate({
        where: {
          status: 'CONFIRMED',
          paymentStatus: 'COMPLETED',
          date: {
            gte: start,
            lte: end,
          },
        },
        _sum: {
          estimatedAmount: true,
        },
        _avg: {
          estimatedAmount: true,
        },
        _count: {
          id: true,
        },
      }),
      
      // Segments de clients (par taille de groupe)
      prisma.reservation.groupBy({
        by: ['partySize'],
        where: {
          date: {
            gte: start,
            lte: end,
          },
        },
        _count: {
          id: true,
        },
        _sum: {
          estimatedAmount: true,
        },
        orderBy: {
          partySize: 'asc',
        },
      }),
      
      // Analyse des créneaux horaires
      prisma.reservation.groupBy({
        by: ['time'],
        where: {
          date: {
            gte: start,
            lte: end,
          },
        },
        _count: {
          id: true,
        },
        _sum: {
          estimatedAmount: true,
        },
        orderBy: {
          _count: {
            id: 'desc',
          },
        },
      }),
      
      // Utilisation des tables (simulation)
      prisma.reservation.aggregate({
        where: {
          date: {
            gte: start,
            lte: end,
          },
        },
        _count: {
          id: true,
        },
      }),
    ]);

    const analytics = {
      period: {
        start: start.toISOString(),
        end: end.toISOString(),
        days: Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)),
      },
      trends: {
        reservations: reservationTrends.map(day => ({
          date: day.date,
          count: day._count.id,
          revenue: day._sum.estimatedAmount || 0,
        })),
        revenue: {
          total: revenueTrends._sum.estimatedAmount || 0,
          average: revenueTrends._avg.estimatedAmount || 0,
          count: revenueTrends._count.id,
        },
      },
      segments: {
        customerSegments: customerSegments.map(segment => ({
          partySize: segment.partySize,
          count: segment._count.id,
          revenue: segment._sum.estimatedAmount || 0,
          percentage: 0, // À calculer
        })),
        timeSlots: timeSlotAnalysis.map(slot => ({
          timeSlot: slot.time,
          count: slot._count.id,
          revenue: slot._sum.estimatedAmount || 0,
          percentage: 0, // À calculer
        })),
      },
      utilization: {
        totalReservations: tableUtilization._count.id,
        averageDailyReservations: Math.round((tableUtilization._count.id / Math.max(1, Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)))) * 100) / 100,
      },
      generatedAt: new Date().toISOString(),
    };

    logger.info('Admin dashboard analytics requested', { 
      userId: user.id, 
      period,
      ip: req.ip 
    });

    res.status(200).json({
      success: true,
      data: analytics,
    });

  } catch (error) {
    logger.error('Failed to fetch admin dashboard analytics', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to fetch analytics',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
