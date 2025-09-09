// Event class

import 'package:event_bus/event_bus.dart';
import 'package:waioz/model/register_response.dart';

final EventBus eventBus = EventBus();

class ViewCartModel {
  final int? totalItems;
  final List<String>? itemImages;
  final Map<String, int> variantQtyMap; // NEW

  ViewCartModel(this.totalItems, this.itemImages, [this.variantQtyMap = const {}]);
}

class TabSwitchEvent {
  final int tabIndex;
  TabSwitchEvent(this.tabIndex);
}

class ReloadEvent {
  final bool reload;
  ReloadEvent(this.reload);
}

class ProfileEvent {
  final Customer? customer;
  ProfileEvent(this.customer);
}
