import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Payment method identifiers ──
enum PaymentMethodType {
  upiQr,
  cashOnDelivery,
}

class PaymentMethodInfo {
  final PaymentMethodType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDisabled;
  final String? disabledReason;

  const PaymentMethodInfo({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isDisabled = false,
    this.disabledReason,
  });
}

// ── Payment state ──
enum PaymentStatus { idle, processing, success, failed }

class PaymentState {
  final String orderId;
  final String serviceType;
  final double amount;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final PaymentMethodType? selectedMethod;
  final PaymentStatus status;
  final String? errorMessage;
  final List<PaymentMethodInfo> availableMethods;

  const PaymentState({
    this.orderId = '',
    this.serviceType = '',
    this.amount = 0,
    this.deliveryFee = 0,
    this.taxes = 0,
    this.discount = 0,
    this.selectedMethod,
    this.status = PaymentStatus.idle,
    this.errorMessage,
    this.availableMethods = const [],
  });

  double get subtotal => amount;
  double get totalAmount => amount + deliveryFee + taxes - discount;

  bool get isLiquorOrder =>
      serviceType.toLowerCase().contains('beverage') ||
      serviceType.toLowerCase().contains('liquor');

  bool get canProceed =>
      selectedMethod != null && status != PaymentStatus.processing;

  PaymentState copyWith({
    String? orderId,
    String? serviceType,
    double? amount,
    double? deliveryFee,
    double? taxes,
    double? discount,
    PaymentMethodType? selectedMethod,
    PaymentStatus? status,
    String? errorMessage,
    List<PaymentMethodInfo>? availableMethods,
  }) {
    return PaymentState(
      orderId: orderId ?? this.orderId,
      serviceType: serviceType ?? this.serviceType,
      amount: amount ?? this.amount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxes: taxes ?? this.taxes,
      discount: discount ?? this.discount,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      availableMethods: availableMethods ?? this.availableMethods,
    );
  }
}

// ── Notifier ──
class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    return const PaymentState();
  }

  /// Initialize payment with order details
  void initPayment({
    required String orderId,
    required String serviceType,
    required double amount,
    double deliveryFee = 0.0,
    double taxes = 0.0,
    double discount = 0.0,
  }) {
    final computedTaxes = taxes;
    final isLiquor = serviceType.toLowerCase().contains('beverage') ||
        serviceType.toLowerCase().contains('liquor');

    final methods = <PaymentMethodInfo>[
      const PaymentMethodInfo(
        type: PaymentMethodType.upiQr,
        label: 'UPI / QR Code',
        subtitle: 'Customer scans & pays via GPay, PhonePe, Paytm',
        icon: Icons.qr_code_2_rounded,
        color: Color(0xFF6366F1),
      ),
      PaymentMethodInfo(
        type: PaymentMethodType.cashOnDelivery,
        label: 'Cash Collection',
        subtitle: isLiquor
            ? 'Not available for liquor orders'
            : 'Collect cash from customer on delivery',
        icon: Icons.payments_rounded,
        color: const Color(0xFF10B981),
        isDisabled: isLiquor,
        disabledReason: isLiquor ? 'Cash not allowed for liquor orders' : null,
      ),
    ];

    state = PaymentState(
      orderId: orderId,
      serviceType: serviceType,
      amount: amount,
      deliveryFee: deliveryFee,
      taxes: computedTaxes,
      discount: discount,
      availableMethods: methods,
    );
  }

  void selectMethod(PaymentMethodType method) {
    // Prevent selecting disabled methods
    final info = state.availableMethods.firstWhere((m) => m.type == method);
    if (info.isDisabled) return;

    state = state.copyWith(selectedMethod: method);
  }

  Future<void> processPayment() async {
    if (state.selectedMethod == null) return;

    state = state.copyWith(status: PaymentStatus.processing);

    try {
      final methodString = state.selectedMethod == PaymentMethodType.cashOnDelivery
          ? 'cash'
          : 'upi';

      // 1. Mark payment as "paid" in the database
      final paymentResult = await DispatchJobService.instance.confirmPayment(
        state.orderId,
        method: methodString,
      );

      if (!paymentResult.ok) {
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: paymentResult.errorMessage ?? 'Payment update failed',
        );
        return;
      }

      // 2. Mark the order payment as collected in the local state
      ref.read(activeDeliveryProvider.notifier).markPaymentCollected();

      // 3. Refresh earnings to update "Cash in Pocket" immediately
      await ref.read(earningsProvider.notifier).refresh();

      state = state.copyWith(status: PaymentStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: e.toString().contains('403')
            ? "Unauthorized. Please login again."
            : "Verification failed. Check network.",
      );
    }
  }

  void resetPayment() {
    state = const PaymentState();
  }
}
