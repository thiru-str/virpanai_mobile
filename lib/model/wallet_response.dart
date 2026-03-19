class WalletResponse {
  final Wallet? wallet;

  WalletResponse({this.wallet});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
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

class WalletCheckoutResponse {
  final double walletBalance;
  final double cartTotal;
  final double applicableAmount;
  final bool canUseWallet;
  final bool autoApply;
  final double minOrderValue;
  final double remainingToPay;

  WalletCheckoutResponse({
    this.walletBalance = 0,
    this.cartTotal = 0,
    this.applicableAmount = 0,
    this.canUseWallet = false,
    this.autoApply = false,
    this.minOrderValue = 0,
    this.remainingToPay = 0,
  });

  factory WalletCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return WalletCheckoutResponse(
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0,
      cartTotal:
          double.tryParse(json['cart_total']?.toString() ?? '0') ?? 0,
      applicableAmount:
          double.tryParse(json['applicable_amount']?.toString() ?? '0') ?? 0,
      canUseWallet: json['can_use_wallet'] ?? false,
      autoApply: json['auto_apply'] ?? false,
      minOrderValue:
          double.tryParse(json['min_order_value']?.toString() ?? '0') ?? 0,
      remainingToPay:
          double.tryParse(json['remaining_to_pay']?.toString() ?? '0') ?? 0,
    );
  }
}

class WalletApplyResponse {
  final bool applied;
  final double walletAmount;
  final double remainingAmount;
  final String? walletId;
  final String? cartId;

  WalletApplyResponse({
    this.applied = false,
    this.walletAmount = 0,
    this.remainingAmount = 0,
    this.walletId,
    this.cartId,
  });

  factory WalletApplyResponse.fromJson(Map<String, dynamic> json) {
    return WalletApplyResponse(
      applied: json['applied'] ?? false,
      walletAmount:
          double.tryParse(json['wallet_amount']?.toString() ?? '0') ?? 0,
      remainingAmount:
          double.tryParse(json['remaining_amount']?.toString() ?? '0') ?? 0,
      walletId: json['wallet_id'],
      cartId: json['cart_id'],
    );
  }
}

class WalletTopUpResponse {
  final String? walletId;
  final double? amount;
  final String? currencyCode;
  final String? paymentProvider;
  final String? customerId;

  WalletTopUpResponse({
    this.walletId,
    this.amount,
    this.currencyCode,
    this.paymentProvider,
    this.customerId,
  });

  factory WalletTopUpResponse.fromJson(Map<String, dynamic> json) {
    return WalletTopUpResponse(
      walletId: json['wallet_id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0'),
      currencyCode: json['currency_code'],
      paymentProvider: json['payment_provider'],
      customerId: json['customer_id'],
    );
  }
}
