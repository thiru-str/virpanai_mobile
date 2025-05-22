// Event class

import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class ViewCartEvent {
  final int totalItems;
  final List<String> itemImages;

  ViewCartEvent(this.totalItems,this.itemImages);
}

class TabSwitchEvent {
  final int tabIndex;
  TabSwitchEvent(this.tabIndex);
}
