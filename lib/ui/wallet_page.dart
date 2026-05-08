import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/ui/wallet_top_up_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';

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
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadWallet();
              _loadTransactions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadWallet();
          await _loadTransactions();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Balance Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${wallet?.balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (topupConfig?.canTopUp == true)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await PageRouteUtils.pushWithSlide(
                              context,
                              const WalletTopUpPage(),
                            );
                            // Refresh if top-up was successful
                            _loadWallet();
                            _loadTransactions();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Money'),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Transaction List
            if (loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (transactions.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= transactions.length) {
                      return loadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null;
                    }

                    final txn = transactions[index];
                    final isCredit = txn.direction == 'credit';

                    return ListTile(
                      onTap: () => _showTransactionDetail(txn),
                      leading: CircleAvatar(
                        backgroundColor: isCredit
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        txn.typeLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatDate(txn.createdAt),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 92),
                        child: Text(
                          '${isCredit ? '+' : '-'}₹${txn.amount?.toStringAsFixed(2) ?? '0.00'}',
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: transactions.length + (loadingMore ? 1 : 0),
                ),
              ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.swap_vert, size: 14),
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

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '${isCredit ? '+' : '-'}₹${transaction.amount?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.typeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isCredit ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow('Date', _formatDate(transaction.createdAt)),
            _DetailRow('Direction', transaction.direction ?? '—'),
            _DetailRow('Transaction ID', transaction.id ?? '—'),
            if (transaction.reason != null && transaction.reason!.isNotEmpty)
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
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
