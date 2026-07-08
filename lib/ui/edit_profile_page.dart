import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';
import 'package:waioz/utility/ui_typography.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  RegisterResponse? registerResponse;
  bool apiCalling = true;
  bool uploadingShopImage = false;
  Customer? customer;
  File? selectedShopImage;
  String? uploadedShopImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerInfo();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNoController.dispose();
    shopNameController.dispose();
    super.dispose();
  }

  static const Color _hairline = Color(0xFFE5E7EC);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: CommonHeaderAppBar(
        title: AppStrings.edit_profile,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiCalling
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  _buildFieldCard(
                    children: [
                      _buildField(
                        label: AppStrings.firstname,
                        controller: firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.firstname_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppStrings.lastname,
                        controller: lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.lastname_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppStrings.phone_number,
                        controller: phoneNoController,
                        enabled: false,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.phone_number_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Shop Name',
                        controller: shopNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Shop Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildShopImageField(),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: apiCalling
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _hairline, width: 1)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle registration logic
                      print("Form is valid. Proceed to register.");
                      updateUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.Upadte,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
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
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: UiTypography.cardSubtitle(color: AppColors.textColor)
              .copyWith(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF4F4F4),
            hintText: label,
            hintStyle: UiTypography.cardSubtitle(color: Colors.grey.shade600),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
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
              borderSide:
                  const BorderSide(color: Color(0xFFE5484D), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopImageField() {
    final localImage = selectedShopImage;
    final remoteImage = uploadedShopImage ?? '';
    final hasImage = localImage != null || remoteImage.isNotEmpty;

    return FormField<String>(
      validator: (_) {
        if ((uploadedShopImage ?? '').isEmpty) {
          return 'Shop Image is required';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Image',
              style: UiTypography.cardMeta(color: AppColors.textColor)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: uploadingShopImage ? null : _showShopImageSourceSheet,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 154),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: field.hasError
                        ? Colors.red.shade700
                        : const Color(0xFFE5E7EC),
                  ),
                ),
                child: hasImage
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: localImage != null
                                ? Image.file(
                                    localImage,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    remoteImage,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _emptyImage(),
                                  ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                _imageActionButton(
                                  icon: Icons.photo_camera_outlined,
                                  onTap: _showShopImageSourceSheet,
                                ),
                                const SizedBox(width: 8),
                                _imageActionButton(
                                  icon: Icons.close_rounded,
                                  onTap: _removeShopImage,
                                ),
                              ],
                            ),
                          ),
                          if (uploadingShopImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : _emptyImage(),
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText ?? '',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _emptyImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.primary,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            uploadingShopImage
                ? 'Uploading shop image...'
                : 'Upload shop image',
            style: FontUtils.primaryFontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Take a photo or choose from gallery',
            textAlign: TextAlign.center,
            style: FontUtils.secondaryFontStyle(
              fontSize: 13,
              color: AppColors.textColor50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: uploadingShopImage ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.textColor),
        ),
      ),
    );
  }

  Future<void> _showShopImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_camera_outlined, color: AppColors.primary),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await _pickShopImage(source);
    }
  }

  Future<void> _pickShopImage(ImageSource source) async {
    final previousShopImage = uploadedShopImage;

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final validationMessage = await _validateShopImage(file);
      if (validationMessage != null) {
        AppUtils.showToast(validationMessage);
        return;
      }

      setState(() {
        selectedShopImage = file;
        uploadedShopImage = null;
        uploadingShopImage = true;
      });

      final response = await ApiService().uploadImage(context, file);
      final imagePath = response?['file']?['path'] as String?;
      if (imagePath == null || imagePath.isEmpty) {
        throw Exception('Invalid upload response');
      }

      if (!mounted) return;
      setState(() {
        uploadedShopImage = imagePath;
        uploadingShopImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        uploadingShopImage = false;
        selectedShopImage = null;
        uploadedShopImage = previousShopImage;
      });
      AppUtils.showToast('Unable to upload shop image');
    }
  }

  Future<String?> _validateShopImage(File file) async {
    final extension = file.path.split('.').last.toLowerCase();
    const supportedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
    const maxImageSizeBytes = 5 * 1024 * 1024;

    if (!supportedExtensions.contains(extension)) {
      return 'Please upload a JPG, PNG, or WEBP image';
    }

    final fileSize = await file.length();
    if (fileSize > maxImageSizeBytes) {
      return 'Shop image must be 5 MB or smaller';
    }

    return null;
  }

  void _removeShopImage() {
    setState(() {
      selectedShopImage = null;
      uploadedShopImage = null;
    });
  }

  Future<void> getCustomerInfo() async {
    try {
      try {
        final response = await ApiService().getCustomer(context);
        customer = response.customer;
        if (customer != null) {
          await SharedPreferencesUtil().saveMap('customer', customer!.toJson());
        }
      } catch (_) {
        customer = await getCustomerResponse();
      }

      if (customer != null) {
        setState(() {
          firstNameController.text = customer?.firstName ?? "";
          lastNameController.text = customer?.lastName ?? "";
          phoneNoController.text = customer?.phone ?? "";
          shopNameController.text =
              customer?.metadata?.shopName ?? customer?.companyName ?? "";
          uploadedShopImage = customer?.metadata?.shopImage;
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
      final shopName = shopNameController.text.trim();
      final shopImage = uploadedShopImage ?? '';

      if (uploadingShopImage) {
        AppUtils.showToast('Please wait for shop image upload');
        return;
      }

      if (shopImage.isEmpty) {
        AppUtils.showToast('Shop Image is required');
        return;
      }

      setState(() {
        apiCalling = true;
      });

      final ApiService apiService = ApiService();
      registerResponse = await apiService.updateProfile(
          context,
          phoneNoController.text,
          shopName,
          firstNameController.text,
          lastNameController.text,
          shopName,
          shopImage,
          customer?.metadata?.toJson());

      final updatedCustomer = registerResponse!.customer;
      if (updatedCustomer != null) {
        updatedCustomer.metadata = Metadata.fromJson({
          ...?customer?.metadata?.toJson(),
          ...?updatedCustomer.metadata?.toJson(),
          "shop_name": shopName,
          "shop_image": shopImage,
        });
        updatedCustomer.companyName = shopName;
      }

      setState(() {
        apiCalling = false;
      });
      SharedPreferencesUtil()
          .saveMap('customer', registerResponse!.customer!.toJson());
      AppUtils.showToast('Profile updated successfully');
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }
}
