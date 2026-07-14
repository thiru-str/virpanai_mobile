import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';

import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/ui_typography.dart';

class AddAddressPage extends StatefulWidget {
  final Address? selectedAddress; // Optional Address parameter
  final bool isFromMap;
  final Placemark? place;
  final LatLng? currentPosition;
  final bool doublePop;

  const AddAddressPage(
      {super.key,
      this.selectedAddress,
      this.isFromMap = false,
      this.place,
      this.currentPosition,
      this.doublePop = false});

  //ScreenFrom
  // 1-> Home page
  // 2-> Menu Address page

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
  bool isUpdating = false;
  RegisterResponse? registerResponse;
  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.selectedAddress != null) {
      final address = widget.selectedAddress!;
      firstNameController.text = address.firstName ?? '';
      lastNameController.text = address.lastName ?? '';
      phoneNumberController.text = address.phone ?? '';
      streetAddressController.text = '${address.address1 ?? ''} ${address.address2 ?? ''}';
      cityController.text = address.city??'';
      stateController.text = address.province??'';
      zipCodeController.text = address.postalCode ?? '';
      selectedLocation = address.addressName ?? AppStrings.home;

      if (selectedLocation != AppStrings.home && selectedLocation != AppStrings.work) {
        selectedLocation = AppStrings.others;
        otherAddressName.text = address.addressName ?? '';
      }
    }

    // If map data is available, always update the address part
    if (widget.isFromMap && widget.place != null) {
      final place = widget.place!;

      List<String?> streetAddress = [
        place.street,
        place.locality,
      ].where((element) => element != null && element.isNotEmpty).toList();

      streetAddressController.text = streetAddress.join(", ");
      cityController.text = place.locality ?? '';
      stateController.text = place.administrativeArea ?? '';
      zipCodeController.text = place.postalCode ?? '';
      latitude = widget.currentPosition!.latitude;
      longitude = widget.currentPosition!.longitude;
    }

  }

  static const Color _hairline = Color(0xFFE5E7EC);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: CommonHeaderAppBar(
          title: AppStrings.save,
          onBackTap: () {
            Navigator.of(context).pop();
          },
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              _buildFieldCard(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildField(
                          label: AppStrings.firstname,
                          controller: firstNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.firstname;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildField(
                          label: AppStrings.lastname,
                          controller: lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.lastname_required;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: AppStrings.street_address,
                    controller: streetAddressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.street_address_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: AppStrings.phone_number,
                    controller: phoneNumberController,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return AppStrings.phone_number_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: AppStrings.city,
                    controller: cityController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.city_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildField(
                          label: AppStrings.state,
                          controller: stateController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.state_required;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildField(
                          label: AppStrings.zip_code,
                          controller: zipCodeController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.zip_code_required;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFieldCard(
                children: [
                  Text(
                    AppStrings.location,
                    style: UiTypography.cardTitle().copyWith(
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildHorizontalLocationList(),
                  if (selectedLocation == AppStrings.others) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: otherAddressName,
                      style: UiTypography.cardSubtitle(color: AppColors.textColor)
                          .copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: AppStrings.ex_friend_house,
                        hintStyle: UiTypography.cardSubtitle(
                            color: Colors.grey.shade600),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE5484D)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFE5484D), width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.enter_address;
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _hairline, width: 1)),
            ),
            child: ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        print("Form is valid. Proceed to Create Address.");
                        createOrUpdateAddress();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary,
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isUpdating
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      widget.selectedAddress != null
                          ? AppStrings.save
                          : AppStrings.add_address,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: UiTypography.cardMeta(color: AppColors.textColor).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.sentences,
          validator: validator,
          style: UiTypography.cardSubtitle(color: AppColors.textColor)
              .copyWith(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            hintStyle: UiTypography.cardSubtitle(color: Colors.grey.shade600),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5484D)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5484D), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLocationList() {
    return SizedBox(
      height: 44, // Adjust height based on your design needs
      child: ListView.builder(
        scrollDirection:
            Axis.horizontal, // Makes the ListView scroll horizontally
        itemCount: locationItems.length, // The total number of items
        itemBuilder: (context, index) {
          final location = locationItems[index]; // Get the location data
          final isSelected =
              selectedLocation == location['name']; // Selection logic
          return Padding(
            padding:
                const EdgeInsets.only(right: 10.0), // Add spacing between items
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedLocation =
                      location['name']; // Update selected location
                });
              },
              child: _buildLocationButton(
                  location['name'], location['icon'], isSelected),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 18),
          const SizedBox(width: 8),
          Text(
            location,
            style: FontUtils.primaryFontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  void createOrUpdateAddress() async {
    try {
      setState(() {
        isUpdating = true;
      });
      final ApiService apiService = ApiService();
      selectedLocation = selectedLocation == AppStrings.others
          ? otherAddressName.text
          : selectedLocation;
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
          selectedLocation,
          latitude.toString(),
          longitude.toString());
      setState(() {
        isUpdating = false;
      });
      Navigator.pop(context, true);
      if (widget.doublePop) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      print(e);
    }
  }
}
