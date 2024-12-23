import 'package:flutter/material.dart';
import 'package:waioz/utility/AppColors.dart';

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information Section
            Container(
              height: 300,
              width: 250,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    /*backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Placeholder image URL*/
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Lina Punk Manado",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Punk@Gmail.Com"),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save Changes action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text("65 orders"),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 32),

            // Tab Section
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(text: "Personal Information"),
                      Tab(text: "Change Password"),
                      Tab(text: "Analytics"),
                    ],
                  ),
                  SizedBox(height: 16),

                  // TabBarView content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PersonalInfoTab(),
                        ChangePasswordTab(),
                        AnalyticsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalInfoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextFieldRow("Full name", "Lina Punk", "Last name", "Manado"),
          buildTextFieldRow("Email address", "Punk@Gmail.Com", "Gender", "", isGender: true),
          buildTextFieldRow("Phone number", "+91 96845 25136", "Date Of Birth", "14/11/2024"),
          buildTextFieldRow("Location", "Tamil Nadu", "Pincode", "625001"),
          SizedBox(height: 24),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () {
                // Save Changes action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Save Changes"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFieldRow(String label1, String text1, String label2, String text2, {bool isGender = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Left Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: text1,
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineColorBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineColorBorder),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineColorBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),

          // Right Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                if (isGender)
                  Row(
                    children: [
                      Radio(value: "Male", groupValue: "Male", onChanged: (value) {},activeColor: AppColors.primary,),
                      Text("Male"),
                      SizedBox(width: 16),
                      Radio(value: "Female", groupValue: "Male", onChanged: (value) {},activeColor: AppColors.primary,),
                      Text("Female"),
                    ],
                  )
                else
                  TextField(
                    enabled: true,
                    decoration: InputDecoration(
                      hintText: text2,
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineColorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineColorBorder),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineColorBorder),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class ChangePasswordTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextFieldRow("New Password", "*******", "Change Password", "*******"),
          SizedBox(height: 24),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () {
                // Save Changes action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFieldRow(String label1, String text1, String label2, String text2, {bool isGender = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Left Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: text1,
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineColorBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineColorBorder),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineColorBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),

          // Right Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                if (isGender)
                  Row(
                    children: [
                      Radio(value: "Male", groupValue: "Male", onChanged: (value) {},activeColor: AppColors.primary,),
                      Text("Male"),
                      SizedBox(width: 16),
                      Radio(value: "Female", groupValue: "Male", onChanged: (value) {},activeColor: AppColors.primary,),
                      Text("Female"),
                    ],
                  )
                else
                  TextField(
                    enabled: true,
                    decoration: InputDecoration(
                      hintText: text1,
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineColorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineColorBorder),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineColorBorder),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Analytics Page"),
    );
  }
}

