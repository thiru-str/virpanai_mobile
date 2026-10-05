import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waioz/model/email_register_response.dart';
import 'package:waioz/model/healthcare_registration_payload.dart';
import 'package:waioz/model/refresh_token_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'package:waioz/utility/app_strings.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';
import '../utility/ui_typography.dart';
import 'bottom_nav_page.dart';

class _HealthcareDocument {
  final String id;
  final String name;

  const _HealthcareDocument({required this.id, required this.name});
}

class RegisterPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  final String token;
  final Widget? redirectPage;
  const RegisterPage(
      {super.key,
      required this.countryCode,
      required this.phoneNo,
      required this.token,
      required this.redirectPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController aadhaarNumberController = TextEditingController();
  final TextEditingController drugLicenceNumberController =
      TextEditingController();
  final TextEditingController drugLicenceValidFromController =
      TextEditingController();
  final TextEditingController drugLicenceValidToController =
      TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();

  bool apiCalling = false;
  RegisterResponse? registerResponse;
  EmailRegisterResponse? emailRegisterResponse;
  bool isEmailLogin = false;
  bool _loginTypeLoaded = false;
  bool _healthcareSubmitted = false;
  String _userType = 'general_user';
  final Map<String, List<_HealthcareDocument>> _healthcareDocuments = {};
  final Map<String, bool> _uploadingHealthcareDocuments = {};
  final Set<String> _healthcareDocumentErrors = {};
  String? _phoneNo;
  String? _countryCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneNo = widget.phoneNo;
    _countryCode = widget.countryCode;
    getLoginType();
  }

  Future<void> getLoginType() async {
    final loginType =
        await SharedPreferencesUtil().getBool('email_login') ?? false;
    if (!mounted) return;
    setState(() {
      isEmailLogin = loginType;
      _loginTypeLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loginTypeLoaded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!isEmailLogin) {
      return _buildHealthcareRegistrationPage();
    }

    return _buildLegacyRegistrationPage();
  }

  Widget _buildLegacyRegistrationPage() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FB),
          elevation: 0,
          leading: IconButton(
            icon:
                SvgPicture.asset(AppAssets.ic_arrow_svg, height: 16, width: 16),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.register_msg,
                    style: UiTypography.cardTitle().copyWith(
                      fontSize: 24,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account to start shopping',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 14,
                      color: AppColors.textColor50,
                    ).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Grouped fields card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                hintText: AppStrings.firstname,
                                controller: firstNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppStrings.firstname_required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                hintText: AppStrings.lastname,
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
                        CustomTextField(
                          hintText: AppStrings.email,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.email_required;
                            }
                            if (!RegExp(
                                    r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return AppStrings.enter_valid_email;
                            }
                            return null;
                          },
                        ),
                        if (isEmailLogin) ...[
                          const SizedBox(height: 16),
                          IntlPhoneField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            dropdownTextStyle: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                            style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: AppStrings.mobile_number,
                              hintStyle: UiTypography.searchHint(),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 1.5),
                              ),
                            ),
                            initialCountryCode: AppStrings.country_code,
                            onChanged: (phone) {
                              _phoneNo = phone.number;
                              _countryCode = phone.countryCode;
                            },
                            validator: (value) {
                              if (value == null || value.number.isEmpty) {
                                return AppStrings.enter_valid_mob_no;
                              }
                              if (value.number.length < 10 ||
                                  value.number.length > 15) {
                                return AppStrings.digit_range;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            hintText: AppStrings.password,
                            controller: passwordController,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                    r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),
                              )
                            ],
                            isPassword: true,
                            validator: (value) {
                              if (!isEmailLogin) return null;

                              if (value == null || value.isEmpty) {
                                return AppStrings.password_required;
                              }
                              if (value.length < 5) {
                                return AppStrings.password_min_length;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            hintText: AppStrings.confirm_password,
                            controller: confirmPasswordController,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                    r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),
                              )
                            ],
                            isPassword: true,
                            validator: (value) {
                              if (!isEmailLogin) return null;

                              if (value == null || value.isEmpty) {
                                return AppStrings.confirm_password_required;
                              }
                              if (value != passwordController.text) {
                                return AppStrings.password_mismatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          newToAppRegisterText(onRegisterTap: () {
                            Navigator.pop(context);
                          }),
                        ],
                        const SizedBox(height: 16),
                        _buildReferralField(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  apiCalling
                      ? SizedBox(
                          height: 54,
                          child: Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              register();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary, // Button color
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppStrings.register,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Item 7 — Referral input with inline QR scan + contact picker icons.
  // Field accepts either a unique code or a phone number; backend resolves.
  Widget _buildHealthcareRegistrationPage() {
    if (_healthcareSubmitted) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.primary, size: 64),
                    const SizedBox(height: 18),
                    Text(
                      'Registration Submitted',
                      textAlign: TextAlign.center,
                      style: UiTypography.cardTitle().copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your account is pending administrator approval.',
                      textAlign: TextAlign.center,
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 14,
                        color: AppColors.textColor50,
                      ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Back to log in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isDoctor = _userType == 'doctor';
    final isUploading =
        _uploadingHealthcareDocuments.values.any((value) => value);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FB),
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              AppAssets.ic_arrow_svg,
              height: 16,
              width: 16,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Registration',
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 24,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isDoctor
                      ? 'Doctor registration'
                      : 'General user registration',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: AppColors.textColor50,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose User Type',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUserTypeOption(
                              value: 'general_user',
                              label: 'General User',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildUserTypeOption(
                              value: 'doctor',
                              label: 'Doctor',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Full Name',
                        controller: fullNameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter Full Name'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: AppStrings.email,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Please enter Email';
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(email)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      if (isDoctor) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'Aadhaar Number',
                          controller: aadhaarNumberController,
                          validator: _requiredHealthcareField('Aadhaar Number'),
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'aadhaar_document',
                          label: 'Aadhaar Upload',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'Drug Licence Number',
                          controller: drugLicenceNumberController,
                          validator:
                              _requiredHealthcareField('Drug Licence Number'),
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'drug_licence_document',
                          label: 'Drug Licence Upload',
                        ),
                        const SizedBox(height: 16),
                        _buildHealthcareDateField(
                          label: 'Drug Licence Valid From',
                          controller: drugLicenceValidFromController,
                        ),
                        const SizedBox(height: 16),
                        _buildHealthcareDateField(
                          label: 'Drug Licence Valid To',
                          controller: drugLicenceValidToController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'PAN Number',
                          controller: panNumberController,
                          textCapitalization: TextCapitalization.characters,
                          validator: _requiredHealthcareField('PAN Number'),
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'pan_document',
                          label: 'PAN Upload',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'GST Number',
                          controller: gstNumberController,
                          textCapitalization: TextCapitalization.characters,
                          validator: _requiredHealthcareField('GST Number'),
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'gst_document',
                          label: 'GST Upload',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (apiCalling || isUploading)
                  SizedBox(
                    height: 54,
                    child: Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _submitHealthcareRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Submit Registration',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? Function(String?) _requiredHealthcareField(String label) {
    return (value) =>
        value == null || value.trim().isEmpty ? 'Please enter $label' : null;
  }

  Widget _buildUserTypeOption({required String value, required String label}) {
    final selected = _userType == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _changeHealthcareUserType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EC),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : Colors.grey.shade500,
            ),
            Expanded(
              child: Text(
                label,
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeHealthcareUserType(String value) {
    setState(() {
      _userType = value;
      if (value != 'doctor') _healthcareDocumentErrors.clear();
    });
  }

  Widget _buildHealthcareDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectHealthcareDate(controller),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: UiTypography.searchHint(),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: const Icon(Icons.calendar_month_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: _requiredHealthcareField(label),
    );
  }

  Future<void> _selectHealthcareDate(
    TextEditingController controller,
  ) async {
    var initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      initialDate = DateTime.tryParse(controller.text) ?? initialDate;
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    final month = selected.month.toString().padLeft(2, '0');
    final day = selected.day.toString().padLeft(2, '0');
    setState(() => controller.text = '${selected.year}-$month-$day');
  }

  Widget _buildHealthcareDocumentField({
    required String field,
    required String label,
  }) {
    final documents = _healthcareDocuments[field] ?? const [];
    final uploading = _uploadingHealthcareDocuments[field] == true;
    final hasError = _healthcareDocumentErrors.contains(field);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? Colors.red.shade600 : const Color(0xFFE5E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FontUtils.primaryFontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: uploading
                ? null
                : () => _pickAndUploadHealthcareDocuments(field),
            icon: uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(uploading ? 'Uploading...' : 'Choose files'),
          ),
          Text(
            'Images or PDF files',
            style: FontUtils.secondaryFontStyle(
              fontSize: 12,
              color: AppColors.textColor50,
            ),
          ),
          if (documents.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...documents.map(
              (document) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        document.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.secondaryFontStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              'Please upload $label',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndUploadHealthcareDocuments(String field) async {
    final selection = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'],
    );
    if (selection == null || selection.files.isEmpty || !mounted) return;

    setState(() => _uploadingHealthcareDocuments[field] = true);
    final uploaded = <_HealthcareDocument>[];
    try {
      for (final selectedFile in selection.files) {
        if (selectedFile.path == null) continue;
        final response = await ApiService().uploadHealthcareDocument(
          context,
          File(selectedFile.path!),
          field,
        );
        final id = response['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          uploaded.add(_HealthcareDocument(id: id, name: selectedFile.name));
        }
      }
      if (!mounted) return;
      setState(() {
        _healthcareDocuments[field] = [
          ...?_healthcareDocuments[field],
          ...uploaded,
        ];
        if (uploaded.isNotEmpty) _healthcareDocumentErrors.remove(field);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File upload failed: ${_cleanError(error)}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingHealthcareDocuments[field] = false);
      }
    }
  }

  Future<void> _submitHealthcareRegistration() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;
    const requiredDocuments = [
      'aadhaar_document',
      'drug_licence_document',
      'pan_document',
      'gst_document',
    ];
    final missingDocuments = _userType == 'doctor'
        ? requiredDocuments
            .where((field) => (_healthcareDocuments[field] ?? []).isEmpty)
            .toSet()
        : <String>{};

    setState(() {
      _healthcareDocumentErrors
        ..clear()
        ..addAll(missingDocuments);
    });
    if (!formValid || missingDocuments.isNotEmpty) return;

    final payload = buildHealthcareRegistrationPayload(
      phone: widget.phoneNo,
      countryCode: widget.countryCode,
      fullName: fullNameController.text,
      email: emailController.text,
      userType: _userType,
      aadhaarNumber: aadhaarNumberController.text,
      drugLicenceNumber: drugLicenceNumberController.text,
      drugLicenceValidFrom: drugLicenceValidFromController.text,
      drugLicenceValidTo: drugLicenceValidToController.text,
      panNumber: panNumberController.text,
      gstNumber: gstNumberController.text,
      documentIds: {
        for (final field in requiredDocuments) field: _documentIds(field),
      },
    );

    setState(() => apiCalling = true);
    try {
      final response =
          await ApiService().registerHealthcareUser(context, payload);
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() => _healthcareSubmitted = true);
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(error)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => apiCalling = false);
    }
  }

  List<String> _documentIds(String field) => (_healthcareDocuments[field] ?? [])
      .map((document) => document.id)
      .toList();

  String _cleanError(Object error) =>
      error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');

  Widget _buildReferralField() {
    return TextField(
      controller: referralCodeController,
      style: FontUtils.primaryFontStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Referral code or phone (optional)',
        hintStyle: FontUtils.primaryFontStyle(
            fontSize: 14, color: Colors.grey.shade400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Scan QR',
              icon: Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.primary, size: 22),
              onPressed: _scanQrCode,
            ),
            IconButton(
              tooltip: 'Pick from contacts',
              icon: Icon(Icons.contacts_rounded,
                  color: AppColors.primary, size: 22),
              onPressed: _pickFromContacts,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _QrScannerSheet()),
    );
    if (result != null && result.trim().isNotEmpty && mounted) {
      referralCodeController.text = result.trim();
    }
  }

  Future<void> _pickFromContacts() async {
    // Pre-prompt soft sheet — explain why we need contacts before the system dialog.
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              // Icon badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.contacts_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Find your referrer easily',
                textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pick a contact whose phone number is\nregistered as a referrer.',
                textAlign: TextAlign.center,
                style: FontUtils.secondaryFontStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              // Allow button — full width
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Allow access',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Not now — text link
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Not now',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              // Privacy note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'We never store or share your contacts',
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
    if (proceed != true || !mounted) return;

    final granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Permission denied. You can still type the referral code manually.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      return;
    }

    try {
      if (Platform.isIOS) {
        // iOS native picker goes directly to Contacts — no app chooser issue.
        final contact = await FlutterContacts.openExternalPick();
        if (contact == null || !mounted) return;
        final full = await FlutterContacts.getContact(contact.id);
        final phone = full?.phones.isNotEmpty == true
            ? full!.phones.first.number
            : (contact.phones.isNotEmpty ? contact.phones.first.number : '');
        if (phone.trim().isNotEmpty) {
          referralCodeController.text = phone.trim();
        }
      } else {
        // Android: load contacts in-app to avoid the OS app chooser (which can
        // show unrelated apps like TeraBox that also handle the pick intent).
        final contacts =
            await FlutterContacts.getContacts(withProperties: true);
        if (!mounted) return;
        final phone = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _ContactPickerSheet(contacts: contacts),
        );
        if (phone != null && phone.trim().isNotEmpty && mounted) {
          referralCodeController.text = phone.trim();
        }
      }
    } catch (_) {}
  }

  void register() async {
    try {
      setState(() {
        apiCalling = true;
      });
      final ApiService apiService = ApiService();

      // Validate referral code BEFORE creating account — block if invalid
      final referralCode = referralCodeController.text.trim();
      if (referralCode.isNotEmpty) {
        try {
          final validateResp =
              await apiService.validateReferralCode(referralCode);
          final validateData = validateResp.data as Map<String, dynamic>?;
          if (validateData?['valid'] != true) {
            final msg = validateData?['message'] as String? ??
                'Invalid referral code. Please check and try again.';
            if (mounted) {
              setState(() => apiCalling = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ));
            }
            return;
          }
        } catch (e) {
          // If validate endpoint fails (e.g. loyalty extension not installed), skip and proceed
          final isNotFound = e.toString().contains('404') ||
              e.toString().contains('DioExceptionType');
          if (!isNotFound) {
            // For 400 errors — code is invalid
            String errMsg =
                'Invalid referral code. Please check and try again.';
            try {
              final dioErr = e as dynamic;
              final data = dioErr.response?.data as Map<String, dynamic>?;
              if (data?['message'] != null) errMsg = data!['message'] as String;
            } catch (_) {}
            if (mounted) {
              setState(() => apiCalling = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(errMsg),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ));
            }
            return;
          }
        }
      }

      if (!isEmailLogin) {
        registerResponse = await apiService.register(
            context,
            emailController.text,
            companyController.text,
            firstNameController.text,
            lastNameController.text,
            _countryCode ?? '',
            _phoneNo ?? '',
            widget.token);

        RefreshTokenResponse refreshTokenResponse =
            await apiService.refreshToken(context, widget.token);
        SharedPreferencesUtil()
            .saveString('token', refreshTokenResponse.token!);
        SharedPreferencesUtil()
            .saveMap('customer', registerResponse?.customer?.toJson() ?? {});
      } else {
        emailRegisterResponse = await apiService.registerEmail(
            context,
            emailController.text,
            companyController.text,
            firstNameController.text,
            lastNameController.text,
            _countryCode ?? '',
            _phoneNo ?? '',
            passwordController.text);
        SharedPreferencesUtil()
            .saveString('token', emailRegisterResponse?.token ?? '');
        SharedPreferencesUtil().saveMap(
            'customer', emailRegisterResponse?.customer?.toJson() ?? {});
      }

      // Apply referral code — already validated above, should always succeed
      if (referralCode.isNotEmpty) {
        try {
          final refResp = await apiService.applyReferralCode(referralCode);
          final refData = refResp.data as Map<String, dynamic>?;
          if (mounted && refData?['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(
                  'Referral code applied! Welcome bonus points added.'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ));
          }
        } catch (_) {}
      }

      if (mounted) {
        if (widget.redirectPage != null) {
          getHomePageApi();
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
      final response = await apiService.getHomePage(context);
      await SharedPreferencesUtil()
          .saveString('region_id', response.global?.regionId ?? "");
      await SharedPreferencesUtil()
          .saveString('cart_id', response.global?.cartId ?? "");
      await SharedPreferencesUtil()
          .saveString('currency_symbol', response.global?.currencySymbol ?? "");
      await SharedPreferencesUtil()
          .saveMap('global', response.global?.toJson() ?? {});
    } catch (e) {
      print(e);
    }
  }

  Widget newToAppRegisterText({
    required VoidCallback onRegisterTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: TextSpan(
            style: FontUtils.primaryFontStyle(
              fontSize: 14,
              color: Colors.grey[700]!,
            ),
            children: [
              const TextSpan(
                text: 'Already have an account? ',
              ),
              TextSpan(
                text: 'Login',
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                recognizer: TapGestureRecognizer()..onTap = onRegisterTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Item 7 — Full-screen QR scanner used by the referral input.
// Returns the decoded string via Navigator.pop on first successful scan.
class _QrScannerSheet extends StatefulWidget {
  const _QrScannerSheet();

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final list = capture.barcodes;
    for (final b in list) {
      final raw = b.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(raw.trim());
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan Referral QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}

class _ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  const _ContactPickerSheet({required this.contacts});

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  String _query = '';

  List<Contact> get _filtered {
    final withPhone =
        widget.contacts.where((c) => c.phones.isNotEmpty).toList();
    if (_query.isEmpty) return withPhone;
    final q = _query.toLowerCase();
    return withPhone.where((c) {
      return c.displayName.toLowerCase().contains(q) ||
          c.phones.any((p) => p.number.contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Select a contact',
                style: FontUtils.primaryFontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name or number',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final c = _filtered[i];
                  final phone = c.phones.first.number;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        c.displayName.isNotEmpty
                            ? c.displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(c.displayName),
                    subtitle: Text(phone),
                    onTap: () => Navigator.pop(context, phone),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
