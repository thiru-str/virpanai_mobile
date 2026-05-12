class DeliveryConfig {
  final bool scheduledDeliveryEnabled;
  final bool pickupEnabled;
  final int pickupBufferHours;
  final bool pickupAnyTimeEnabled;
  final String pickupAddress;
  final String pickupInstructions;
  final int maxDaysAdvance;
  final bool deliveryInstructionsEnabled;

  const DeliveryConfig({
    this.scheduledDeliveryEnabled = true,
    this.pickupEnabled = false,
    this.pickupBufferHours = 2,
    this.pickupAnyTimeEnabled = false,
    this.pickupAddress = '',
    this.pickupInstructions = '',
    this.maxDaysAdvance = 30,
    this.deliveryInstructionsEnabled = false,
  });

  factory DeliveryConfig.fromJson(Map<String, dynamic> json) => DeliveryConfig(
        scheduledDeliveryEnabled: json['scheduled_delivery_enabled'] ?? true,
        pickupEnabled: json['pickup_enabled'] ?? false,
        pickupBufferHours: json['pickup_buffer_hours'] ?? 2,
        pickupAnyTimeEnabled: json['pickup_any_time_enabled'] ?? false,
        pickupAddress: json['pickup_address'] ?? '',
        pickupInstructions: json['pickup_instructions'] ?? '',
        maxDaysAdvance: json['max_days_advance'] ?? 30,
        deliveryInstructionsEnabled: json['delivery_instructions_enabled'] ?? false,
      );
}

class DeliverySlot {
  final String id;
  final String label;
  final String startTime;
  final String endTime;
  final bool available;

  const DeliverySlot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) => DeliverySlot(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        startTime: json['start_time'] ?? '',
        endTime: json['end_time'] ?? '',
        available: json['available'] ?? true,
      );
}

class DeliverySlotsResponse {
  final String? date;
  final List<DeliverySlot> slots;
  final bool blocked;
  final String? reason;
  final String? error;
  final int? maxDaysAdvance;
  final bool pickupAnyTimeEnabled;

  const DeliverySlotsResponse({
    this.date,
    this.slots = const [],
    this.blocked = false,
    this.reason,
    this.error,
    this.maxDaysAdvance,
    this.pickupAnyTimeEnabled = false,
  });

  factory DeliverySlotsResponse.fromJson(Map<String, dynamic> json) =>
      DeliverySlotsResponse(
        date: json['date'],
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((e) => DeliverySlot.fromJson(e as Map<String, dynamic>))
            .toList(),
        blocked: json['blocked'] ?? false,
        reason: json['reason'],
        error: json['error'],
        maxDaysAdvance: json['settings']?['max_days_advance'],
        pickupAnyTimeEnabled: json['settings']?['pickup_any_time_enabled'] ?? false,
      );
}

// What gets saved to cart metadata
class FulfillmentSelection {
  final String type; // "standard" | "scheduled" | "pickup"

  // scheduled
  final String? deliveryDate;
  final String? deliverySlotId;
  final String? deliverySlotLabel;
  final String? deliveryInstructions;

  // pickup
  final String? pickupDate;
  final String? pickupSlotId;
  final String? pickupSlotLabel;
  final bool pickupAnyTime;
  final String? pickupAddress;

  const FulfillmentSelection({
    required this.type,
    this.deliveryDate,
    this.deliverySlotId,
    this.deliverySlotLabel,
    this.deliveryInstructions,
    this.pickupDate,
    this.pickupSlotId,
    this.pickupSlotLabel,
    this.pickupAnyTime = false,
    this.pickupAddress,
  });

  Map<String, dynamic> toMetadata() {
    final m = <String, dynamic>{'fulfillment_type': type};
    if (type == 'scheduled') {
      m['delivery_date'] = deliveryDate;
      m['delivery_time_slot_id'] = deliverySlotId;
      m['delivery_time_slot_label'] = deliverySlotLabel;
      if (deliveryInstructions?.isNotEmpty == true) {
        m['delivery_instructions'] = deliveryInstructions;
      }
    } else if (type == 'pickup') {
      m['pickup_date'] = pickupDate;
      m['pickup_slot_id'] = pickupAnyTime ? null : pickupSlotId;
      m['pickup_slot_label'] = pickupAnyTime ? 'Any time' : pickupSlotLabel;
      m['pickup_any_time'] = pickupAnyTime;
      if (pickupAddress?.isNotEmpty == true) {
        m['pickup_address'] = pickupAddress;
      }
    }
    return m;
  }
}
