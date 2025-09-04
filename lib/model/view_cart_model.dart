// Event class

import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class ViewCartModel {
  final int? totalItems;
  final List<String>? itemImages;
  final Map<String, int> variantQtyMap; // NEW

  ViewCartModel(this.totalItems, this.itemImages, [this.variantQtyMap = const {}]);
}
