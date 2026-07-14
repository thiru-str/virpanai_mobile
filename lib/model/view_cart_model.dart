// Event class

import 'package:event_bus/event_bus.dart';
import 'package:waioz/model/register_response.dart';

final EventBus eventBus = EventBus();

class ViewCartModel {
  final int? totalItems;
  final List<String>? itemImages;
  final Map<String, int> variantQtyMap;
  final Map<String, int> unitLineQtyMap;
  final Map<String, String> unitLineIdMap;

  ViewCartModel(
    this.totalItems,
    this.itemImages, [
    this.variantQtyMap = const {},
    this.unitLineQtyMap = const {},
    this.unitLineIdMap = const {},
  ]);
}

class TabSwitchEvent {
  final int tabIndex;
  TabSwitchEvent(this.tabIndex);
}

class ProfileEvent {
  final Customer? customer;
  ProfileEvent(this.customer);
}
