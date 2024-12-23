import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/login_response_model.dart';
import 'package:waioz/ui/expense_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/AppColors.dart';

import '../utility/shared_preferences_util.dart';
import 'SettingsPage.dart';
import 'cash_section_page.dart';
import 'orders_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? globalUserId;
  int selectedIndex = 1;
  Data? userData;

  final List<Widget> pages = [
    ExpensePage(),
    const CashSectionPage(),
    OrderPage(),
    SettingsPage(),
    MessagesPage(),
    LogoutPage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreferenceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          // Match this color with your sidebar color
          elevation: 0,
          // Optional: to remove shadow
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SvgPicture.asset(
                      'images/storees_logo.svg',
                      // Replace with your logo asset path
                      width: 40,
                      height: 30,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(userData?.employeeName?? "",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    // Replace with profile background color
                    radius: 20,
                  ),
                ],
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Divider(
                color: AppColors.divider, // Color of the divider
                thickness: 1, // Thickness of the divider
                height: 1, // Height of the divider
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top icons
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SidebarIcon(
                      iconWidget: SvgPicture.asset('images/expense_icon.svg',
                          // Replace with your logo asset path
                          width: 40,
                          height: 30,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == 0 ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          )),
                      isSelected: selectedIndex == 0,
                      onTap: () => setState(() => selectedIndex = 0),
                    ),
                    SidebarIcon(
                      iconWidget: SvgPicture.asset(
                        'images/cash_flow_icon.svg',
                        // Replace with your logo asset path
                        width: 40,
                        height: 30,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == 1 ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          )
                      ),
                      isSelected: selectedIndex == 1,
                      onTap: () => setState(() => selectedIndex = 1),
                    ),
                    SidebarIcon(
                      iconWidget: SvgPicture.asset(
                        'images/order_icon.svg',
                        // Replace with your logo asset path
                        width: 40,
                        height: 30,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == 2 ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          )
                      ),
                      isSelected: selectedIndex == 2,
                      onTap: () => setState(() => selectedIndex = 2),
                    ),
                  ],
                ),
                // Bottom icons
                Column(
                  children: [
                    SidebarIcon(
                      iconWidget: SvgPicture.asset(
                        'images/settings_icon.svg',
                        // Replace with your logo asset path
                        width: 40,
                        height: 30,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == 3 ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          )
                      ),
                      isSelected: selectedIndex == 3,
                      onTap: () => setState(() => selectedIndex = 3),
                    ),
                    SidebarIcon(
                      iconWidget: SvgPicture.asset(
                        'images/message_icon.svg',
                        // Replace with your logo asset path
                        width: 40,
                        height: 30,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == 4 ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          )
                      ),
                      isSelected: selectedIndex == 4,
                      onTap: () => setState(() => selectedIndex = 4),
                    ),
                    SidebarIcon(
                      iconWidget: SvgPicture.asset(
                        'images/logout_icon.svg',
                        // Replace with your logo asset path
                        width: 40,
                        height: 30,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == 5 ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          )
                      ),
                      isSelected: selectedIndex == 5,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => WelcomePage()),
                              (route) => false, // Removes all routes until the HomePage
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
          // Main content area with elevation effect
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }

  void getPreferenceDetails() async{
    userData = await getLoginResponse();
    globalUserId = userData?.id;
    setState(() {
      userData;
    });
  }

  Future<Data?> getLoginResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('user_data');
    if (userData != null) {
      return Data.fromJson(userData);
    }
    return null;
  }

}

class SidebarIcon extends StatelessWidget {
  final Widget iconWidget; // Changed from IconData to Widget
  final bool isSelected;
  final VoidCallback onTap;

  SidebarIcon(
      {required this.iconWidget,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.primary : Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 8), // Space between items
        padding: const EdgeInsets.all(8.0),
        child: iconWidget, // Use iconWidget here
      ),
    );
  }
}



class TargetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey, child: const Center(child: Text("Target Page")));
  }
}

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Reports Page"));
  }
}


class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Messages Page"));
  }
}

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Logout Page"));
  }
}
