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
  final TextEditingController emailController = TextEditingController();
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 32),
              CustomTextField(
                hintText: "First Name",
                controller: firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "First name  is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Last Name",
                controller: lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "First name  is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Company",
                controller: companyController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Company is required";
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
                  'Update',
                  style: FontUtils.circularStdStyle(
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
    customer = await getCustomerResponse();
    if (customer != null) {
      setState(() {
        customer;
        firstNameController.text = customer?.firstName ?? "";
        lastNameController.text = customer?.lastName ?? "";
        emailController.text = customer?.email ?? "";
        companyController.text = customer?.companyName ?? "";
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
      //registerResponse = await apiService.updateProfile(context,emailController.text,companyController.text,firstNameController.text,lastNameController.text);
      setState(() {
        apiCalling = false;
      });
      SharedPreferencesUtil().saveMap('customer', registerResponse!.customer!.toJson());
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }
}
