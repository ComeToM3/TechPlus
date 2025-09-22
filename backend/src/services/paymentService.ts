import Stripe from 'stripe';
import { config } from '@/config/environment';
import prisma from '@/config/database';
import { PaymentStatus } from '@prisma/client';

class PaymentService {
  private stripe: Stripe | null = null;

  constructor() {
    if (config.stripe.secretKey) {
      this.stripe = new Stripe(config.stripe.secretKey, {
        apiVersion: '2025-08-27.basil',
      });
    } else {
      console.warn('Stripe secret key not configured. Payment features will be disabled.');
    }
  }

  /**
   * Créer un PaymentIntent pour une réservation
   */
  async createPaymentIntent(reservationId: string, amount: number): Promise<Stripe.PaymentIntent> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured');
    }
    const reservation = await prisma.reservation.findUnique({
      where: { id: reservationId },
      include: {
        restaurant: { select: { name: true } },
        user: { select: { email: true, name: true } },
      },
    });

    if (!reservation) {
      throw new Error('Reservation not found');
    }

    if (reservation.paymentStatus !== PaymentStatus.PENDING) {
      throw new Error('Reservation is not in pending payment status');
    }

    // Créer le PaymentIntent
    const paymentIntent = await this.stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convertir en centimes
      currency: 'eur',
      metadata: {
        reservationId,
        restaurantName: reservation.restaurant.name,
        partySize: reservation.partySize.toString(),
        date: reservation.date.toISOString(),
        time: reservation.time,
      },
      description: `Acompte réservation ${reservation.restaurant.name} - ${reservation.date.toLocaleDateString('fr-FR')} ${reservation.time}`,
    });

    // Mettre à jour la réservation avec l'ID du paiement
    await prisma.reservation.update({
      where: { id: reservationId },
      data: {
        stripePaymentId: paymentIntent.id,
      },
    });

    return paymentIntent;
  }

  /**
   * Confirmer un paiement
   */
  async confirmPayment(paymentIntentId: string): Promise<boolean> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured');
    }

    try {
      const paymentIntent = await this.stripe.paymentIntents.retrieve(paymentIntentId);

      if (paymentIntent.status === 'succeeded') {
        // Trouver la réservation par stripePaymentId
        const reservation = await prisma.reservation.findFirst({
          where: { stripePaymentId: paymentIntentId },
        });

        if (reservation) {
          // Mettre à jour le statut de la réservation
          await prisma.reservation.update({
            where: { id: reservation.id },
            data: {
              paymentStatus: PaymentStatus.COMPLETED,
            },
          });
        }

        return true;
      }

      return false;
    } catch (error) {
      console.error('Error confirming payment:', error);
      return false;
    }
  }

  /**
   * Effectuer un remboursement
   */
  async processRefund(reservationId: string, amount?: number): Promise<Stripe.Refund> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured');
    }
    const reservation = await prisma.reservation.findUnique({
      where: { id: reservationId },
    });

    if (!reservation?.stripePaymentId) {
      throw new Error('Reservation or payment not found');
    }

    const refundParams: any = {
      payment_intent: reservation.stripePaymentId,
      metadata: {
        reservationId,
        reason: 'cancellation',
      },
    };

    if (amount) {
      refundParams.amount = Math.round(amount * 100);
    }

    const refund = await this.stripe.refunds.create(refundParams);

    // Mettre à jour le statut de paiement
    const depositAmount = Number(reservation.depositAmount || 0);
    const newStatus =
      amount && amount < depositAmount ? PaymentStatus.PARTIALLY_REFUNDED : PaymentStatus.REFUNDED;

    await prisma.reservation.update({
      where: { id: reservationId },
      data: {
        paymentStatus: newStatus,
      },
    });

    return refund;
  }

  /**
   * Calculer le montant de l'acompte selon la politique
   */
  calculateDepositAmount(partySize: number, averagePricePerPerson: number = 25): number {
    if (partySize < 6) {
      return 0; // Pas d'acompte pour moins de 6 personnes
    }

    // Montant fixe de 10€ par personne pour les groupes de 6+ personnes
    return Math.min(partySize * 10, partySize * averagePricePerPerson * 0.3);
  }

  /**
   * Vérifier si un paiement est requis
   */
  isPaymentRequired(partySize: number): boolean {
    return partySize >= 6;
  }

  /**
   * Obtenir les détails d'un paiement
   */
  async getPaymentDetails(paymentIntentId: string): Promise<Stripe.PaymentIntent | null> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured');
    }

    try {
      return await this.stripe.paymentIntents.retrieve(paymentIntentId);
    } catch (error) {
      console.error('Error retrieving payment details:', error);
      return null;
    }
  }

  /**
   * Traiter un webhook Stripe
   */
  async handleWebhook(event: Stripe.Event): Promise<void> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured');
    }
    switch (event.type) {
      case 'payment_intent.succeeded':
        await this.handlePaymentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;

      case 'payment_intent.payment_failed':
        await this.handlePaymentFailed(event.data.object as Stripe.PaymentIntent);
        break;

      case 'charge.dispute.created':
        await this.handleDisputeCreated(event.data.object as Stripe.Dispute);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
  }

  /**
   * Gérer un paiement réussi
   */
  private async handlePaymentSucceeded(paymentIntent: Stripe.PaymentIntent): Promise<void> {
    const reservationId = paymentIntent.metadata.reservationId;

    if (reservationId) {
      const reservation = await prisma.reservation.findFirst({
        where: { stripePaymentId: paymentIntent.id },
      });

      if (reservation) {
        await prisma.reservation.update({
          where: { id: reservation.id },
          data: {
            paymentStatus: PaymentStatus.COMPLETED,
          },
        });

        console.log(`Payment succeeded for reservation ${reservationId}`);
      }
    }
  }

  /**
   * Gérer un échec de paiement
   */
  private async handlePaymentFailed(paymentIntent: Stripe.PaymentIntent): Promise<void> {
    const reservationId = paymentIntent.metadata.reservationId;

    if (reservationId) {
      const reservation = await prisma.reservation.findFirst({
        where: { stripePaymentId: paymentIntent.id },
      });

      if (reservation) {
        await prisma.reservation.update({
          where: { id: reservation.id },
          data: {
            paymentStatus: PaymentStatus.FAILED,
          },
        });

        console.log(`Payment failed for reservation ${reservationId}`);
      }
    }
  }

  /**
   * Gérer une contestation
   */
  private async handleDisputeCreated(dispute: Stripe.Dispute): Promise<void> {
    console.log(`Dispute created: ${dispute.id}`);
    // TODO: Implémenter la gestion des contestations
  }

  /**
   * Obtenir la politique de remboursement
   */
  getRefundPolicy(): {
    freeCancellationHours: number;
    refundPercentage: number;
    noShowPolicy: string;
  } {
    return {
      freeCancellationHours: 24,
      refundPercentage: 100,
      noShowPolicy: 'No refund for no-show',
    };
  }

  /**
   * Calculer le montant de remboursement selon la politique
   */
  calculateRefundAmount(
    reservationDate: Date,
    depositAmount: number,
    cancellationReason?: string
  ): { amount: number; reason: string } {
    const now = new Date();
    const hoursUntilReservation = (reservationDate.getTime() - now.getTime()) / (1000 * 60 * 60);

    if (cancellationReason === 'no_show') {
      return {
        amount: 0,
        reason: 'No refund for no-show',
      };
    }

    if (hoursUntilReservation >= 24) {
      return {
        amount: depositAmount,
        reason: 'Full refund - cancelled more than 24h in advance',
      };
    }

    return {
      amount: 0,
      reason: 'No refund - cancelled less than 24h in advance',
    };
  }
}

// Instance singleton
export const paymentService = new PaymentService();
export default paymentService;
