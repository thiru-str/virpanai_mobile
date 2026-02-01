import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/ui/ApprovalPage.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/image_uploader.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../model/pin_code_response.dart';
import '../model/refresh_token_response.dart';
import '../model/register_response.dart';
import '../utility/app_assets.dart';
import '../utility/app_strings.dart';
import '../utility/font_utils.dart';
import '../utility/shared_preferences_util.dart';

class CustomerRegisterPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  final String token;
  final Widget? redirectPage;

  const CustomerRegisterPage(
      {super.key,
      required this.countryCode,
      required this.phoneNo,
      required this.token,
      this.redirectPage});

  @override
  State<CustomerRegisterPage> createState() => _CustomerRegisterPageState();
}

class _CustomerRegisterPageState extends State<CustomerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1 Controllers
  //final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2 Controllers
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _gstNumberController = TextEditingController();

  bool _isGstRegistered = false;
  File? _gstImage;
  File? _shopFrontImage;
  File? _shopInteriorImage;
  File? _shopCounterImage;

  String? _gstImagePath;
  String? _shopFrontImagePath;
  String? _shopInteriorImagePath;
  String? _shopCounterImagePath;

  bool _isGstImageUploading = false;
  bool _isShopFrontUploading = false;
  bool _isShopInteriorUploading = false;
  bool _isShopCounterUploading = false;

  bool apiCalling = false;
  RegisterResponse? registerResponse;

  final FocusNode _focusNode = FocusNode();

  Widget buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters, // 👈 optional
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            validator: validator,
            maxLength: maxLength,
            enabled: enabled,
            inputFormatters: inputFormatters, // 👈 apply only if passed
            textCapitalization: inputType == TextInputType.emailAddress
                ? TextCapitalization.none
                : TextCapitalization.words,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary.withAlpha(50)),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          const Text("Owner Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // buildLabeledTextField(
          //   label: "Owner Name",
          //   controller: _nameController,
          //   validator: (val) =>
          //       val == null || val.isEmpty ? 'Please enter your name' : null,
          // ),
          buildLabeledTextField(
            label: "Email Address",
            controller: _emailController,
            inputType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.email_required;
              }
              if (!RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value)) {
                return AppStrings.enter_valid_email;
              }
              return null;
            },
          ),
          buildLabeledTextField(
            label: "Phone Number",
            enabled: false,
            controller: _phoneController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            inputType: TextInputType.phone,
            validator: (val) => val == null || val.isEmpty
                ? 'Enter valid phone number'
                : null,
          ),
        ],
      );
    } else if (_currentStep == 1) {
      // Step 2: Shop Details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Shop Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          buildLabeledTextField(
            label: "Shop Name",
            controller: _shopNameController,
            validator: (val) =>
                val == null || val.isEmpty ? 'Please enter shop name' : null,
          ),
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
          Text('Postal Code',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          PinCodeTextField(
            appContext: context,
            length: 6,
            autoDisposeControllers: false,
            controller: _postalCodeController,
            // Reusing your postal code controller
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            autoFocus: true,
            animationType: AnimationType.none,
            textStyle: FontUtils.primaryFontStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 50,
              fieldWidth: 50,
              inactiveFillColor: Colors.white,
              activeFillColor: Colors.white,
              selectedFillColor: Colors.white,
              inactiveColor: AppColors.primary,
              activeColor: AppColors.primary,
              selectedColor: AppColors.primary,
            ),
            enableActiveFill: true,
            validator: (value) =>
                value == null || value.isEmpty || value.length != 6
                    ? 'Please enter a valid 6-digit postal code'
                    : null,
            onCompleted: (value) => print("Postal Code Entered: $value"),
            onChanged: (value) => print(value),
          ),
          Text(
              'Note: Based on the entered pincode is how we assign the correct Agent/ Distributer. Please ensure you give the correct pincode.'),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("Is your shop GST-registered?",
                  style: TextStyle(fontSize: 16)),
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
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter GST Number' : null,
            ),
            const SizedBox(height: 6),
            ImageUploader(
              label: "GST Image",
              imageFile: _gstImage,
              isUploading: _isGstImageUploading,
              onTap: () => _pickAndUploadImage(
                onPick: (file) => setState(() => _gstImage = file),
                onUploaded: (path) => setState(() => _gstImagePath = path),
                onUploadFailed: () => setState(() {
                  _gstImage = null;
                  _gstImagePath = null;
                  AppUtils.showToast('GST image upload failed. Please try again');
                }),
                setLoading: (val) => setState(() => _isGstImageUploading = val),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Shop Images",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ImageUploader(
            label: "Shop Front With Name Board",
            imageFile: _shopFrontImage,
            isUploading: _isShopFrontUploading,
            onTap: () => _pickAndUploadImage(
              onPick: (file) => setState(() => _shopFrontImage = file),
              onUploaded: (path) => setState(() => _shopFrontImagePath = path),
              onUploadFailed: () => setState(() {
                _shopFrontImage = null;
                _shopFrontImagePath = null;
                AppUtils.showToast('Shop Front Image upload failed. Please try again');
              }),
              setLoading: (val) => setState(() => _isShopFrontUploading = val),
            ),
          ),
          ImageUploader(
            label: "Shop Interior",
            imageFile: _shopInteriorImage,
            isUploading: _isShopInteriorUploading,
            onTap: () => _pickAndUploadImage(
              onPick: (file) => setState(() => _shopInteriorImage = file),
              onUploaded: (path) =>
                  setState(() => _shopInteriorImagePath = path),
              onUploadFailed: () => setState(() {
                _shopInteriorImage = null;
                _shopInteriorImagePath = null;
                AppUtils.showToast('Shop Interior Image upload failed. Please try again');
              }),
              setLoading: (val) =>
                  setState(() => _isShopInteriorUploading = val),
            ),
          ),
          ImageUploader(
            label: "Shop Counter",
            imageFile: _shopCounterImage,
            isUploading: _isShopCounterUploading,
            onTap: () => _pickAndUploadImage(
              onPick: (file) => setState(() => _shopCounterImage = file),
              onUploaded: (path) =>
                  setState(() => _shopCounterImagePath = path),
              onUploadFailed: () => setState(() {
                _shopCounterImage = null;
                _shopCounterImagePath = null;
                AppUtils.showToast('Shop Counter Image upload failed. Please try again');
              }),
              setLoading: (val) =>
                  setState(() => _isShopCounterUploading = val),
            ),
          ),
        ],
      );
    }
  }

  Future<void> _handleNext() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_currentStep == 0) {
      final response = await ApiService().checkDuplicate(
          context, _emailController.text, _phoneController.text);

      if (response.status ?? false) {
        setState(() => _currentStep = 1);
      } else {
        AppUtils.showToast(response.error?.message ?? '');
      }
      return;
    }

    if (_currentStep == 1) {

      if (_isGstRegistered) {
        if (_isGstImageUploading) {
          AppUtils.showToast('Please wait, GST image is uploading');
          return;
        }
        if (_gstImagePath == null) {
          AppUtils.showToast('Please upload GST image');
          return;
        }
      }

      final response =
      await ApiService().pinCodeCheck(context, _postalCodeController.text);

      _showConfirmationAlert(context, response);
      return;
    }

    if (_currentStep == 2) {

      if (_isShopFrontUploading ||
          _isShopInteriorUploading ||
          _isShopCounterUploading) {
        AppUtils.showToast('Please wait, images are still uploading');
        return;
      }

      if (_shopFrontImagePath == null) {
        AppUtils.showToast('Please upload Shop front image');
        return;
      }

      if (_shopInteriorImagePath == null) {
        AppUtils.showToast('Please upload Shop interior image');
        return;
      }

      if (_shopCounterImagePath == null) {
        AppUtils.showToast('Please upload Shop counter image');
        return;
      }

      register();
    }
  }

  Future<void> _pickAndUploadImage({
    required Function(File) onPick,
    required Function(String?) onUploaded,
    required VoidCallback onUploadFailed,
    required Function(bool) setLoading,
  }) async {
    try {
      setLoading(true);

      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picked = await ImagePicker().pickImage(source: source);
      if (picked == null) return;

      final originalFile = File(picked.path);

      final compressedFile = await _compressImage(originalFile);


      onPick(compressedFile);

      final response = await ApiService()
          .uploadDocImages(context, widget.token, compressedFile);

      final path = response?['file']?['path'];
      if (path == null) throw Exception('Upload failed');

      onUploaded(path);
    } catch (e) {
      onUploadFailed();
    } finally {
      setLoading(false);
    }
  }


  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'cmp_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (compressed == null) {
      return file;
    }

    return File(compressed.path);
  }

  void _showConfirmationAlert(BuildContext context, PinCodeResponse response) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: 'PinCode Verification',
          content: 'You entered: ${_postalCodeController.text}\n\n'
              'Area name: ${response.data?.pincode?.firstOrNull?.area ?? 'N/A'}\n\n'
              '${response.data?.dealer?.firstOrNull?.name != null ? 'Assigned Distributor: ${response.data!.dealer!.first.name}\n\n' : ''}'
              'Note: Distributor assignment depends on this PinCode.\n\n'
              'Please confirm this before proceeding.',
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
    //_nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _gstNumberController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _phoneController.text = '${widget.countryCode} ${widget.phoneNo}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          FocusScope.of(context).unfocus();
          _formKey.currentState?.reset();
          setState(() => _currentStep -= 1);
          return false; // prevent page exit
        }
        return true; // allow exit if already at step 0
      },
      child: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: Scaffold(
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
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(padding:EdgeInsets.only(right: 20),child: _buildStepper()),
                            const SizedBox(height: 20),
                            // Modified Scrollable Area
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight - 200,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildStepContent(),
                                      // Add minimal padding only if needed
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom >
                                                  0
                                              ? 20
                                              : 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            AnimatedPadding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom >
                                          0
                                      ? MediaQuery.of(context).viewInsets.bottom +
                                          10
                                      : 10,
                                ),
                                duration: const Duration(milliseconds: 100),
                                child: apiCalling
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: ElevatedButton(
                                              onPressed: _handleNext,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                _currentStep < 1 ? "Next" : "Submit",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              )),
                                        ),
                                      )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    List<String> titles = ["Step 1", "Step 2", "Step 3"];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back arrow as the first element in row
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () {
              if (_currentStep > 0) {
                FocusScope.of(context).unfocus();
                _formKey.currentState?.reset();
                setState(() => _currentStep -= 1);
              } else {
                Navigator.pop(context);
              }
            },
          ),

        // Stepper content
        Expanded(
          child: Row(
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
                      color: isLineActive
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.2),
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
                        color: isActive || isCompleted
                            ? AppColors.primary
                            : Colors.white,
                        border: Border.all(
                          color: isActive || isCompleted
                              ? AppColors.primary
                              : Colors.grey.shade400,
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
          ),
        ),
      ] ,
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
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                  ? CircularProgressIndicator(color: AppColors.primary)
                  : (imageFile != null)
                      ? Image.file(imageFile, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 40, color: AppColors.primary),
                            const SizedBox(height: 10),
                            Text("Click to Upload",
                                style: TextStyle(color: AppColors.primary)),
                            Text("(Max. File size: 5 MB)",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> pickImage(
      Function(File) onImagePicked, Function(String?) onUploadComplete) async {
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
          _isShopCounterUploading = false;
          _isShopInteriorUploading = false;
          _isShopFrontUploading = false;
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
      var response = await apiService.createCustomer(
          context,
          _emailController.text,
          _shopNameController.text,
          widget.countryCode,
          widget.phoneNo,
          _shopNameController.text,
          _stateController.text,
          _cityController.text,
          _postalCodeController.text,
          _isGstRegistered,
          _gstNumberController.text,
          _gstImagePath ?? "",
          _shopFrontImagePath ?? "",
          _shopInteriorImagePath ?? "",
          _shopCounterImagePath ?? "",widget.token);

      setState(() {
        apiCalling = false;
      });

      if (response != null) {
        setState(() {
          apiCalling = false;
        });
        if (response['status'] == 'success') {
          Navigator.pop(context, true);
        } else {
          AppUtils.showToast(response['error']);
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
      final response = await apiService.getHomePage(context);
      await SharedPreferencesUtil()
          .saveString('region_id', response.global!.regionId!);
      await SharedPreferencesUtil()
          .saveString('cart_id', response.global!.cartId!);
      await SharedPreferencesUtil()
          .saveString('currency_symbol', response.global!.currencySymbol!);
      await SharedPreferencesUtil()
          .saveMap('global', response.global!.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<void> _uploadAndStoreImage(
      File image, Function(String?) onSuccess) async {
    try {
      var response =
          await ApiService().uploadDocImages(context, widget.token, image);
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
