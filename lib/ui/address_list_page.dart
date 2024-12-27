import 'package:flutter/material.dart';
import 'package:waioz/ui/add_address_page.dart';
import 'package:waioz/ui/widgets/address_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_strings.dart';

import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.my_address,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16.0),
                children: [
                  AddressCard(
                    title: 'Home',
                    address:
                        '2715 Ash Dr. San Jose, South Dakota\nJose, South 83475',
                    icon: Icons.home,
                    onDelete: () {

                    },
                    onEdit: () {

                    },
                  ),
                  AddressCard(
                    title: 'Work',
                    address:
                        '2715 Ash Dr. San Jose, South Dakota\nJose, South 83475',
                    icon: Icons.work,
                    onDelete: () {

                    },
                    onEdit: () {

                    },
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    PageRouteUtils.push(context, AddAddressPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize:
                        const Size(double.infinity, 52), // Full-width button
                  ),
                  child: Text(
                    AppStrings.add_address,
                    style: FontUtils.circularStdStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
