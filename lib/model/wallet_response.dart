class WalletResponse {
  final Wallet? wallet;
  final TopUpConfig? topupConfig;
  final String? walletMode; // "full_payment" or "split_payment"
  final bool autoApplyWallet;

  WalletResponse({this.wallet, this.topupConfig, this.walletMode, this.autoApplyWallet = true});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
      topupConfig: json['topup_config'] != null
          ? TopUpConfig.fromJson(json['topup_config'])
          : null,
      walletMode: json['wallet_mode'] ?? 'full_payment',
      autoApplyWallet: json['auto_apply_wallet'] ?? true,
    );
  }

  bool get isSplitPayment => walletMode == 'split_payment';
}

class WalletSplitResponse {
  final bool walletApplied;
  final double walletAmount;
  final double gatewayAmount;
  final double walletBalance;
  final bool fullWalletCoverage;

  WalletSplitResponse({
    this.walletApplied = false,
    this.walletAmount = 0,
    this.gatewayAmount = 0,
    this.walletBalance = 0,
    this.fullWalletCoverage = false,
  });

  factory WalletSplitResponse.fromJson(Map<String, dynamic> json) {
    return WalletSplitResponse(
      walletApplied: json['wallet_applied'] ?? false,
      walletAmount:
          double.tryParse(json['wallet_amount']?.toString() ?? '0') ?? 0,
      gatewayAmount:
          double.tryParse(json['gateway_amount']?.toString() ?? '0') ?? 0,
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0,
      fullWalletCoverage: json['full_wallet_coverage'] ?? false,
    );
  }
}

class Wallet {
  final String? id;
  final String? customerId;
  final String? currencyCode;
  final String? status;
  final double? balance;
  final String? createdAt;
  final String? updatedAt;

  Wallet({
    this.id,
    this.customerId,
    this.currencyCode,
    this.status,
    this.balance,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      customerId: json['customer_id'],
      currencyCode: json['currency_code'],
      status: json['status'],
      balance: json['balance'] != null
          ? double.tryParse(json['balance'].toString()) ?? 0.0
          : 0.0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TopUpConfig {
  final bool allowCustomerTopup;
  final String? topupPaymentProvider;
  final double minTopupAmount;
  final double maxTopupAmount;
  final double maxWalletBalance;

  TopUpConfig({
    this.allowCustomerTopup = false,
    this.topupPaymentProvider,
    this.minTopupAmount = 100,
    this.maxTopupAmount = 10000,
    this.maxWalletBalance = 10000,
  });

  factory TopUpConfig.fromJson(Map<String, dynamic> json) {
    return TopUpConfig(
      allowCustomerTopup: json['allow_customer_topup'] ?? false,
      topupPaymentProvider: json['topup_payment_provider'],
      minTopupAmount: double.tryParse(
              json['min_topup_amount']?.toString() ?? '100') ??
          100,
      maxTopupAmount: double.tryParse(
              json['max_topup_amount']?.toString() ?? '10000') ??
          10000,
      maxWalletBalance: double.tryParse(
              json['max_wallet_balance']?.toString() ?? '10000') ??
          10000,
    );
  }

  bool get canTopUp =>
      allowCustomerTopup &&
      topupPaymentProvider != null &&
      topupPaymentProvider!.isNotEmpty;
}

class WalletTransactionsResponse {
  final List<WalletTransaction> transactions;
  final int count;
  final int limit;
  final int offset;

  WalletTransactionsResponse({
    this.transactions = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponse(
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => WalletTransaction.fromJson(t))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
    );
  }
}

class WalletTransaction {
  final String? id;
  final String? type;
  final String? direction;
  final double? amount;
  final String? idempotencyKey;
  final String? referenceType;
  final String? referenceId;
  final String? reason;
  final String? createdBy;
  final String? expiresAt;
  final bool expired;
  final String? createdAt;

  WalletTransaction({
    this.id,
    this.type,
    this.direction,
    this.amount,
    this.idempotencyKey,
    this.referenceType,
    this.referenceId,
    this.reason,
    this.createdBy,
    this.expiresAt,
    this.expired = false,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      type: json['type'],
      direction: json['direction'],
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
      idempotencyKey: json['idempotency_key'],
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      reason: json['reason'],
      createdBy: json['created_by'],
      expiresAt: json['expires_at'],
      expired: json['expired'] ?? false,
      createdAt: json['created_at'],
    );
  }

  String get typeLabel {
    const labels = {
      'top_up': 'Top-Up',
      'purchase': 'Purchase',
      'refund': 'Refund',
      'admin_credit': 'Credit',
      'admin_debit': 'Debit',
      'cashback': 'Cashback',
      'reward_conversion': 'Reward',
      'expiry': 'Expired',
      'reversal': 'Reversal',
    };
    return labels[type] ?? type ?? 'Unknown';
  }
}

class WalletTopUpResponse {
  final String? walletId;
  final double? amount;
  final String? currencyCode;
  final String? paymentProvider;
  final String? customerId;
  final String? razorpayOrderId;
  final String? razorpayKey;

  WalletTopUpResponse({
    this.walletId,
    this.amount,
    this.currencyCode,
    this.paymentProvider,
    this.customerId,
    this.razorpayOrderId,
    this.razorpayKey,
  });

  factory WalletTopUpResponse.fromJson(Map<String, dynamic> json) {
    return WalletTopUpResponse(
      walletId: json['wallet_id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0'),
      currencyCode: json['currency_code'],
      paymentProvider: json['payment_provider'],
      customerId: json['customer_id'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpayKey: json['razorpay_key'],
    );
  }
}

class WalletConfirmResponse {
  final bool success;
  final Wallet? wallet;

  WalletConfirmResponse({this.success = false, this.wallet});

  factory WalletConfirmResponse.fromJson(Map<String, dynamic> json) {
    return WalletConfirmResponse(
      success: json['success'] ?? false,
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
    );
  }
}
