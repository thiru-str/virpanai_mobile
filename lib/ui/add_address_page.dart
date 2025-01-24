import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/address_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';

import '../utility/app_colors.dart';
import '../utility/font_utils.dart';

class AddAddressPage extends StatefulWidget {
  final Address? selectedAddress; // Optional Address parameter

  const AddAddressPage({super.key, this.selectedAddress});

  @override
  State<AddAddressPage> createState() => _AddAddressPage();
}

class _AddAddressPage extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController otherAddressName = TextEditingController();

  String selectedLocation = AppStrings.home; // Default location selection
  bool apiCalling = true;
  RegisterResponse? registerResponse;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedAddress != null) {
      // Populate the form fields with existing address data
      final address = widget.selectedAddress!;
      firstNameController.text = address.firstName ?? '';
      lastNameController.text = address.lastName ?? '';
      streetAddressController.text = address.address1 ?? '';
      phoneNumberController.text = address.phone ?? '';
      cityController.text = address.city ?? '';
      stateController.text = address.province ?? '';
      zipCodeController.text = address.postalCode ?? '';
      selectedLocation = address.addressName ?? AppStrings.home;
      print(selectedLocation);
      if (selectedLocation != AppStrings.home && selectedLocation != AppStrings.work) {
        selectedLocation = AppStrings.others;
        otherAddressName.text = address.addressName ?? '';
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.save,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView( // Makes the body scrollable
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: AppStrings.firstname,
                              controller: firstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.firstname;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              hintText: AppStrings.lastname,
                              controller: lastNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Lastname is required";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: AppStrings.street_address,
                        controller: streetAddressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.street_address_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: "Phone Number",
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone number is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: "City",
                        controller: cityController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "City is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: "State",
                              controller: stateController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "State is required";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              hintText: "Zip Code",
                              controller: zipCodeController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Zip code is required";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.location,
                        style: FontUtils.circularStdStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHorizontalLocationList(),
                      const SizedBox(height: 24),
                      if (selectedLocation == AppStrings.others)
                        TextFormField(
                            controller: otherAddressName,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.secondary,
                              hintText: 'ex: Friend House',
                              border: InputBorder.none,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an address name';
                              }
                              return null;
                            }),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Form is valid. Proceed to Create Address.");
                      createOrUpdateAddress();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Text(
                    widget.selectedAddress != null
                        ? AppStrings.save
                        : AppStrings.add_address,
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


  Widget _buildHorizontalLocationList() {
    return SizedBox(
      height: 40, // Adjust height based on your design needs
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Makes the ListView scroll horizontally
        itemCount: locationItems.length, // The total number of items
        itemBuilder: (context, index) {
          final location = locationItems[index]; // Get the location data
          final isSelected = selectedLocation == location['name']; // Selection logic
          return Padding(
            padding: const EdgeInsets.only(right: 8.0), // Add spacing between items
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedLocation = location['name']; // Update selected location
                });
              },
              child: _buildLocationButton(
                  location['name'],
                  location['icon'],
                  isSelected
              ),
            ),
          );
        },
      ),
    );
  }

  final List<Map<String, dynamic>> locationItems = [
    {'name': AppStrings.home, 'icon': Icons.home},
    {'name': AppStrings.work, 'icon': Icons.work},
    {'name': AppStrings.others, 'icon': Icons.location_pin},
  ];


  Widget _buildLocationButton(String location, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (Colors.grey[300] ?? Colors.grey),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? Colors.black87 : Colors.grey[400],
              size: 20),
          const SizedBox(width: 8),
          Text(
            location,
            style: FontUtils.circularStdStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black87 : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }



  void createOrUpdateAddress() async {
    try {
      final ApiService apiService = ApiService();
      selectedLocation = selectedLocation == AppStrings.others ? otherAddressName.text : selectedLocation;
      registerResponse = await apiService.createOrUpdateAddress(
          context,
          firstNameController.text,
          lastNameController.text,
          widget.selectedAddress?.id,
          streetAddressController.text,
          phoneNumberController.text,
          cityController.text,
          stateController.text,
          "India",
          zipCodeController.text,
          selectedLocation);
      setState(() {
        apiCalling = false;
      });
      print("1111111object");
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }
}
