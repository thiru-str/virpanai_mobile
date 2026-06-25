class DeliveryTimeSlot {
  final String id;
  final String label;
  final String startTime;
  final String endTime;
  final bool available;

  DeliveryTimeSlot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  factory DeliveryTimeSlot.fromJson(Map<String, dynamic> json) =>
      DeliveryTimeSlot(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        startTime: json['start_time']?.toString() ?? '',
        endTime: json['end_time']?.toString() ?? '',
        available: json['available'] != false,
      );
}

int _deliverySlotStartMinutes(DeliveryTimeSlot slot) {
  final parts = slot.startTime.split(':');
  final hours = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  final minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return hours * 60 + minutes;
}

class DeliveryScheduleSettings {
  final bool scheduledDeliveryEnabled;
  final double leadTimeHours;
  final int maxDaysAdvance;
  final bool deliveryInstructionsEnabled;

  DeliveryScheduleSettings({
    this.scheduledDeliveryEnabled = false,
    this.leadTimeHours = 0,
    this.maxDaysAdvance = 7,
    this.deliveryInstructionsEnabled = false,
  });

  factory DeliveryScheduleSettings.fromJson(Map<String, dynamic>? json) =>
      DeliveryScheduleSettings(
        scheduledDeliveryEnabled:
            json?['scheduled_delivery_enabled'] == true ||
                json?['scheduled_delivery_enabled'] == 'true',
        leadTimeHours:
            double.tryParse('${json?['lead_time_hours'] ?? 0}') ?? 0,
        maxDaysAdvance: int.tryParse('${json?['max_days_advance'] ?? 7}') ?? 7,
        deliveryInstructionsEnabled:
            json?['delivery_instructions_enabled'] == true ||
                json?['delivery_instructions_enabled'] == 'true',
      );
}

class DeliveryScheduleResponse {
  final String? date;
  final List<DeliveryTimeSlot> slots;
  final bool blocked;
  final String? reason;
  final String? error;
  final DeliveryScheduleSettings settings;

  DeliveryScheduleResponse({
    this.date,
    this.slots = const [],
    this.blocked = false,
    this.reason,
    this.error,
    DeliveryScheduleSettings? settings,
  }) : settings = settings ?? DeliveryScheduleSettings();

  factory DeliveryScheduleResponse.fromJson(Map<String, dynamic> json) {
    final slots = (json['slots'] as List? ?? [])
        .whereType<Map>()
        .map((m) => DeliveryTimeSlot.fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) =>
          _deliverySlotStartMinutes(a).compareTo(_deliverySlotStartMinutes(b)));

    return DeliveryScheduleResponse(
        date: json['date']?.toString(),
        slots: slots,
        blocked: json['blocked'] == true,
        reason: json['reason']?.toString(),
        error: json['error']?.toString(),
        settings: DeliveryScheduleSettings.fromJson(
          json['settings'] is Map
              ? Map<String, dynamic>.from(json['settings'])
              : null,
        ),
      );
  }
}

class DeliveryScheduleSelection {
  final String mode;
  final String? date;
  final DeliveryTimeSlot? slot;
  final String? instructions;

  DeliveryScheduleSelection({
    required this.mode,
    this.date,
    this.slot,
    this.instructions,
  });

  bool get isScheduled => mode == 'scheduled' && date != null;
  String get slotLabel => slot?.label ?? '';

  Map<String, dynamic> toPayload() => {
        'delivery_mode': isScheduled ? 'scheduled' : 'instant',
        if (isScheduled) 'delivery_date': date,
        if (isScheduled && slot != null) 'delivery_time_slot_id': slot!.id,
        if (isScheduled && slot != null) 'delivery_time_slot_label': slot!.label,
        if (isScheduled && instructions != null && instructions!.isNotEmpty)
          'delivery_instructions': instructions,
      };
}
