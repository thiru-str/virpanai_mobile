import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/delivery_schedule_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget — max 2-card layout on cart page.
// Schedule is a button ON the delivery card, not a separate card.
// ─────────────────────────────────────────────────────────────────────────────
class FulfillmentMethodWidget extends StatefulWidget {
  final void Function(FulfillmentSelection?) onChanged;
  final Map<String, dynamic>? cartMetadata;

  const FulfillmentMethodWidget({
    super.key,
    required this.onChanged,
    this.cartMetadata,
  });

  @override
  State<FulfillmentMethodWidget> createState() => _FulfillmentMethodWidgetState();
}

class _FulfillmentMethodWidgetState extends State<FulfillmentMethodWidget> {
  final _api = ApiService();
  DeliveryConfig? _config;
  bool _loading = true;
  FulfillmentSelection _selection = const FulfillmentSelection(type: 'standard');

  @override
  void initState() {
    super.initState();
    _restoreFromMetadata();
    _load();
  }

  void _restoreFromMetadata() {
    final m = widget.cartMetadata;
    if (m == null) return;
    final type = m['fulfillment_type'] as String? ?? 'standard';
    if (type == 'scheduled') {
      _selection = FulfillmentSelection(
        type: 'scheduled',
        deliveryDate: m['delivery_date'] as String?,
        deliverySlotId: m['delivery_time_slot_id'] as String?,
        deliverySlotLabel: m['delivery_time_slot_label'] as String?,
        deliveryInstructions: m['delivery_instructions'] as String?,
      );
    } else if (type == 'pickup') {
      _selection = FulfillmentSelection(
        type: 'pickup',
        pickupDate: m['pickup_date'] as String?,
        pickupSlotId: m['pickup_slot_id'] as String?,
        pickupSlotLabel: m['pickup_slot_label'] as String?,
        pickupAnyTime: m['pickup_any_time'] == true,
        pickupAddress: m['pickup_address'] as String?,
      );
    }
  }

  Future<void> _load() async {
    try {
      final cfg = await _api.getDeliveryConfig(context);
      if (!mounted) return;
      setState(() { _config = cfg; _loading = false; });
      if (!cfg.scheduledDeliveryEnabled && !cfg.pickupEnabled) {
        widget.onChanged(const FulfillmentSelection(type: 'standard'));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        widget.onChanged(const FulfillmentSelection(type: 'standard'));
      }
    }
  }

  // Open delivery schedule sheet (schedule-only, no standard tab)
  Future<void> _openDeliverySheet() async {
    final cfg = _config;
    if (cfg == null) return;
    final result = await showModalBottomSheet<FulfillmentSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeliverySheet(config: cfg, current: _selection),
    );
    if (result != null && mounted) {
      setState(() => _selection = result);
      widget.onChanged(result);
    }
  }

  // Open pickup sheet
  Future<void> _openPickupSheet() async {
    final cfg = _config;
    if (cfg == null || !cfg.pickupEnabled) return;
    final result = await showModalBottomSheet<FulfillmentSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickupSheet(config: cfg, current: _selection),
    );
    if (result != null && mounted) {
      setState(() => _selection = result);
      widget.onChanged(result);
    }
  }

  // Switch back to standard delivery (no schedule)
  void _revertToStandard() {
    const std = FulfillmentSelection(type: 'standard');
    setState(() => _selection = std);
    widget.onChanged(std);
  }

  @override
  Widget build(BuildContext context) {
    // Show nothing only on first load (no restored selection yet)
    if (_config == null) return const SizedBox.shrink();
    final cfg = _config!;

    // Scenario: both disabled → hidden
    if (!cfg.pickupEnabled && !cfg.scheduledDeliveryEnabled) return const SizedBox.shrink();

    final isScheduled = _selection.type == 'scheduled';
    final isPickup = _selection.type == 'pickup';
    final deliveryActive = !isPickup; // delivery card is active when not on pickup

    // ── Delivery card CTA ────────────────────────────────────────
    // Show "Schedule"/"Edit" only when scheduledDeliveryEnabled
    final String? deliveryCtaLabel = cfg.scheduledDeliveryEnabled
        ? (isScheduled ? 'Edit' : 'Schedule')
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card 1: Home Delivery ─────────────────────────────────
        _SummaryCard(
          icon: Icons.local_shipping_outlined,
          iconColor: deliveryActive ? AppColors.primary : Colors.grey.shade500,
          iconBg: deliveryActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          title: isScheduled
              ? _dateSlotLine(_selection.deliveryDate, _selection.deliverySlotLabel)
              : 'Home Delivery',
          subtitle: isScheduled ? 'Scheduled delivery' : 'Delivered as soon as possible',
          ctaLabel: deliveryCtaLabel,
          ctaColor: AppColors.primary,
          active: deliveryActive,
          activeColor: AppColors.primary,
          onTap: isPickup ? _revertToStandard : null,
          onCtaTap: deliveryCtaLabel != null ? _openDeliverySheet : null,
        ),

        // ── Card 2: Self Pickup (only if pickupEnabled) ───────────
        if (cfg.pickupEnabled) ...[
          const SizedBox(height: 8),
          _SummaryCard(
            icon: Icons.storefront_outlined,
            iconColor: isPickup ? Colors.orange.shade600 : Colors.grey.shade500,
            iconBg: isPickup ? Colors.orange.shade50 : Colors.grey.shade50,
            title: isPickup
                ? _dateSlotLine(
                    _selection.pickupDate,
                    _selection.pickupSlotLabel ?? (_selection.pickupAnyTime == true ? 'Any time' : null),
                  )
                : 'Self Pickup',
            subtitle: isPickup ? 'Self Pickup' : 'Collect from our store',
            ctaLabel: isPickup ? 'Edit' : 'Book',
            ctaColor: Colors.orange.shade600,
            active: isPickup,
            activeColor: Colors.orange.shade600,
            onTap: _openPickupSheet,
            onCtaTap: _openPickupSheet,
          ),
        ],
      ],
    );
  }

  static String _dateSlotLine(String? date, String? slot) {
    if (date == null) return slot ?? 'Scheduled';
    final d = DateTime.tryParse(date);
    if (d == null) return slot ?? 'Scheduled';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = d.isAtSameMomentAs(today)
        ? 'Today'
        : d.isAtSameMomentAs(tomorrow)
            ? 'Tomorrow'
            : '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
    return slot != null ? '$dateStr  ·  $slot' : dateStr;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact summary card — shown on cart page.
// onTap   = whole card body tapped
// onCtaTap = CTA pill button tapped (stops propagation)
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final Color ctaColor;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;
  final VoidCallback? onCtaTap;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    required this.ctaColor,
    required this.active,
    required this.activeColor,
    this.onTap,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.35) : Colors.grey.shade200,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Radio indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? activeColor : Colors.grey.shade300,
                width: active ? 2 : 1.5,
              ),
            ),
            child: active
                ? Center(
                    child: Container(
                      width: 9, height: 9,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: activeColor),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),

          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 11),

          // Text
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A))),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
          )),

          // CTA pill button — separate gesture to stop propagation
          if (ctaLabel != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCtaTap,
              // absorb the tap so the card body onTap doesn't also fire
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ctaColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ctaColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  ctaLabel!,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ctaColor),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Delivery sheet — Instant Delivery ↔ Schedule toggle (Zepto pattern)
// ─────────────────────────────────────────────────────────────────────────────
class _DeliverySheet extends StatefulWidget {
  final DeliveryConfig config;
  final FulfillmentSelection current;
  const _DeliverySheet({required this.config, required this.current});

  @override
  State<_DeliverySheet> createState() => _DeliverySheetState();
}

class _DeliverySheetState extends State<_DeliverySheet> {
  final _api = ApiService();

  // 'instant' | 'schedule'
  late String _mode;
  late List<DateTime> _dates;
  late int _dateIndex;
  List<DeliverySlot> _slots = [];
  bool _loadingSlots = false;
  int? _slotCount;
  String? _blocked;
  String? _slotError;
  String? _slotId;
  String? _slotLabel;
  final _instrCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mode = widget.current.type == 'scheduled' ? 'schedule' : 'instant';

    final now = DateTime.now();
    final cap = widget.config.maxDaysAdvance.clamp(1, 7);
    _dates = List.generate(cap, (i) => DateTime(now.year, now.month, now.day + i));

    final saved = widget.current.deliveryDate;
    _dateIndex = 0;
    if (saved != null) {
      final idx = _dates.indexWhere((d) => _fmt(d) == saved);
      if (idx >= 0) _dateIndex = idx;
    }
    if (widget.current.deliveryInstructions != null) {
      _instrCtrl.text = widget.current.deliveryInstructions!;
    }
    if (_mode == 'schedule') _loadSlots(_dates[_dateIndex]);
  }

  @override
  void dispose() {
    _instrCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _switchMode(String mode) {
    setState(() { _mode = mode; });
    if (mode == 'schedule' && _slots.isEmpty && _blocked == null && _slotError == null) {
      _loadSlots(_dates[_dateIndex]);
    }
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _loadingSlots = true; _slots = []; _slotCount = null;
      _blocked = null; _slotError = null; _slotId = null; _slotLabel = null;
    });
    final savedId = widget.current.type == 'scheduled' ? widget.current.deliverySlotId : null;
    try {
      final res = await _api.getDeliverySlots(context, _fmt(date), 'delivery');
      if (!mounted) return;
      setState(() {
        _loadingSlots = false;
        if (res.blocked) { _blocked = res.reason ?? 'Not available on this date'; return; }
        if (res.error != null) { _slotError = res.error; return; }
        _slots = res.slots;
        _slotCount = res.slots.where((s) => s.available).length;
        if (savedId != null && widget.current.deliveryDate == _fmt(date)) {
          final match = _slots.where((s) => s.id == savedId).toList();
          if (match.isNotEmpty) { _slotId = savedId; _slotLabel = match.first.label; }
        }
      });
    } catch (_) {
      if (mounted) setState(() { _loadingSlots = false; _slotError = 'Failed to load slots'; });
    }
  }

  bool get _canConfirm => _mode == 'instant' || _slotId != null;

  void _confirm() {
    if (_mode == 'instant') {
      Navigator.pop(context, const FulfillmentSelection(type: 'standard'));
      return;
    }
    if (_slotId == null) return;
    Navigator.pop(context, FulfillmentSelection(
      type: 'scheduled',
      deliveryDate: _fmt(_dates[_dateIndex]),
      deliverySlotId: _slotId,
      deliverySlotLabel: _slotLabel,
      deliveryInstructions: _instrCtrl.text.trim().isEmpty ? null : _instrCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Container(
      margin: EdgeInsets.only(top: media.size.height * 0.12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        _SheetHeader(
          title: 'Delivery',
          onClose: () => Navigator.pop(context),
        ),

        // ── Zepto-style toggle tiles ─────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            _DeliveryOptionTile(
              icon: Icons.flash_on_rounded,
              label: 'Instant Delivery',
              sub: 'Deliver any time',
              active: _mode == 'instant',
              onTap: () => _switchMode('instant'),
            ),
            const SizedBox(width: 10),
            _DeliveryOptionTile(
              icon: Icons.event_available_rounded,
              label: 'Schedule',
              sub: 'Select a slot',
              active: _mode == 'schedule',
              onTap: () => _switchMode('schedule'),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: _mode == 'instant'
                ? _InstantContent()
                : Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _DateStrip(
                        dates: _dates,
                        selectedIndex: _dateIndex,
                        slotCount: _slotCount,
                        accent: AppColors.primary,
                        onSelect: (i) {
                          setState(() { _dateIndex = i; _slotId = null; _slotLabel = null; });
                          _loadSlots(_dates[i]);
                        },
                      ),
                      const SizedBox(height: 16),
                      _SlotSection(
                        slots: _slots,
                        loading: _loadingSlots,
                        blocked: _blocked,
                        error: _slotError,
                        selectedId: _slotId,
                        accent: AppColors.primary,
                        onSelect: (slot) => setState(() {
                          _slotId = _slotId == slot.id ? null : slot.id;
                          _slotLabel = _slotId != null ? slot.label : null;
                        }),
                      ),
                      if (widget.config.deliveryInstructionsEnabled && _slotId != null) ...[
                        const SizedBox(height: 20),
                        Text('Delivery instructions',
                            style: FontUtils.primaryFontStyle(
                                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _instrCtrl,
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () => FocusScope.of(context).unfocus(),
                          style: FontUtils.primaryFontStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'e.g. Leave at the gate...',
                            hintStyle: FontUtils.primaryFontStyle(fontSize: 12, color: Colors.grey.shade400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            filled: true, fillColor: const Color(0xFFF8F8F8),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)),
                          ),
                        ),
                      ],
                    ]),
                  ),
          ),
        ),

        _BottomBar(
          label: _mode == 'instant'
              ? 'Confirm — Instant Delivery'
              : (_slotId != null ? 'Confirm Schedule' : 'Pick a time slot'),
          accent: AppColors.primary,
          enabled: _canConfirm,
          onTap: _canConfirm ? _confirm : null,
        ),
      ]),
        ),
      ),
    );
  }
}

// Two-option Zepto-style tile inside the delivery sheet
class _DeliveryOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool active;
  final VoidCallback onTap;
  const _DeliveryOptionTile({
    required this.icon, required this.label, required this.sub,
    required this.active, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.primary : Colors.grey.shade200,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label,
                      maxLines: 1, softWrap: false,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: active ? AppColors.primary : const Color(0xFF1A1A1A))),
                ),
                const SizedBox(height: 2),
                Text(sub,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 11,
                        color: active ? AppColors.primary.withValues(alpha: 0.65) : Colors.grey.shade500)),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 20, color: active ? AppColors.primary : Colors.grey.shade400),
          ]),
        ),
      ),
    );
  }
}

// Instant delivery content — shown when mode is 'instant'
class _InstantContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.local_shipping_outlined, size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Instant Delivery',
                style: FontUtils.primaryFontStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            Text("We'll deliver as soon as possible — no specific time needed.",
                style: FontUtils.primaryFontStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pickup sheet — date/slot picker only (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _PickupSheet extends StatefulWidget {
  final DeliveryConfig config;
  final FulfillmentSelection current;
  const _PickupSheet({required this.config, required this.current});

  @override
  State<_PickupSheet> createState() => _PickupSheetState();
}

class _PickupSheetState extends State<_PickupSheet> {
  final _api = ApiService();
  late List<DateTime> _dates;
  late int _dateIndex;
  List<DeliverySlot> _slots = [];
  bool _loadingSlots = false;
  int? _slotCount;
  String? _blocked;
  String? _slotError;
  String? _slotId;
  String? _slotLabel;
  bool _anyTime = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final cap = widget.config.maxDaysAdvance.clamp(1, 7);
    _dates = List.generate(cap, (i) => DateTime(now.year, now.month, now.day + i));

    final saved = widget.current.pickupDate;
    _dateIndex = 0;
    if (saved != null) {
      final idx = _dates.indexWhere((d) => _fmt(d) == saved);
      if (idx >= 0) _dateIndex = idx;
    }
    _anyTime = widget.current.type == 'pickup' && widget.current.pickupAnyTime;
    _loadSlots(_dates[_dateIndex]);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadSlots(DateTime date) async {
    setState(() { _loadingSlots = true; _slots = []; _slotCount = null; _blocked = null; _slotError = null; });
    final savedId = widget.current.type == 'pickup' ? widget.current.pickupSlotId : null;
    try {
      final res = await _api.getDeliverySlots(context, _fmt(date), 'pickup');
      if (!mounted) return;
      setState(() {
        _loadingSlots = false;
        if (res.blocked) { _blocked = res.reason ?? 'Not available on this date'; return; }
        if (res.error != null) { _slotError = res.error; return; }
        _slots = res.slots;
        _slotCount = res.slots.where((s) => s.available).length;
        if (savedId != null && widget.current.pickupDate == _fmt(date)) {
          final match = _slots.where((s) => s.id == savedId).toList();
          if (match.isNotEmpty) { _slotId = savedId; _slotLabel = match.first.label; }
        }
      });
    } catch (_) {
      if (mounted) setState(() { _loadingSlots = false; _slotError = 'Failed to load slots'; });
    }
  }

  bool get _canConfirm => _anyTime || _slotId != null;

  void _confirm() {
    Navigator.pop(context, FulfillmentSelection(
      type: 'pickup',
      pickupDate: _fmt(_dates[_dateIndex]),
      pickupSlotId: _anyTime ? null : _slotId,
      pickupSlotLabel: _anyTime ? 'Any time' : _slotLabel,
      pickupAnyTime: _anyTime,
      pickupAddress: widget.config.pickupAddress.isNotEmpty ? widget.config.pickupAddress : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    final cfg = widget.config;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        _SheetHeader(title: 'Book Pickup', onClose: () => Navigator.pop(context)),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 90),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info banner
              if (cfg.pickupInstructions.isNotEmpty)
                _InfoBanner(message: cfg.pickupInstructions, color: Colors.amber),
              // Address
              if (cfg.pickupAddress.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Expanded(child: Text(cfg.pickupAddress,
                        style: FontUtils.primaryFontStyle(fontSize: 12, color: Colors.grey.shade600))),
                  ]),
                ),

              // Date strip
              _DateStrip(
                dates: _dates,
                selectedIndex: _dateIndex,
                slotCount: _slotCount,
                accent: Colors.orange.shade600,
                onSelect: (i) {
                  setState(() { _dateIndex = i; _anyTime = false; _slotId = null; });
                  _loadSlots(_dates[i]);
                },
              ),

              const SizedBox(height: 16),

              // Any time
              if (cfg.pickupAnyTimeEnabled)
                _AnyTimeRow(
                  value: _anyTime,
                  accent: Colors.orange.shade600,
                  onToggle: () => setState(() { _anyTime = !_anyTime; _slotId = null; _slotLabel = null; }),
                ),

              // Slots
              if (!_anyTime) ...[
                const SizedBox(height: 8),
                _SlotSection(
                  slots: _slots,
                  loading: _loadingSlots,
                  blocked: _blocked,
                  error: _slotError,
                  selectedId: _slotId,
                  accent: Colors.orange.shade600,
                  onSelect: (slot) => setState(() {
                    _slotId = _slotId == slot.id ? null : slot.id;
                    _slotLabel = _slotId != null ? slot.label : null;
                  }),
                ),
              ],
            ]),
          ),
        ),

        _BottomBar(
          label: 'Confirm Pickup',
          accent: Colors.orange.shade600,
          enabled: _canConfirm,
          onTap: _canConfirm ? _confirm : null,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _SheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(children: [
            Expanded(child: Text(title,
                style: FontUtils.secondaryFontStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)))),
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, size: 17, color: Colors.grey.shade600),
              ),
            ),
          ]),
        ),
        Divider(color: Colors.grey.shade100, height: 1),
      ]),
    );
  }
}

class _DateStrip extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final int? slotCount;
  final Color accent;
  final void Function(int) onSelect;
  const _DateStrip({required this.dates, required this.selectedIndex, required this.slotCount,
      required this.accent, required this.onSelect});

  String _label(int i, DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d.isAtSameMomentAs(today)) return 'Today';
    if (d.isAtSameMomentAs(today.add(const Duration(days: 1)))) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(dates.length, (i) {
            final sel = i == selectedIndex;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: EdgeInsets.only(right: i < dates.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? accent.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: sel ? accent : Colors.grey.shade300,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(_label(i, dates[i]),
                    style: FontUtils.primaryFontStyle(
                        fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? accent : Colors.grey.shade600)),
              ),
            );
          }),
        ),
      ),
      if (slotCount != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            slotCount! > 0 ? '$slotCount ${slotCount == 1 ? 'slot' : 'slots'} available' : 'No slots available',
            style: FontUtils.primaryFontStyle(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: slotCount! > 0 ? Colors.green.shade600 : Colors.red.shade400),
          ),
        ),
    ]);
  }
}

// Format slot start/end (HH:mm) into a clean hour-only label:
//   09:00–10:00 → "9 - 10 AM"
//   11:00–13:00 → "11 AM - 1 PM"
//   minutes shown only when non-zero (e.g. "9:30 - 10:30 AM")
String _formatSlot(DeliverySlot s) {
  final st = s.startTime.split(':');
  final et = s.endTime.split(':');
  if (st.length < 2 || et.length < 2) return s.label;
  final sH = int.tryParse(st[0]);
  final sM = int.tryParse(st[1]);
  final eH = int.tryParse(et[0]);
  final eM = int.tryParse(et[1]);
  if (sH == null || sM == null || eH == null || eM == null) return s.label;

  String fmt(int hour, int minute, bool withSuffix) {
    final isPm = hour >= 12;
    final h12 = (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour);
    final mm = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
    final suf = withSuffix ? (isPm ? ' PM' : ' AM') : '';
    return '$h12$mm$suf';
  }

  final sameMeridiem = (sH < 12) == (eH < 12);
  if (sameMeridiem) {
    return '${fmt(sH, sM, false)} - ${fmt(eH, eM, true)}';
  }
  return '${fmt(sH, sM, true)} - ${fmt(eH, eM, true)}';
}

class _SlotSection extends StatelessWidget {
  final List<DeliverySlot> slots;
  final bool loading;
  final String? blocked;
  final String? error;
  final String? selectedId;
  final Color accent;
  final void Function(DeliverySlot) onSelect;
  const _SlotSection({required this.slots, required this.loading, required this.blocked,
      required this.error, required this.selectedId, required this.accent, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (blocked != null) return _InfoBanner(message: blocked!, color: Colors.red);
    if (error != null) return _InfoBanner(message: error!, color: Colors.grey);
    if (loading) return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3, childAspectRatio: 2.0, mainAxisSpacing: 10, crossAxisSpacing: 10,
      children: List.generate(6, (_) => Container(
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      )),
    );
    if (slots.isEmpty) return _InfoBanner(message: 'No slots available. Try another date.', color: Colors.grey);
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3, childAspectRatio: 2.4, mainAxisSpacing: 10, crossAxisSpacing: 10,
      children: slots.map((slot) {
        final sel = selectedId == slot.id;
        return GestureDetector(
          onTap: slot.available ? () => onSelect(slot) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: !slot.available
                  ? Colors.grey.shade50
                  : sel ? accent.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: !slot.available ? Colors.grey.shade200 : sel ? accent : Colors.grey.shade200,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Stack(alignment: Alignment.center, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(_formatSlot(slot),
                    textAlign: TextAlign.center, maxLines: 1, softWrap: false,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: !slot.available ? Colors.grey.shade400 : sel ? accent : const Color(0xFF2A2A2A))),
              ),
              if (!slot.available)
                Positioned(top: 3, right: 4,
                    child: Text('Full', style: FontUtils.primaryFontStyle(fontSize: 9, color: Colors.grey.shade400))),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _AnyTimeRow extends StatelessWidget {
  final bool value;
  final Color accent;
  final VoidCallback onToggle;
  const _AnyTimeRow({required this.value, required this.accent, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? accent.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? accent.withValues(alpha: 0.35) : Colors.grey.shade200, width: value ? 1.5 : 1),
        ),
        child: Row(children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(
              value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              key: ValueKey(value), size: 20,
              color: value ? accent : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 10),
          Text('Any time during business hours',
              style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                  color: value ? accent : const Color(0xFF333333))),
        ]),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  final MaterialColor color;
  const _InfoBanner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 14, color: color.shade500),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: FontUtils.primaryFontStyle(fontSize: 12, color: color.shade800))),
      ]),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final Color accent;
  final bool enabled;
  final VoidCallback? onTap;
  const _BottomBar({required this.label, required this.accent, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: enabled ? accent : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : Colors.grey.shade400)),
        ),
      ),
    );
  }
}
