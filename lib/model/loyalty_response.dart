import 'dart:convert';

// Helper — safely parses int, double or string to num
num? _parseNum(dynamic val) {
  if (val == null) return null;
  if (val is num) return val;
  return num.tryParse(val.toString());
}

// GET /store/loyalty
LoyaltyAccountResponse loyaltyAccountResponseFromJson(String str) =>
    LoyaltyAccountResponse.fromJson(json.decode(str));

class LoyaltyAccountResponse {
  bool? status;
  LoyaltyAccountData? data;

  LoyaltyAccountResponse({this.status, this.data});

  factory LoyaltyAccountResponse.fromJson(Map<String, dynamic> json) =>
      LoyaltyAccountResponse(
        status: json["status"],
        data: json["data"] == null
            ? null
            : LoyaltyAccountData.fromJson(json["data"]),
      );
}

class LoyaltyAccountData {
  int? pointsBalance;
  int? totalEarned;
  int? totalRedeemed;
  String? referralCode;
  // Stored as numeric(10,4) in Postgres — comes back as string "2.0000"
  num? earnRatio;
  num? redeemRatio;
  num? minimumOrderValue;
  bool? earnEnabled;
  bool? redeemEnabled;
  bool? checkoutApplyEnabled;
  bool? allowCouponWithPoints;
  bool? allowWalletWithPoints;

  LoyaltyAccountData({
    this.pointsBalance,
    this.totalEarned,
    this.totalRedeemed,
    this.referralCode,
    this.earnRatio,
    this.redeemRatio,
    this.minimumOrderValue,
    this.earnEnabled,
    this.redeemEnabled,
    this.checkoutApplyEnabled,
    this.allowCouponWithPoints,
    this.allowWalletWithPoints,
  });

  factory LoyaltyAccountData.fromJson(Map<String, dynamic> json) =>
      LoyaltyAccountData(
        pointsBalance: json["points_balance"],
        totalEarned: json["total_earned"],
        totalRedeemed: json["total_redeemed"],
        referralCode: json["referral_code"],
        earnRatio: _parseNum(json["earn_ratio"]),
        redeemRatio: _parseNum(json["redeem_ratio"]),
        minimumOrderValue: _parseNum(json["minimum_order_value"]),
        earnEnabled: json["earn_enabled"],
        redeemEnabled: json["redeem_enabled"],
        checkoutApplyEnabled: json["checkout_apply_enabled"],
        allowCouponWithPoints: json["allow_coupon_with_points"],
        allowWalletWithPoints: json["allow_wallet_with_points"],
      );
}

// GET /store/loyalty/transactions
LoyaltyTransactionsResponse loyaltyTransactionsResponseFromJson(String str) =>
    LoyaltyTransactionsResponse.fromJson(json.decode(str));

class LoyaltyTransactionsResponse {
  bool? status;
  LoyaltyTransactionsData? data;

  LoyaltyTransactionsResponse({this.status, this.data});

  factory LoyaltyTransactionsResponse.fromJson(Map<String, dynamic> json) =>
      LoyaltyTransactionsResponse(
        status: json["status"],
        data: json["data"] == null
            ? null
            : LoyaltyTransactionsData.fromJson(json["data"]),
      );
}

class LoyaltyTransactionsData {
  List<LoyaltyTransaction>? transactions;
  int? count;
  int? limit;
  int? offset;

  LoyaltyTransactionsData({
    this.transactions,
    this.count,
    this.limit,
    this.offset,
  });

  factory LoyaltyTransactionsData.fromJson(Map<String, dynamic> json) =>
      LoyaltyTransactionsData(
        transactions: json["transactions"] == null
            ? []
            : List<LoyaltyTransaction>.from(json["transactions"]
                .map((x) => LoyaltyTransaction.fromJson(x))),
        count: json["count"],
        limit: json["limit"],
        offset: json["offset"],
      );
}

class LoyaltyTransaction {
  String? id;
  String? customerId;
  String? type;
  int? points;
  int? walletAmount;
  int? discountAmount;
  String? referenceType;
  String? referenceId;
  String? note;
  String? createdAt;

  LoyaltyTransaction({
    this.id,
    this.customerId,
    this.type,
    this.points,
    this.walletAmount,
    this.discountAmount,
    this.referenceType,
    this.referenceId,
    this.note,
    this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) =>
      LoyaltyTransaction(
        id: json["id"],
        customerId: json["customer_id"],
        type: json["type"],
        points: json["points"],
        walletAmount: json["wallet_amount"],
        discountAmount: json["discount_amount"],
        referenceType: json["reference_type"],
        referenceId: json["reference_id"],
        note: json["note"],
        createdAt: json["created_at"],
      );
}

// POST /store/loyalty/redeem
LoyaltyRedeemResponse loyaltyRedeemResponseFromJson(String str) =>
    LoyaltyRedeemResponse.fromJson(json.decode(str));

class LoyaltyRedeemResponse {
  bool? status;
  LoyaltyRedeemData? data;
  String? message;

  LoyaltyRedeemResponse({this.status, this.data, this.message});

  factory LoyaltyRedeemResponse.fromJson(Map<String, dynamic> json) =>
      LoyaltyRedeemResponse(
        status: json["status"],
        data: json["data"] == null
            ? null
            : LoyaltyRedeemData.fromJson(json["data"]),
        message: json["message"],
      );
}

class LoyaltyRedeemData {
  int? pointsRedeemed;
  num? walletCredited;
  String? transactionId;

  LoyaltyRedeemData({
    this.pointsRedeemed,
    this.walletCredited,
    this.transactionId,
  });

  factory LoyaltyRedeemData.fromJson(Map<String, dynamic> json) =>
      LoyaltyRedeemData(
        pointsRedeemed: json["points_redeemed"],
        walletCredited: _parseNum(json["wallet_credited"]),
        transactionId: json["transaction_id"],
      );
}

// GET /store/loyalty/referral
LoyaltyReferralResponse loyaltyReferralResponseFromJson(String str) =>
    LoyaltyReferralResponse.fromJson(json.decode(str));

class LoyaltyReferralResponse {
  bool? status;
  LoyaltyReferralData? data;

  LoyaltyReferralResponse({this.status, this.data});

  factory LoyaltyReferralResponse.fromJson(Map<String, dynamic> json) =>
      LoyaltyReferralResponse(
        status: json["status"],
        data: json["data"] == null
            ? null
            : LoyaltyReferralData.fromJson(json["data"]),
      );
}

class LoyaltyReferralData {
  String? referralCode;
  int? totalReferrals;
  int? referralsWithSignup;
  int? referralsWithOrder;
  int? totalPointsEarned;
  bool? rewardEnabled;
  String? rewardMode;
  int? referrerSignupPts;
  int? referrerFirstOrderPts;

  final Map<String, dynamic> _raw;

  LoyaltyReferralData({
    this.referralCode,
    this.totalReferrals,
    this.referralsWithSignup,
    this.referralsWithOrder,
    this.totalPointsEarned,
    this.rewardEnabled,
    this.rewardMode,
    this.referrerSignupPts,
    this.referrerFirstOrderPts,
    Map<String, dynamic>? raw,
  }) : _raw = raw ?? {};

  factory LoyaltyReferralData.fromJson(Map<String, dynamic> json) =>
      LoyaltyReferralData(
        referralCode: json["referral_code"],
        totalReferrals: json["total_referrals"],
        referralsWithSignup: json["referrals_with_signup"],
        referralsWithOrder: json["referrals_with_order"],
        totalPointsEarned: json["total_points_earned"],
        rewardEnabled: json["reward_enabled"],
        rewardMode: json["reward_mode"],
        referrerSignupPts: json["referrer_signup_pts"],
        referrerFirstOrderPts: json["referrer_first_order_pts"],
        raw: json,
      );

  Map<String, dynamic> toJson() => _raw;
}
