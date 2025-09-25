import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  RegisterResponse? registerResponse;
  bool apiCalling = true;
  Customer? customer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerInfo();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.edit_profile,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiCalling
          ?  Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    CustomTextField(
                      hintText:AppStrings.firstname,
                      controller: firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.firstname_required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: AppStrings.lastname,
                      controller: lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.lastname_required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enabled: false,
                      hintText: AppStrings.phone_number,
                      controller: phoneNoController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.phone_number_required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle registration logic
                          print("Form is valid. Proceed to register.");
                          updateUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        AppStrings.Upadte,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> getCustomerInfo() async {
    try {
      customer = await getCustomerResponse();
      if (customer != null) {
        setState(() {
          firstNameController.text = customer?.firstName ?? "";
          lastNameController.text = customer?.lastName ?? "";
          phoneNoController.text = customer?.phone ?? "";
          companyController.text = customer?.companyName ?? "";
        });
      }
    } catch (e) {
      print("Error fetching customer info: $e");
    } finally {
      setState(() {
        apiCalling = false; // Hide the loading spinner when done
      });
    }
  }

  Future<Customer?> getCustomerResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('customer');
    if (userData != null) {
      return Customer.fromJson(userData);
    }
    return null;
  }

  void updateUser() async {
    try {
      final ApiService apiService = ApiService();
      registerResponse = await apiService.updateProfile(
          context,
          phoneNoController.text,
          companyController.text,
          firstNameController.text,
          lastNameController.text);
      setState(() {
        apiCalling = false;
      });
      SharedPreferencesUtil()
          .saveMap('customer', registerResponse!.customer!.toJson());
      //Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }
}
