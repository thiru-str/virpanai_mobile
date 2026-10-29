import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/ui/wallet_top_up_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

// Premium UI tokens (shared recipe)
const Color _kScaffoldBg = Color(0xFFF9F9FB);
const Color _kHairline = Color(0xFFE5E7EC);
const Color _kCredit = Color(0xFF1FA971);
const Color _kCreditBg = Color(0xFFE7F7F0);
const Color _kDebit = Color(0xFFE5484D);
const Color _kDebitBg = Color(0xFFFDECEC);

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Wallet? wallet;
  TopUpConfig? topupConfig;
  List<WalletTransaction> transactions = [];
  int transactionCount = 0;
  bool loading = true;
  bool loadingMore = false;
  int offset = 0;
  final int limit = 20;
  String? filterDirection;
  String? filterType;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadWallet();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !loadingMore &&
        transactions.length < transactionCount) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadWallet() async {
    try {
      final response = await ApiService().getWalletBalance(context);
      if (mounted) {
        setState(() {
          wallet = response.wallet;
          topupConfig = response.topupConfig;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      loading = true;
      offset = 0;
      transactions = [];
    });

    try {
      final response = await ApiService().getWalletTransactions(
        context,
        limit: limit,
        offset: 0,
        type: filterType,
        direction: filterDirection,
      );
      if (mounted) {
        setState(() {
          transactions = response.transactions;
          transactionCount = response.count;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (loadingMore) return;
    setState(() => loadingMore = true);

    try {
      final newOffset = offset + limit;
      final response = await ApiService().getWalletTransactions(
        context,
        limit: limit,
        offset: newOffset,
        type: filterType,
        direction: filterDirection,
      );
      if (mounted) {
        setState(() {
          transactions.addAll(response.transactions);
          offset = newOffset;
          loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  void _showTransactionDetail(WalletTransaction txn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailSheet(transaction: txn),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kScaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Text(
          'My Wallet',
          style: UiTypography.cardTitle(color: Colors.black87)
              .copyWith(fontSize: 20, height: 1.25, letterSpacing: -0.2),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              _loadWallet();
              _loadTransactions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await _loadWallet();
          await _loadTransactions();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Balance Hero Card
            SliverToBoxAdapter(child: _balanceHero()),

            // Section header + filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    Text(
                      'Transactions',
                      style: UiTypography.cardTitle()
                          .copyWith(fontSize: 18, letterSpacing: -0.2),
                    ),
                    const Spacer(),
                    _FilterChip(
                      label: filterDirection == null
                          ? 'All'
                          : filterDirection == 'credit'
                              ? 'Credits'
                              : 'Debits',
                      onTap: () {
                        setState(() {
                          if (filterDirection == null) {
                            filterDirection = 'credit';
                          } else if (filterDirection == 'credit') {
                            filterDirection = 'debit';
                          } else {
                            filterDirection = null;
                          }
                        });
                        _loadTransactions();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Transaction List
            if (loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (transactions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _emptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= transactions.length) {
                        return loadingMore
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null;
                      }

                      final txn = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _txnRow(txn),
                      );
                    },
                    childCount: transactions.length + (loadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _balanceHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Available Balance',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '₹${wallet?.balance?.toStringAsFixed(2) ?? '0.00'}',
            style: UiTypography.cardPrice(color: Colors.white).copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (topupConfig?.canTopUp == true) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await PageRouteUtils.pushWithSlide(
                    context,
                    const WalletTopUpPage(),
                  );
                  // Refresh if top-up was successful
                  _loadWallet();
                  _loadTransactions();
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'Add Money',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _txnRow(WalletTransaction txn) {
    final isCredit = txn.direction == 'credit';
    final accent = isCredit ? _kCredit : _kDebit;
    final accentBg = isCredit ? _kCreditBg : _kDebitBg;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTransactionDetail(txn),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.typeLabel,
                      style: UiTypography.cardTitle().copyWith(fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(txn.createdAt),
                      style: UiTypography.cardMeta(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  '${isCredit ? '+' : '-'}₹${txn.amount?.toStringAsFixed(2) ?? '0.00'}',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTypography.cardPrice(color: accent)
                      .copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 34, color: AppColors.primary.withOpacity(0.7)),
          ),
          const SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: UiTypography.cardTitle().copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Your wallet activity will appear here',
            style: UiTypography.cardMeta(),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: UiTypography.cardAction(color: Colors.black87)
                  .copyWith(fontSize: 12.5),
            ),
            const SizedBox(width: 4),
            Icon(Icons.swap_vert, size: 15, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionDetailSheet({required this.transaction});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.direction == 'credit';
    final accent = isCredit ? _kCredit : _kDebit;
    final accentBg = isCredit ? _kCreditBg : _kDebitBg;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Text(
                '${isCredit ? '+' : '-'}₹${transaction.amount?.toStringAsFixed(2) ?? '0.00'}',
                style: UiTypography.cardPrice(color: accent).copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.typeLabel,
                  style: UiTypography.cardAction(color: accent)
                      .copyWith(fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kHairline),
              ),
              child: Column(
                children: [
                  _DetailRow('Date', _formatDate(transaction.createdAt)),
                  _DetailRow('Direction', transaction.direction ?? '—'),
                  _DetailRow('Transaction ID', transaction.id ?? '—'),
                  if (transaction.reason != null &&
                      transaction.reason!.isNotEmpty)
                    _DetailRow('Reason', transaction.reason!),
                  if (transaction.referenceType != null)
                    _DetailRow('Reference',
                        '${transaction.referenceType}: ${transaction.referenceId ?? '—'}'),
                  if (transaction.expiresAt != null)
                    _DetailRow(
                      'Expires',
                      transaction.expired
                          ? 'Expired'
                          : _formatDate(transaction.expiresAt),
                    ),
                  if (transaction.createdBy != null)
                    _DetailRow('Created By', transaction.createdBy!),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: UiTypography.cardMeta(color: Colors.grey.shade600)
                  .copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: UiTypography.cardSubtitle(color: Colors.black87)
                  .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
