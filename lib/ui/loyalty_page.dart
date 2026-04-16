import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../api/api_service.dart';
import '../model/loyalty_response.dart';
import '../utility/app_colors.dart';
import '../utility/currency_util.dart';
import '../utility/font_utils.dart';

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends State<LoyaltyPage> {
  final ApiService _api = ApiService();
  LoyaltyAccountData? _account;
  LoyaltyReferralData? _referral;
  List<dynamic> _referralHistory = [];
  List<LoyaltyTransaction> _transactions = [];
  bool _isLoading = true;
  bool _isRedeeming = false;
  bool _isLoadingMore = false;
  bool _hasMoreTransactions = true;
  static const int _txnPageSize = 10;
  final TextEditingController _redeemCtrl = TextEditingController();
  String? _redeemPreview;

  @override
  void initState() {
    super.initState();
    _redeemCtrl.addListener(_onRedeemChanged);
    _loadData();
  }

  void _onRedeemChanged() {
    final pts = int.tryParse(_redeemCtrl.text) ?? 0;
    final ratio = _ratioDouble();
    if (pts > 0 && ratio > 0) {
      final credit = (pts / ratio).floor();
      setState(() => _redeemPreview = CurrencyUtil.appendCurrency(credit.toStringAsFixed(0)));
    } else {
      setState(() => _redeemPreview = null);
    }
  }

  double _ratioDouble() {
    final r = _account?.redeemRatio;
    if (r == null) return 1.0;
    return double.tryParse(r.toString()) ?? 1.0;
  }

  String _numFmt(num? val) {
    if (val == null) return '0';
    final d = val.toDouble();
    return d == d.toInt() ? '${d.toInt()}' : val.toString();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getLoyaltyAccount(),
        _api.getLoyaltyTransactions(limit: _txnPageSize, offset: 0),
        _api.getLoyaltyReferral(),
        _api.getLoyaltyReferralHistory(limit: 20, offset: 0),
      ]);
      final accountResp = LoyaltyAccountResponse.fromJson(results[0].data);
      final txnResp = LoyaltyTransactionsResponse.fromJson(results[1].data);
      final refResp = LoyaltyReferralResponse.fromJson(results[2].data);
      final refHistoryData = results[3].data;
      final refHistoryList = (refHistoryData['status'] == true && refHistoryData['data'] is List)
          ? refHistoryData['data'] as List<dynamic>
          : <dynamic>[];
      final txnList = txnResp.data?.transactions ?? [];
      setState(() {
        _account = accountResp.data;
        _transactions = txnList;
        _hasMoreTransactions = txnList.length >= _txnPageSize;
        _referral = refResp.data;
        _referralHistory = refHistoryList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading loyalty data: $e');
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMoreTransactions) return;
    setState(() => _isLoadingMore = true);
    try {
      final resp = await _api.getLoyaltyTransactions(limit: _txnPageSize, offset: _transactions.length);
      final txnResp = LoyaltyTransactionsResponse.fromJson(resp.data);
      final newTxns = txnResp.data?.transactions ?? [];
      setState(() {
        _transactions.addAll(newTxns);
        _hasMoreTransactions = newTxns.length >= _txnPageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      debugPrint('Error loading more transactions: $e');
    }
  }

  Future<void> _handleRedeem() async {
    final pts = int.tryParse(_redeemCtrl.text) ?? 0;
    if (pts <= 0) return;
    setState(() => _isRedeeming = true);
    try {
      final resp = await _api.redeemLoyaltyPoints(pts);
      final result = LoyaltyRedeemResponse.fromJson(resp.data);
      if (result.status == true && result.data != null) {
        _redeemCtrl.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${result.data!.pointsRedeemed} pts → ${CurrencyUtil.appendCurrency(result.data!.walletCredited!.toStringAsFixed(0))} added to wallet'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        }
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.message ?? 'Failed to redeem'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to redeem points'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    }
    if (mounted) setState(() => _isRedeeming = false);
  }

  void _useMax() {
    final max = _account?.pointsBalance ?? 0;
    if (max > 0) {
      _redeemCtrl.text = '$max';
      _redeemCtrl.selection = TextSelection.fromPosition(TextPosition(offset: '$max'.length));
    }
  }

  void _copyCode() {
    if (_referral?.referralCode != null) {
      Clipboard.setData(ClipboardData(text: _referral!.referralCode!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Copied!'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1),
        ));
      }
    }
  }

  void _shareCode() {
    if (_referral?.referralCode != null) {
      final box = context.findRenderObject() as RenderBox?;
      Share.share(
        'Use my referral code ${_referral!.referralCode!} to earn rewards!\nDownload the app and enter my code during signup.',
        subject: 'Join me and earn rewards!',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Text('Loyalty Points',
            style: FontUtils.primaryFontStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _account == null
              ? const Center(child: Text('Unable to load loyalty data'))
              : RefreshIndicator(
                  onRefresh: _loadData, color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    children: [
                      _heroCard(),
                      const SizedBox(height: 14),
                      if (_account!.earnEnabled == true) _earnBanner(),
                      if (_account!.redeemEnabled == true) ...[const SizedBox(height: 14), _redeemSection()],
                      if (_referral?.referralCode != null) ...[const SizedBox(height: 14), _referralSection()],
                      const SizedBox(height: 20),
                      _historySection(),
                    ],
                  ),
                ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Text('POINTS BALANCE', style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), letterSpacing: 2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_account!.pointsBalance ?? 0}',
                  style: FontUtils.primaryFontStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text('pts', style: FontUtils.secondaryFontStyle(fontSize: 16, color: Colors.white.withOpacity(0.6))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.15), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _heroStat('Earned', '${_account!.totalEarned ?? 0}'),
              Container(width: 1, height: 28, color: Colors.white.withOpacity(0.15)),
              _heroStat('Redeemed', '${_account!.totalRedeemed ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(children: [
          Text(label, style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 4),
          Text('$value pts', style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _earnBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(children: [
        Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text('Earn 1 point for every ₹${_numFmt(_account!.earnRatio)} spent',
            style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade700))),
      ]),
    );
  }

  Widget _redeemSection() {
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text('Redeem → Wallet', style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text('${_numFmt(_account!.redeemRatio)} points = ${CurrencyUtil.appendCurrency("1")}',
          style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.grey.shade500)),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: TextField(
            controller: _redeemCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Points to redeem', hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
              suffixIcon: GestureDetector(
                onTap: _useMax,
                child: Center(
                  widthFactor: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                    child: Text('MAX', style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(height: 46, child: ElevatedButton(
          onPressed: _isRedeeming ? null : _handleRedeem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isRedeeming
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Redeem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        )),
      ]),
      if (_redeemPreview != null)
        Padding(padding: const EdgeInsets.only(top: 6, left: 2), child: Row(children: [
          Icon(Icons.arrow_forward, size: 12, color: Colors.green.shade600),
          const SizedBox(width: 4),
          Text('$_redeemPreview wallet credit', style: FontUtils.secondaryFontStyle(fontSize: 12, color: Colors.green.shade700)),
        ])),
    ]));
  }

  Widget _referralSection() {
    final rewardEnabled = _referral?.rewardEnabled == true;
    final rewardMode = _referral?.rewardMode ?? 'both';
    final signupPts = _referral?.referrerSignupPts ?? 0;
    final orderPts = _referral?.referrerFirstOrderPts ?? 0;

    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.people_outline, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text('Refer & Earn', style: FontUtils.primaryFontStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
      // Reward info banner
      if (rewardEnabled) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((rewardMode == 'signup' || rewardMode == 'both') && (signupPts as num) > 0)
                Text('• Earn $signupPts pts when a friend signs up',
                    style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.green.shade700)),
              if ((rewardMode == 'first_order' || rewardMode == 'both') && (orderPts as num) > 0)
                Text('• Earn $orderPts pts when they place first order',
                    style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.green.shade700)),
            ],
          ),
        ),
      ],
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.04), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Center(child: Text(_referral!.referralCode!,
            style: FontUtils.primaryFontStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 3))),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: _copyCode, icon: const Icon(Icons.copy, size: 15), label: const Text('Copy'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary, side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton.icon(
          onPressed: _shareCode, icon: const Icon(Icons.share, size: 15), label: const Text('Share'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )),
      ]),
      if ((_referral?.totalReferrals ?? 0) > 0) ...[
        const SizedBox(height: 12), Divider(color: Colors.grey.shade200, height: 1), const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _refStat('Referred', _referral!.totalReferrals ?? 0),
          _refStat('Signups', _referral!.referralsWithSignup ?? 0),
          _refStat('Orders', _referral!.referralsWithOrder ?? 0),
        ]),
      ],
      // Referral history — who signed up using your code
      if (_referralHistory.isNotEmpty) ...[
        const SizedBox(height: 12), Divider(color: Colors.grey.shade200, height: 1), const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('People who used your code', style: FontUtils.secondaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            if (_referralHistory.length > 3)
              GestureDetector(
                onTap: () => _showAllReferrals(context),
                child: Text('View All (${_referralHistory.length})',
                    style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Show max 3 inline
        ..._referralHistory.take(3).map((ref) => _buildReferralRow(ref)),
      ],
    ]));
  }

  Widget _buildReferralRow(dynamic ref) {
    final name = ref['referred_name'] ?? 'Customer';
    final status = ref['status'] ?? 'signed_up';
    final ptsEarned = ref['points_earned'] ?? 0;
    final ptsPending = ref['pending_points'] ?? 0;
    final date = ref['created_at'] != null ? DateTime.tryParse(ref['created_at']) : null;
    final dateStr = date != null
        ? '${date.day} ${['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month]}'
        : '';
    final isOrdered = status == 'first_order';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isOrdered ? Colors.green.shade50 : AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(isOrdered ? Icons.shopping_bag_outlined : Icons.person_outline,
              size: 16, color: isOrdered ? Colors.green.shade600 : AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(isOrdered ? 'Placed first order' : 'Signed up',
              style: FontUtils.secondaryFontStyle(fontSize: 11, color: isOrdered ? Colors.green.shade600 : Colors.grey.shade500)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if ((ptsEarned as num) > 0)
            Text('+$ptsEarned pts', style: FontUtils.primaryFontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade600)),
          if ((ptsPending as num) > 0 && (ptsEarned as num) == 0)
            Text('Pending', style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.orange.shade600)),
          if (dateStr.isNotEmpty)
            Text(dateStr, style: FontUtils.secondaryFontStyle(fontSize: 10, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }

  void _showAllReferrals(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => Column(children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('All Referrals (${_referralHistory.length})',
                  style: FontUtils.primaryFontStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: 22, color: Colors.grey.shade600),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _referralHistory.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (_, i) => _buildReferralRow(_referralHistory[i]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _refStat(String label, int value) => Column(children: [
    Text('$value', style: FontUtils.primaryFontStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
    const SizedBox(height: 2),
    Text(label, style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.grey.shade500)),
  ]);

  Widget _historySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Points History', style: FontUtils.primaryFontStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      if (_transactions.isEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Column(children: [
            Icon(Icons.stars_outlined, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No transactions yet', style: FontUtils.secondaryFontStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 2),
            Text('Earn points by placing orders!', style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.grey.shade400)),
          ]),
        )
      else
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                ..._transactions.asMap().entries.map((e) {
                  final i = e.key; final txn = e.value;
                  return Column(children: [
                    _txnItem(txn),
                    if (i < _transactions.length - 1) Divider(height: 1, indent: 56, color: Colors.grey.shade100),
                  ]);
                }),
                // Load More button
                if (_hasMoreTransactions)
                  GestureDetector(
                    onTap: _isLoadingMore ? null : _loadMoreTransactions,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Center(
                        child: _isLoadingMore
                            ? SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : Text('Load More',
                                style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
    ]);
  }

  Widget _txnItem(LoyaltyTransaction txn) {
    final pts = txn.points ?? 0;
    final pos = pts > 0;
    final info = _typeInfo(txn.type ?? '');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(info.icon, color: info.color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(info.label, style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (txn.note != null && txn.note!.isNotEmpty)
            Text(txn.note!, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: FontUtils.secondaryFontStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: pos ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${pos ? "+" : ""}$pts pts',
              style: FontUtils.primaryFontStyle(
                fontSize: 13, fontWeight: FontWeight.bold,
                color: pos ? Colors.green.shade700 : Colors.red.shade600,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            pos ? 'Credited' : 'Debited',
            style: FontUtils.secondaryFontStyle(
              fontSize: 10,
              color: pos ? Colors.green.shade400 : Colors.red.shade300,
            ),
          ),
          if (txn.createdAt != null)
            Text(_fmtDate(txn.createdAt!),
                style: FontUtils.secondaryFontStyle(fontSize: 10, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }

  ({String label, IconData icon, Color color}) _typeInfo(String type) => switch (type) {
    'earn' => (label: 'Points Earned', icon: Icons.shopping_bag_outlined, color: Colors.green),
    'redeem' => (label: 'Redeemed to Wallet', icon: Icons.account_balance_wallet_outlined, color: AppColors.primary),
    'checkout_apply' => (label: 'Checkout Discount', icon: Icons.local_offer_outlined, color: Colors.teal),
    'reversal' => (label: 'Points Reversed', icon: Icons.undo, color: Colors.orange),
    'referral_earn' => (label: 'Referral Bonus', icon: Icons.people_outline, color: Colors.purple),
    'admin_credit' => (label: 'Admin Credit', icon: Icons.add_circle_outline, color: Colors.green),
    'admin_debit' => (label: 'Admin Debit', icon: Icons.remove_circle_outline, color: Colors.red),
    _ => (label: type, icon: Icons.stars_outlined, color: Colors.amber),
  };

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month]}';
    } catch (_) { return ''; }
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: child,
  );

  @override
  void dispose() {
    _redeemCtrl.removeListener(_onRedeemChanged);
    _redeemCtrl.dispose();
    super.dispose();
  }
}
