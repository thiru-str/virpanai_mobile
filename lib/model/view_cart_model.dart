// Event class

import 'package:event_bus/event_bus.dart';
import 'package:waioz/model/register_response.dart';

final EventBus eventBus = EventBus();

class ViewCartModel {
  final int totalItems;
  final List<String> itemImages;

  ViewCartModel(this.totalItems,this.itemImages);
}

class TabSwitchEvent {
  final int tabIndex;
  TabSwitchEvent(this.tabIndex);
}

class ProfileEvent {
  final Customer? customer;
  ProfileEvent(this.customer);
}
