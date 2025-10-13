import { PaymentIntent } from '../entities/PaymentIntent';
import { Refund } from '../entities/Refund';
import { RefundPolicy } from '../entities/RefundPolicy';

export interface CreatePaymentIntentData {
  amount: number;
  currency: string;
  reservationId: string;
  userId: string;
  metadata?: Record<string, any> | undefined;
}

export interface CreateRefundData {
  amount: number;
  currency: string;
  reason: string;
  reservationId: string;
  paymentIntentId: string;
  metadata?: Record<string, any> | undefined;
}

export interface PaymentRepository {
  // PaymentIntent operations
  createPaymentIntent(data: CreatePaymentIntentData): Promise<PaymentIntent>;
  findPaymentIntentById(id: string): Promise<PaymentIntent | null>;
  findPaymentIntentByReservationId(reservationId: string): Promise<PaymentIntent | null>;
  updatePaymentIntentStatus(id: string, status: string): Promise<PaymentIntent>;
  
  // Refund operations
  createRefund(data: CreateRefundData): Promise<Refund>;
  findRefundById(id: string): Promise<Refund | null>;
  findRefundsByReservationId(reservationId: string): Promise<Refund[]>;
  updateRefundStatus(id: string, status: string): Promise<Refund>;
  
  // RefundPolicy operations
  getRefundPolicy(): Promise<RefundPolicy>;
  updateRefundPolicy(policy: RefundPolicy): Promise<RefundPolicy>;
  
  // Webhook operations
  handleWebhookEvent(eventType: string, eventData: any): Promise<void>;
}
