import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/ui/ApprovalPage.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/refresh_token_response.dart';
import '../model/register_response.dart';
import '../utility/app_assets.dart';
import '../utility/font_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'bottom_nav_page.dart';

class UserDetailsPage extends StatefulWidget {
  final Widget? redirectPage;

  const UserDetailsPage(
      {super.key,
        this.redirectPage});


  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2 Controllers
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();

  bool _isGstRegistered = true;
  File? _gstImage;
  File? _panImage;

  String? _gstImagePath;
  String? _panImagePath;


  bool _isGstImageUploading = false;
  bool _isPanImageUploading = false;


  bool apiCalling = false;
  RegisterResponse? registerResponse;

  final FocusNode _focusNode = FocusNode();

  Widget buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStepContent() {
    if (_currentStep == 0) {
      // Step 1: Owner Details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Distributor Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          buildLabeledTextField(
            label: "Distributor Name",
            controller: _nameController,
            validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
          ),
          buildLabeledTextField(
            label: "Email Address",
            controller: _emailController,
            inputType: TextInputType.emailAddress,
            validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
          ),
          buildLabeledTextField(
            label: "Phone Number",
            controller: _phoneController,
            inputType: TextInputType.phone,
            validator: (val) => val == null || val.length < 10 ? 'Enter valid phone number' : null,
          ),
        ],
      );
    } else {
      // Step 2: Shop Details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Distributor Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // buildLabeledTextField(
          //   label: "Address",
          //   controller: _addressController,
          //   validator: (val) => val == null || val.isEmpty ? 'Please enter address' : null,
          // ),Waioz
          // buildLabeledTextField(
          //   label: "State",
          //   controller: _stateController,
          //   validator: (val) => val == null || val.isEmpty ? 'Please enter country' : null,
          // ),

          Visibility(
            visible: false,
            child: Row(
              children: [
                const Text("Is your shop GST-registered?", style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  activeColor: AppColors.primary,
                  value: _isGstRegistered,
                  onChanged: (value) => setState(() => _isGstRegistered = value),
                ),
              ],
            ),
          ),
          if (_isGstRegistered) ...[
            buildLabeledTextField(
              label: "GST Number",
              controller: _gstNumberController,
              validator: (val) => val == null || val.isEmpty ? 'Enter GST Number' : null,
            ),
            const SizedBox(height: 6),
            buildImageUploader(
              label: "GST Image",
              imageFile: _gstImage,
              isLoading: _isGstImageUploading,
              onUploadTap: () async {
                setState(() => _isGstImageUploading = true);
                await pickImage(
                      (img) => setState(() => _gstImage = img),
                      (path) => setState(() {
                    _gstImagePath = path;
                    _isGstImageUploading = false;
                  }),
                );
              },
            ),
            const SizedBox(height: 20),

            buildLabeledTextField(
              label: "PAN Number",
              controller: _panNumberController,
              validator: (val) => val == null || val.isEmpty ? 'Enter GST Number' : null,
            ),
            const SizedBox(height: 6),
            buildImageUploader(
              label: "PAN Image",
              imageFile: _panImage,
              isLoading: _isPanImageUploading,
              onUploadTap: () async {
                setState(() => _isPanImageUploading = true);
                await pickImage(
                      (img) => setState(() => _panImage = img),
                      (path) => setState(() {
                    _panImagePath = path;
                    _isPanImageUploading = false;
                  }),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ],
      );
    }
  }


  void _handleNext() {

    //if (_formKey.currentState?.validate() ?? false) {
    if (true) {
      if (_currentStep == 0) {
        setState(() => _currentStep = 1);
      }
      else {
      PageRouteUtils.pushAndRemoveUntil(context, const ApprovalPage(errorCode: '00000'));
        // Submit
        debugPrint("Form Submitted: ${_nameController.text}, ${_emailController.text}...");
        // Navigate or trigger next logic
        register();
      }
    }
  }

  void _showConfirmationAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: 'PinCode Verification',
          content: 'You entered: ${_postalCodeController.text}\n\n'
              'Note: Agent/Distributor assignment depends on this PinCode.\n\n'
              'Please confirm this is correct before proceeding.',
          contentOk: 'Confirm',
          contentCancel: 'Edit',
          onTapOk: () {
            Navigator.of(context).pop();
            setState(() => _currentStep = 2);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _postalCodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [

              Positioned(
                top: 0,
                right: 0,
                child: SvgPicture.asset(AppAssets.bg_top),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: SvgPicture.asset(AppAssets.bg_bottom),
              ),


              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: Colors.white.withOpacity(0.7)),
                ),
              ),


              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        children: [
                        _buildStepper(),
                    const SizedBox(height: 20),

                    // Modified Scrollable Area
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 200,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildStepContent(),
                              // Add minimal padding only if needed
                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    AnimatedPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom > 0
                            ? MediaQuery.of(context).viewInsets.bottom + 10
                            : 10,
                      ),
                      duration: const Duration(milliseconds: 100),
                      child: apiCalling? Center(child: CircularProgressIndicator(color: AppColors.primary,),): SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                            child: Text(
                              _currentStep < 1 ? "Next" : "Submit",
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            )
                        ),)
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

  }

  Widget _buildStepper() {
    List<String> titles = ["Step 1", "Step 2"];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(titles.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          int stepIndex = (index - 1) ~/ 2;
          bool isLineActive = _currentStep > stepIndex;

          return Expanded(
            child: Container(
              height: 36,
              alignment: Alignment.center,
              child: Container(
                height: 2,
                color: isLineActive ? AppColors.primary : AppColors.primary.withOpacity(0.2),
              ),
            ),
          );
        } else {
          // Step circle
          int stepIndex = index ~/ 2;
          bool isActive = _currentStep == stepIndex;
          bool isCompleted = _currentStep > stepIndex;

          return Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isActive || isCompleted ? AppColors.primary : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${stepIndex + 1}",
                  style: TextStyle(
                    color: isActive || isCompleted ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                titles[stepIndex],
                style: TextStyle(
                  color: isActive || isCompleted ? AppColors.primary : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }
      }),
    );
  }




  Widget buildImageUploader({
    required String label,
    required File? imageFile,
    required bool isLoading,
    required VoidCallback onUploadTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isLoading ? null : onUploadTap,
          child: DottedBorder(
            color: AppColors.primary,
            strokeWidth: 1.5,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            child: Container(
              width: double.infinity,
              height: 150,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: isLoading
                  ?  CircularProgressIndicator(color: AppColors.primary)
                  : (imageFile != null)
                  ? Image.file(imageFile, fit: BoxFit.cover)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 40,
                      color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text("Click to Upload",
                      style: TextStyle(color: AppColors.primary)),
                  Text("(Max. File size: 5 MB)",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> pickImage(Function(File) onImagePicked, Function(String?) onUploadComplete) async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final imageFile = File(picked.path);
        onImagePicked(imageFile);
        await _uploadAndStoreImage(imageFile, onUploadComplete);
      }
    } finally {
      // Reset all loading states if image picking is cancelled or fails
      if (mounted) {
        setState(() {
          _isGstImageUploading = false;
          _isPanImageUploading = false;
        });
      }
    }
  }

  void register() async {
    try {
      setState(() {
        apiCalling = true;
      });
      final ApiService apiService = ApiService();
      registerResponse = await apiService.register(
          context,
          _emailController.text,
          _shopNameController.text,
          _nameController.text,
          "",
          'widget.countryCode',
          'widget.phoneNo',
          'widget.token',
          _shopNameController.text,
          _stateController.text,
          _cityController.text,
          _postalCodeController.text,
          _isGstRegistered,
          _gstNumberController.text,
          _gstImagePath ?? "",
          "",
          "",
          "");

      // RefreshTokenResponse refreshTokenResponse =await apiService.refreshToken(
      //     context,widget.token);

      setState(() {
        apiCalling = false;
      });

      // SharedPreferencesUtil().saveString('token', refreshTokenResponse.token!);
      // SharedPreferencesUtil()
      //     .saveMap('customer', registerResponse!.customer!.toJson());

      if (mounted) {
        if (widget.redirectPage != null) {
          setState(() {
            apiCalling = true;
          });
          getHomePageApi();
          setState(() {
            apiCalling = false;
          });
          PageRouteUtils.pushAndRemoveUntil(context, widget.redirectPage!);
        } else {
          PageRouteUtils.pushAndRemoveUntil(context, const ApprovalPage(errorCode: '00000'));
        }
      }
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }

  void getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      final response= await apiService.getHomePage(context);
      await SharedPreferencesUtil().saveString('region_id', response.global!.regionId!);
      await SharedPreferencesUtil().saveString('cart_id', response.global!.cartId!);
      await SharedPreferencesUtil().saveString('currency_symbol', response.global!.currencySymbol!);
      await SharedPreferencesUtil().saveMap('global', response.global!.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<void> _uploadAndStoreImage(File image, Function(String?) onSuccess) async {
    try {
      var response = await ApiService().uploadDocImages(context, '', image);
      if (response != null && response['file'] != null) {
        onSuccess(response['file']['path']);
        print('Uploaded File Path: ${response['file']['path']}');
      } else {
        onSuccess(null);
        print('File upload failed or invalid response');
      }
    } catch (e) {
      onSuccess(null);
      print('Error uploading image: $e');
    }
  }


}
