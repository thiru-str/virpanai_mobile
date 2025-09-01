// Event class

import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class ViewCartModel {
  final int totalItems;
  final List<String> itemImages;

  ViewCartModel(this.totalItems,this.itemImages);
}

class ReloadEvent {
  final bool reload;
  ReloadEvent(this.reload);
}
