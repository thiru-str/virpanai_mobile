import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waioz/ui/ApprovalPage.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/refresh_token_response.dart';
import '../model/register_response.dart';
import '../utility/shared_preferences_util.dart';
import 'bottom_nav_page.dart';

class UserDetailsPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  final String token;
  final Widget? redirectPage;

  const UserDetailsPage(
      {super.key,
        required this.countryCode,
        required this.phoneNo,
        required this.token,
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

  bool _isGstRegistered = true;
  File? _gstImage;
  File? _shopFrontImage;
  File? _shopInteriorImage;
  File? _shopCounterImage;

  String? _gstImagePath;
  String? _shopFrontImagePath;
  String? _shopInteriorImagePath;
  String? _shopCounterImagePath;

  bool apiCalling = true;
  bool imageUploading = false;
  RegisterResponse? registerResponse;

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
          const Text("Owner Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          buildLabeledTextField(
            label: "Name",
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
    } else if (_currentStep == 1){
      // Step 2: Shop Details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Shop Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          buildLabeledTextField(
            label: "Shop Name",
            controller: _shopNameController,
            validator: (val) => val == null || val.isEmpty ? 'Please enter shop name' : null,
          ),
          buildLabeledTextField(
            label: "Address",
            controller: _addressController,
            validator: (val) => val == null || val.isEmpty ? 'Please enter address' : null,
          ),
          buildLabeledTextField(
            label: "State",
            controller: _stateController,
            validator: (val) => val == null || val.isEmpty ? 'Please enter country' : null,
          ),
          Row(
            children: [
              Expanded(
                child: buildLabeledTextField(
                  label: "City",
                  controller: _cityController,
                  validator: (val) => val == null || val.isEmpty ? 'Enter city' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildLabeledTextField(
                  label: "Postal Code",
                  controller: _postalCodeController,
                  inputType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Enter postal code' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
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
              onUploadTap: () => pickImage((img) => setState(() => _gstImage = img),(path) => setState(() => _gstImagePath = path)),
            ),
            const SizedBox(height: 20),
          ],
        ],
      );
    }
    else{
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shop Images", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildImageUploader(
              label: "Shop Front With Name Board",
              imageFile: _shopFrontImage,
              onUploadTap: () => pickImage((img) => setState(() => _shopFrontImage = img),(path) => setState(() => _shopFrontImagePath = path)),
            ),
            buildImageUploader(
              label: "Shop Interior",
              imageFile: _shopInteriorImage,
              onUploadTap: () => pickImage((img) => setState(() => _shopInteriorImage = img),(path) => setState(() => _shopInteriorImagePath = path)),
            ),
            buildImageUploader(
              label: "Shop Counter",
              imageFile: _shopCounterImage,
              onUploadTap: () => pickImage((img) => setState(() => _shopCounterImage = img),(path) => setState(() => _shopCounterImagePath = path)),
            ),
          ],
        );

    }
  }


  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep == 0) {
        setState(() => _currentStep = 1);
      }
      else if (_currentStep == 1) {
        setState(() => _currentStep = 2);
      } else {
        // Submit
        debugPrint("Form Submitted: ${_nameController.text}, ${_emailController.text}...");
        PageRouteUtils.push(context, ApprovalPage());
        // Navigate or trigger next logic
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _phoneController.text = '${widget.countryCode} ${widget.phoneNo}';
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Step Indicators
                _buildStepper(),
                const SizedBox(height: 20),
                Expanded(child: SingleChildScrollView(child: buildStepContent())),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_currentStep < 1 ? "Next" : "Submit", style: const TextStyle(fontSize: 18,color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    List<String> titles = ["Step 1", "Step 2", "Step 3"];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(titles.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          int stepIndex = (index - 1) ~/ 2;
          bool isLineActive = _currentStep > stepIndex;

          return Expanded(
            child: Container(
              height: 36, // Match circle height
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







  Widget _buildStepIndicator(int step, String title) {
    bool isActive = _currentStep == step;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
          child: Text("${step + 1}", style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: isActive ? AppColors.primary : Colors.grey)),
      ],
    );
  }

  Widget buildImageUploader({
    required String label,
    required File? imageFile,
    required VoidCallback onUploadTap,
  }) {
    return imageUploading? Center(child: CircularProgressIndicator(color: AppColors.primary,)) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onUploadTap,
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
              child: imageFile != null
                  ? Image.file(imageFile, fit: BoxFit.cover)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                  SizedBox(height: 10),
                  Text("Click to Upload", style: TextStyle(color: AppColors.primary)),
                  Text("(Max. File size: 5 MB)", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageFile = File(picked.path);
      onImagePicked(imageFile);
      await _uploadAndStoreImage(imageFile, onUploadComplete);
    }
  }

  void register() async {
    try {
      final ApiService apiService = ApiService();
      registerResponse = await apiService.register(
          context,
          _emailController.text,
          _shopNameController.text,
          _nameController.text,
          "",
          widget.countryCode,
          widget.phoneNo,
          widget.token,
          _shopNameController.text,
          _stateController.text,
          _cityController.text,
          _postalCodeController.text,
          _isGstRegistered,
          _gstNumberController.text,
          _gstImagePath ?? "",
          _shopFrontImagePath ?? "",
          _shopInteriorImagePath ?? "",
          _shopCounterImagePath ?? "");

      RefreshTokenResponse refreshTokenResponse =await apiService.refreshToken(
          context,widget.token);

      setState(() {
        apiCalling = false;
      });

      SharedPreferencesUtil().saveString('token', refreshTokenResponse.token!);
      SharedPreferencesUtil()
          .saveMap('customer', registerResponse!.customer!.toJson());

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
          PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
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
      setState(() {
        imageUploading = true;
      });
      var response = await ApiService().uploadDocImages(context, widget.token, image);
      if (response != null && response['file'] != null) {
        setState(() {
          imageUploading = false;
        });
        onSuccess(response['file']['path']);
        print('Uploaded File Path: ${response['file']['path']}');
      } else {
        setState(() {
          imageUploading = false;
        });
        onSuccess(null);
        print('File upload failed or invalid response');
      }
    } catch (e) {
      setState(() {
        imageUploading = false;
      });
      onSuccess(null);
      print('Error uploading image: $e');
    }
  }


}
