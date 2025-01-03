import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'bottom_nav_page.dart';

class RegisterPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  final String token;
  const RegisterPage({super.key,required this.countryCode,required this.phoneNo,required this.token});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();


  bool apiCalling = true;
  RegisterResponse? registerResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(AppAssets.ic_arrow_svg,height: 16,width: 16),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello! Register to get started",
                style: FontUtils.gabaritoStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
                isPassword: false,
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
                    register();
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
                  'Register',
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

  void register() async {
    try {
      final ApiService apiService = ApiService();
      registerResponse = await apiService.register(context,emailController.text,companyController.text,firstNameController.text,lastNameController.text,widget.phoneNo,widget.token);
      setState(() {
        apiCalling = false;
      });

      SharedPreferencesUtil().saveString('token', widget.token);
      SharedPreferencesUtil().saveMap('customer', registerResponse!.customer!.toJson());

      PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }
}
