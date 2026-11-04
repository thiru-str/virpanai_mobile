import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waioz/model/healthcare_registration_payload.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'package:waioz/utility/app_strings.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/registration_input_formatters.dart';
import '../utility/registration_validators.dart';
import '../utility/shared_preferences_util.dart';
import '../utility/ui_typography.dart';
import 'bottom_nav_page.dart';

class _HealthcareDocument {
  final String id;
  final String name;
  final String? localPath;
  final String? url;

  const _HealthcareDocument({
    required this.id,
    required this.name,
    this.localPath,
    this.url,
  });

  bool get isImage {
    final normalizedName = name.toLowerCase();
    return normalizedName.endsWith('.jpg') ||
        normalizedName.endsWith('.jpeg') ||
        normalizedName.endsWith('.png') ||
        normalizedName.endsWith('.webp');
  }
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
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
  bool isEmailLogin = false;
  bool _loginTypeLoaded = false;
  bool _healthcareSubmitted = false;
  String _userType = 'general_user';
  final Map<String, List<_HealthcareDocument>> _healthcareDocuments = {};
  final Map<String, bool> _uploadingHealthcareDocuments = {};
  final Set<String> _healthcareDocumentErrors = {};
  String? _phoneNo;
  String? _countryCode;
  bool _phoneMissing = false;

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

    return _buildHealthcareRegistrationPage();
  }

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
                        // Email sign-up sits directly above the login page,
                        // which is not the first route.
                        onPressed: () => isEmailLogin
                            ? Navigator.pop(context)
                            : Navigator.of(context)
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
                        labelText: 'First Name',
                        hintText: 'Enter first name',
                        controller: firstNameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter First Name'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Last Name',
                        hintText: 'Enter last name',
                        controller: lastNameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter Last Name'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: AppStrings.email,
                        hintText: 'Enter email address',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        validator: validateRegistrationEmail,
                      ),
                      if (isEmailLogin) ..._buildEmailCredentialFields(),
                      if (isDoctor) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          labelText: 'Aadhaar Number',
                          hintText: 'Enter 12-digit Aadhaar number',
                          controller: aadhaarNumberController,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          validator: validateAadhaarNumber,
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'aadhaar_front_document',
                          label: 'Aadhaar Front',
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'aadhaar_back_document',
                          label: 'Aadhaar Back',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          labelText: 'Drug Licence Number',
                          hintText: 'Enter drug licence number',
                          controller: drugLicenceNumberController,
                          keyboardType: TextInputType.visiblePassword,
                          textCapitalization: TextCapitalization.characters,
                          autocorrect: false,
                          enableSuggestions: false,
                          maxLength: 50,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9/-]'),
                            ),
                            const UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(50),
                          ],
                          validator: validateDrugLicenceNumber,
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
                          validator: validateDrugLicenceValidFrom,
                        ),
                        const SizedBox(height: 16),
                        _buildHealthcareDateField(
                          label: 'Drug Licence Valid To',
                          controller: drugLicenceValidToController,
                          validator: (value) => validateDrugLicenceValidTo(
                            value,
                            drugLicenceValidFromController.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          labelText: 'PAN Number',
                          hintText: 'Enter PAN number',
                          controller: panNumberController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9]'),
                            ),
                            const UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: validatePanNumber,
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'pan_document',
                          label: 'PAN Upload',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          labelText: 'GST Number',
                          hintText: 'Enter GST number',
                          controller: gstNumberController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 15,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9]'),
                            ),
                            const UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: validateGstNumber,
                        ),
                        const SizedBox(height: 12),
                        _buildHealthcareDocumentField(
                          field: 'gst_document',
                          label: 'GST Upload',
                        ),
                      ],
                      if (isEmailLogin) ...[
                        const SizedBox(height: 16),
                        newToAppRegisterText(onRegisterTap: () {
                          Navigator.pop(context);
                        }),
                        // A doctor is not signed in, so a referral cannot be
                        // applied.
                        if (!isDoctor) ...[
                          const SizedBox(height: 16),
                          _buildReferralField(),
                        ],
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

  List<Widget> _buildEmailCredentialFields() {
    return [
      const SizedBox(height: 16),
      IntlPhoneField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          labelText: AppStrings.mobile_number,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: UiTypography.searchHint().copyWith(
            color: AppColors.textColor,
          ),
          floatingLabelStyle: UiTypography.searchHint().copyWith(
            color: AppColors.primary,
          ),
          hintText: 'Enter mobile number',
          hintStyle: UiTypography.searchHint(),
          fillColor: Colors.white,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          // IntlPhoneField reports no error for an untouched field, so the
          // submit guard supplies it.
          errorText: _phoneMissing ? AppStrings.enter_valid_mob_no : null,
        ),
        initialCountryCode: AppStrings.country_code,
        onChanged: (phone) {
          _phoneNo = phone.number;
          _countryCode = phone.countryCode;
          if (_phoneMissing) setState(() => _phoneMissing = false);
        },
        // Picking a country does not fire onChanged.
        onCountryChanged: (country) {
          _countryCode = '+${country.fullCountryCode}';
        },
        validator: (value) {
          if (value == null || value.number.isEmpty) {
            return AppStrings.enter_valid_mob_no;
          }
          if (value.number.length < 10 || value.number.length > 15) {
            return AppStrings.digit_range;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        labelText: AppStrings.password,
        hintText: 'Enter password',
        controller: passwordController,
        textCapitalization: TextCapitalization.none,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),
          ),
          LengthLimitingTextInputFormatter(128),
        ],
        isPassword: true,
        validator: (value) => validateRegistrationPassword(
          value,
          requiredMessage: AppStrings.password_required,
        ),
      ),
      const SizedBox(height: 16),
      CustomTextField(
        labelText: AppStrings.confirm_password,
        hintText: 'Re-enter password',
        controller: confirmPasswordController,
        textCapitalization: TextCapitalization.none,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),
          ),
          LengthLimitingTextInputFormatter(128),
        ],
        isPassword: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.confirm_password_required;
          }
          if (value != passwordController.text) {
            return AppStrings.password_mismatch;
          }
          return null;
        },
      ),
    ];
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
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectHealthcareDate(controller),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: UiTypography.searchHint().copyWith(
          color: AppColors.textColor,
        ),
        floatingLabelStyle: UiTypography.searchHint().copyWith(
          color: AppColors.primary,
        ),
        hintText: 'Select date',
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
      validator: validator,
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
          if (documents.isEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: uploading
                      ? null
                      : () => _pickAndUploadHealthcareDocument(field),
                  icon: uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_outlined),
                  label: Text(uploading ? 'Uploading...' : 'Choose file'),
                ),
                OutlinedButton.icon(
                  onPressed: uploading
                      ? null
                      : () => _takeAndUploadHealthcareDocument(field),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take photo'),
                ),
              ],
            ),
          Text(
            'JPG, PNG, WebP or PDF. One file only.',
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
                    if (document.isImage)
                      InkWell(
                        key:
                            ValueKey('preview-thumbnail-$field-${document.id}'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showHealthcareDocumentPreview(document),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: _buildHealthcareDocumentImage(document),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Colors.red.shade700,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.secondaryFontStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            document.isImage
                                ? 'Tap to preview'
                                : 'PDF uploaded',
                            style: FontUtils.secondaryFontStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (document.isImage)
                      IconButton(
                        key: ValueKey('preview-$field-${document.id}'),
                        tooltip: 'Preview ${document.name}',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        onPressed: () =>
                            _showHealthcareDocumentPreview(document),
                      ),
                    IconButton(
                      key: ValueKey('remove-$field-${document.id}'),
                      tooltip: 'Remove ${document.name}',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: uploading
                          ? null
                          : () => _removeHealthcareDocument(field, document),
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

  Widget _buildHealthcareDocumentImage(
    _HealthcareDocument document, {
    BoxFit fit = BoxFit.cover,
  }) {
    final localPath = document.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: fit,
        errorBuilder: (_, __, ___) => _documentPreviewError(),
      );
    }

    final url = document.url;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _documentPreviewError(),
      );
    }

    return _documentPreviewError();
  }

  Widget _documentPreviewError() => Container(
        color: const Color(0xFFF3F4F6),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      );

  Future<void> _showHealthcareDocumentPreview(
    _HealthcareDocument document,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final screenSize = MediaQuery.sizeOf(dialogContext);
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.75,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Center(
                      child: _buildHealthcareDocumentImage(
                        document,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    tooltip: 'Close preview',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeHealthcareDocument(
    String field,
    _HealthcareDocument document,
  ) {
    setState(() {
      final documents = [...?_healthcareDocuments[field]]
        ..removeWhere((item) => item.id == document.id);
      if (documents.isEmpty) {
        _healthcareDocuments.remove(field);
      } else {
        _healthcareDocuments[field] = documents;
      }
    });
  }

  Future<void> _pickAndUploadHealthcareDocument(String field) async {
    final selection = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (selection == null || selection.files.isEmpty || !mounted) return;

    final selectedFile = selection.files.single;
    final path = selectedFile.path;
    if (path == null) return;
    await _uploadHealthcareDocument(
      field: field,
      path: path,
      name: selectedFile.name,
    );
  }

  Future<void> _takeAndUploadHealthcareDocument(String field) async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo == null || !mounted) return;
      await _uploadHealthcareDocument(
        field: field,
        path: photo.path,
        name: photo.name,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to take photo: ${_cleanError(error)}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _uploadHealthcareDocument({
    required String field,
    required String path,
    required String name,
  }) async {
    if ((_healthcareDocuments[field] ?? const []).isNotEmpty) return;

    setState(() => _uploadingHealthcareDocuments[field] = true);
    try {
      final response = await ApiService().uploadHealthcareDocument(
        context,
        File(path),
        field,
      );
      final id = response['id']?.toString() ?? '';
      if (!mounted) return;
      if (id.isNotEmpty) {
        final url =
            response['url']?.toString() ?? response['path']?.toString() ?? '';
        setState(() {
          _healthcareDocuments[field] = [
            _HealthcareDocument(
              id: id,
              name: name,
              localPath: path,
              url: url,
            ),
          ];
          _healthcareDocumentErrors.remove(field);
        });
      }
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
      'aadhaar_front_document',
      'aadhaar_back_document',
      'drug_licence_document',
      'pan_document',
      'gst_document',
    ];
    final missingDocuments = _userType == 'doctor'
        ? requiredDocuments
            .where((field) => (_healthcareDocuments[field] ?? []).isEmpty)
            .toSet()
        : <String>{};

    final phoneMissing = isEmailLogin && (_phoneNo ?? '').isEmpty;

    setState(() {
      _phoneMissing = phoneMissing;
      _healthcareDocumentErrors
        ..clear()
        ..addAll(missingDocuments);
    });
    if (!formValid || phoneMissing || missingDocuments.isNotEmpty) return;

    final referralCode = isEmailLogin && _userType != 'doctor'
        ? referralCodeController.text.trim()
        : '';
    final payload = buildHealthcareRegistrationPayload(
      phone: isEmailLogin ? _phoneNo ?? '' : widget.phoneNo,
      countryCode: isEmailLogin ? _countryCode ?? '' : widget.countryCode,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
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
      password: isEmailLogin ? passwordController.text : '',
    );

    setState(() => apiCalling = true);
    try {
      // Validate the referral BEFORE creating the account — block if invalid.
      if (!await _isReferralCodeAccepted(referralCode)) return;
      if (!mounted) return;

      final response =
          await ApiService().registerHealthcareUser(context, payload);
      if (!mounted) return;
      if (response['success'] == true) {
        // Only a doctor waits for an administrator; a general user is signed
        // in and goes to the shop. (An older backend sends no flag — the
        // user type decides.)
        final needsApproval = response['approval_required'] is bool
            ? response['approval_required'] as bool
            : _userType == 'doctor';
        if (needsApproval) {
          setState(() => _healthcareSubmitted = true);
        } else if (isEmailLogin) {
          await _finishEmailRegistration(
            response['token']?.toString() ?? '',
            referralCode,
          );
        } else {
          await _signInAfterHealthcareRegistration();
        }
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_registrationError(error)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => apiCalling = false);
    }
  }

  /// The password registration signs a general user in itself; the token is
  /// empty when the account was created but that sign-in failed.
  Future<void> _finishEmailRegistration(
    String token,
    String referralCode,
  ) async {
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account was created. Please log in to continue.'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    await SharedPreferencesUtil().saveString('token', token);
    await _applyReferralCode(referralCode);
    if (!mounted) return;
    await _saveCustomer();
    if (!mounted) return;
    await getHomePageApi();
    if (!mounted) return;
    PageRouteUtils.pushAndRemoveUntil(
        context, widget.redirectPage ?? const BottomNavPage());
  }

  /// The cart and favourites read the stored customer, and a redirect page
  /// does not pass through BottomNavPage to fetch it. The shopper is already
  /// signed in, so a failure here does not stop them.
  Future<void> _saveCustomer() async {
    try {
      final response = await ApiService().getCustomer(context);
      final customer = response.customer;
      if (customer != null) {
        await SharedPreferencesUtil().saveMap('customer', customer.toJson());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// False when the code is invalid, and the shopper has been told why. A
  /// validate endpoint that cannot answer (e.g. loyalty extension not
  /// installed) does not stop the registration.
  Future<bool> _isReferralCodeAccepted(String referralCode) async {
    if (referralCode.isEmpty) return true;
    const invalidMessage = 'Invalid referral code. Please check and try again.';
    try {
      final validateResp =
          await ApiService().validateReferralCode(referralCode);
      final validateData = validateResp.data as Map<String, dynamic>?;
      if (validateData?['valid'] == true) return true;
      _showReferralError(validateData?['message'] as String? ?? invalidMessage);
      return false;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == null || status == 404 || status >= 500) return true;
      final data = error.response?.data;
      final message = data is Map ? data['message'] : null;
      _showReferralError(message is String ? message : invalidMessage);
      return false;
    } catch (_) {
      _showReferralError(invalidMessage);
      return false;
    }
  }

  void _showReferralError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // Already validated before the account was created, so this should succeed.
  Future<void> _applyReferralCode(String referralCode) async {
    if (referralCode.isEmpty) return;
    try {
      final refResp = await ApiService().applyReferralCode(referralCode);
      final refData = refResp.data as Map<String, dynamic>?;
      if (mounted && refData?['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              const Text('Referral code applied! Welcome bonus points added.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (_) {}
  }

  /// The registration linked this phone's auth identity to the new customer,
  /// so the registration token refreshes into a customer token — the same
  /// step the standard sign-up takes.
  Future<void> _signInAfterHealthcareRegistration() async {
    final apiService = ApiService();
    final refreshed = await apiService.refreshToken(context, widget.token);
    final token = refreshed.token ?? '';
    if (token.isEmpty)
      throw Exception('Registered. Please log in to continue.');
    await SharedPreferencesUtil().saveString('token', token);
    await getHomePageApi();
    if (!mounted) return;
    PageRouteUtils.pushAndRemoveUntil(
        context, widget.redirectPage ?? const BottomNavPage());
  }

  List<String> _documentIds(String field) => (_healthcareDocuments[field] ?? [])
      .map((document) => document.id)
      .toList();

  String _cleanError(Object error) =>
      error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');

  /// The request layer wraps transport failures in text not meant for the
  /// shopper; it has already shown any message the backend sent.
  String _registrationError(Object error) {
    final message = _cleanError(error);
    return isEmailLogin && message.startsWith('An error occurred:')
        ? 'Unable to complete registration. Please try again.'
        : message;
  }

  // Item 7 — Referral input with inline QR scan + contact picker icons.
  // Field accepts either a unique code or a phone number; backend resolves.
  Widget _buildReferralField() {
    return TextField(
      controller: referralCodeController,
      style: FontUtils.primaryFontStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Referral Code or Phone',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: FontUtils.primaryFontStyle(
          fontSize: 14,
          color: AppColors.textColor,
        ),
        floatingLabelStyle: FontUtils.primaryFontStyle(
          fontSize: 14,
          color: AppColors.primary,
        ),
        hintText: 'Enter referral code or phone (optional)',
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

  Future<void> getHomePageApi() async {
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
