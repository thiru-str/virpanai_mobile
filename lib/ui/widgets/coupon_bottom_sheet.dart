import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/promotion_list_model.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class CouponBottomSheet extends StatefulWidget {
  final String cartId;
  final List<String> appliedCodes;
  final Future<void> Function(String code) onApply;
  final Future<void> Function(List<String> codes) onRemove;

  const CouponBottomSheet({
    super.key,
    required this.cartId,
    required this.appliedCodes,
    required this.onApply,
    required this.onRemove,
  });

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  List<AvailablePromotion> _promotions = [];
  bool _loading = true;
  bool _showCouponList = true;
  String? _error;
  String? _actionCode; // code currently being applied/removed

  final TextEditingController _manualController = TextEditingController();
  String? _manualError;

  @override
  void initState() {
    super.initState();
    _initializeCouponSettings();
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _initializeCouponSettings() async {
    try {
      final visible = await ApiService().getCouponListVisibility();
      if (!mounted) return;

      setState(() {
        _showCouponList = visible;
      });

      if (!visible) {
        setState(() {
          _loading = false;
        });
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _showCouponList = true;
      });
    }

    await _loadPromotions();
  }

  Future<void> _applyManual() async {
    final code = _manualController.text.trim();
    if (code.isEmpty) {
      setState(() => _manualError = 'Please enter a coupon code');
      return;
    }
    setState(() {
      _manualError = null;
      _actionCode = code;
    });
    try {
      await widget.onApply(code);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _actionCode = null);
    }
  }

  Future<void> _loadPromotions() async {
    try {
      final result =
          await ApiService().getAvailablePromotions(context, widget.cartId);
      if (!mounted) return;
      setState(() {
        _promotions = result.promotions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load coupons';
        _loading = false;
      });
    }
  }

  Future<void> _apply(String code) async {
    setState(() => _actionCode = code);
    try {
      await widget.onApply(code);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _actionCode = null);
    }
  }

  Future<void> _remove(List<String> codes) async {
    setState(() => _actionCode = codes.firstOrNull);
    try {
      await widget.onRemove(codes);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _actionCode = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligible =
        _promotions.where((p) => p.isEligible && !p.isApplied).toList();
    final applied = _promotions.where((p) => p.isApplied).toList();
    final ineligible = _promotions.where((p) => !p.isEligible && !p.isApplied).toList();
    final initialChildSize = _showCouponList ? 0.75 : 0.24;
    final maxChildSize = _showCouponList ? 0.92 : 0.28;
    final minChildSize = _showCouponList ? 0.4 : 0.22;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      minChildSize: minChildSize,
      expand: false,
      builder: (_, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Coupons & Offers',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: Colors.grey.shade600, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showCouponList) ...[
                Divider(height: 1, color: Colors.grey.shade100),
                // Content
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Text(_error!,
                                  style: TextStyle(color: Colors.grey.shade600)),
                            )
                          : _promotions.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_offer_outlined,
                                          size: 48, color: Colors.grey.shade300),
                                      const SizedBox(height: 12),
                                      Text('No coupons available',
                                          style: TextStyle(color: Colors.grey.shade500)),
                                    ],
                                  ),
                                )
                              : ListView(
                                  controller: scrollController,
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                  children: [
                                    if (applied.isNotEmpty) ...[
                                      _sectionLabel('Applied'),
                                      ...applied.map((p) => _PromoCard(
                                            promo: p,
                                            actionCode: _actionCode,
                                            onRemove: () => _remove(
                                              applied.map((x) => x.code).toList(),
                                            ),
                                          )),
                                      const SizedBox(height: 8),
                                    ],
                                    if (eligible.isNotEmpty) ...[
                                      _sectionLabel('Available Offers'),
                                      ...eligible.map((p) => _PromoCard(
                                            promo: p,
                                            actionCode: _actionCode,
                                            onApply: () => _apply(p.code),
                                          )),
                                      const SizedBox(height: 8),
                                    ],
                                    if (ineligible.isNotEmpty) ...[
                                      _sectionLabel('Not Available Offers'),
                                      ...ineligible.map((p) => _PromoCard(
                                            promo: p,
                                            actionCode: _actionCode,
                                          )),
                                    ],
                                  ],
                                ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final AvailablePromotion promo;
  final String? actionCode;
  final VoidCallback? onApply;
  final VoidCallback? onRemove;

  const _PromoCard({
    required this.promo,
    required this.actionCode,
    this.onApply,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isActing = actionCode == promo.code;
    final isApplied = promo.isApplied;
    final isEligible = promo.isEligible;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApplied
              ? Colors.green.shade200
              : isEligible
                  ? Colors.grey.shade200
                  : Colors.grey.shade100,
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Middle: code + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isApplied
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        promo.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      if (promo.estimatedDiscountDisplay != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          promo.estimatedDiscountDisplay!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right: action button
                if (isApplied)
                  _ActionButton(
                    label: 'Remove',
                    color: Colors.red.shade600,
                    isLoading: isActing,
                    onTap: onRemove,
                  )
                else if (isEligible)
                  _ActionButton(
                    label: 'Apply',
                    color: AppColors.primary,
                    isLoading: isActing,
                    onTap: onApply,
                  ),
              ],
            ),
          ),
          // Ineligibility reason strip
          if (!isEligible && !isApplied && promo.ineligibilityReason != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 13, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      promo.ineligibilityReason!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade100 : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isLoading ? Colors.grey.shade200 : color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: color,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
      ),
    );
  }
}
