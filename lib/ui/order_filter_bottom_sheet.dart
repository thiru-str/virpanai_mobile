import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:waioz/utility/app_colors.dart';

import '../model/order_filter_result.dart';

const Map<String, String> kDisplayToApi = {
  'Processing': 'fulfilled',
  'Delivered':  'delivered',
  'Shipped':  'shipped',
};

const List<String> kDisplayOrder = ['Processing', 'Delivered','Shipped'];

String? displayFromApi(String api) {
  for (final e in kDisplayToApi.entries) {
    if (e.value == api) return e.key;
  }
  return null;
}

Future<OrdersFilterResult?> showOrdersFilterSheet(
    BuildContext context, {
      bool showDate = true,
      bool showStatus = true,
      bool singleDateSelection = false,
      DateTime? initialStart,
      DateTime? initialEnd,
      String? initialStatus,
      List<String> allStatuses = const [
        'Processing',
        'Delivered',
        'Shipped',
      ],
    }) {
  assert(showDate || showStatus,
  'At least one of showDate or showStatus must be true.');

  return showModalBottomSheet<OrdersFilterResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _OrdersFilterSheet(
      showDate: showDate,
      showStatus: showStatus,
      singleDateSelection: singleDateSelection,
      initialStart: initialStart,
      initialEnd: initialEnd,
      initialStatus: initialStatus,
      allStatuses: allStatuses,
    ),
  );
}

class _OrdersFilterSheet extends StatefulWidget {
  final bool showDate;
  final bool showStatus;
  final bool singleDateSelection;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final String? initialStatus;
  final List<String> allStatuses;

  const _OrdersFilterSheet({
    required this.showDate,
    required this.showStatus,
    required this.singleDateSelection,
    this.initialStart,
    this.initialEnd,
    this.initialStatus,
    required this.allStatuses,
  });

  @override
  State<_OrdersFilterSheet> createState() => _OrdersFilterSheetState();
}

class _OrdersFilterSheetState extends State<_OrdersFilterSheet> {
  // Date state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;      // for single mode
  DateTime? _rangeStart;       // for range mode
  DateTime? _rangeEnd;         // for range mode
  RangeSelectionMode _rangeMode = RangeSelectionMode.toggledOff;

  String? _selectedDisplayStatus;

  @override
  void initState() {
    super.initState();

    // dates (unchanged)
    if (widget.singleDateSelection) {
      _selectedDay = widget.initialStart ?? DateTime.now();
      _focusedDay = _selectedDay!;
    } else {
      _rangeStart = widget.initialStart;
      _rangeEnd = widget.initialEnd ?? widget.initialStart;
      _focusedDay = widget.initialStart ?? widget.initialEnd ?? DateTime.now();
      _rangeMode = RangeSelectionMode.toggledOn;
    }

    // statuses: initialStatuses are API values -> convert to display labels
    _selectedDisplayStatus =
    widget.initialStatus != null
        ? displayFromApi(widget.initialStatus!)
        : null;

  }



  void _reset() {
    setState(() {
      _selectedDay = null;
      _rangeStart = null;
      _rangeEnd = null;
      _selectedDisplayStatus =
      widget.initialStatus != null
          ? displayFromApi(widget.initialStatus!)
          : null;
    });
  }

  // Normalize to start of day local, then convert to UTC (00:00 & 23:59:59.999)
  DateTime _startUtc(DateTime d) =>
      DateTime(d.year, d.month, d.day).toUtc();

  DateTime _endUtc(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).toUtc();

  void _apply() {
    DateTime? startUtc;
    DateTime? endUtc;

    if (widget.showDate) {
      if (widget.singleDateSelection) {
        if (_selectedDay != null) {
          startUtc = _startUtc(_selectedDay!);
          endUtc = _endUtc(_selectedDay!);
        }
      } else {
        if (_rangeStart != null && _rangeEnd != null) {
          startUtc = _startUtc(_rangeStart!);
          endUtc = _endUtc(_rangeEnd!);
        } else if (_rangeStart != null && _rangeEnd == null) {
          // user picked only one date in range mode → treat as single
          startUtc = _startUtc(_rangeStart!);
          endUtc = _endUtc(_rangeStart!);
        }
      }
    }

    Navigator.pop(
      context,
      OrdersFilterResult(
        startUtc: startUtc,
        endUtc: endUtc,
        status: _selectedDisplayStatus != null
            ? kDisplayToApi[_selectedDisplayStatus!]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel',style: TextStyle(color: AppColors.primary),)),
                const Spacer(),
                const Text('Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(onPressed: _apply, child: Text('Apply',style: TextStyle(color: AppColors.primary),)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showStatus) ...[
                    Text('Order Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: kDisplayOrder.map((display) {
                        final selected = _selectedDisplayStatus == display;

                        return ChoiceChip(
                          label: Text(display),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedDisplayStatus = display;
                            });
                          },
                          selectedColor: const Color(0xFF0B8F79),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: const Color(0xFFEDEDED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.showDate) ...[
                    const SizedBox(height: 8),
                    Text('Select Date', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildCalendarCard(theme),
                    const SizedBox(height: 24),
                  ],

                  Center(
                    child: TextButton(
                      onPressed: _reset,
                      child: const Text('Reset filter', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: _focusedDay,
        headerStyle: const HeaderStyle(
          titleCentered: false,
          formatButtonVisible: false,
          leftChevronVisible: true,
          rightChevronVisible: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        calendarStyle: const CalendarStyle(
          isTodayHighlighted: false,
          rangeHighlightColor: Color(0x220B8F79),
          rangeStartDecoration: BoxDecoration(color: Color(0xFF0B8F79), shape: BoxShape.circle),
          rangeEndDecoration: BoxDecoration(color: Color(0xFF0B8F79), shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Color(0xFF0B8F79), shape: BoxShape.circle),
          withinRangeDecoration: BoxDecoration(color: Color(0x220B8F79), shape: BoxShape.circle),
        ),
        availableGestures: AvailableGestures.horizontalSwipe,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        // Selection modes
        selectedDayPredicate: (day) =>
        widget.singleDateSelection && _selectedDay != null
            ? isSameDay(_selectedDay, day)
            : false,
        rangeSelectionMode: widget.singleDateSelection
            ? RangeSelectionMode.toggledOff
            : _rangeMode,
        rangeStartDay: widget.singleDateSelection ? null : _rangeStart,
        rangeEndDay: widget.singleDateSelection ? null : _rangeEnd,
        onRangeSelected: (start, end, focusedDay) {
          if (widget.singleDateSelection) return;
          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = focusedDay;
            _rangeMode = RangeSelectionMode.toggledOn; // keep it on
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
