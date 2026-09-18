import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

  final TextEditingController referralCodeController = TextEditingController();

  bool apiCalling = false;
  RegisterResponse? registerResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(AppAssets.ic_arrow_svg, height: 16, width: 16),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.register_msg,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  hintText: AppStrings.firstname,
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
                  hintText: AppStrings.email,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter email';
                    }

                    final emailRegex =
                        RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

                    if (!emailRegex.hasMatch(value)) {
                      return AppStrings.enter_valid_email;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildReferralField(),
                const SizedBox(height: 16),
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
                    AppStrings.register,
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
      ),
    );
  }

  // Item 7 — Referral input with inline QR scan + contact picker icons.
  // Field accepts either a unique code or a phone number; backend resolves.
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
                  Icon(Icons.lock_outline, size: 12, color: Colors.grey.shade400),
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
      final ApiService apiService = ApiService();
      // registerResponse = await apiService.register(
      //     context,
      //     emailController.text,
      //     companyController.text,
      //     firstNameController.text,
      //     lastNameController.text,
      //     widget.countryCode,
      //     widget.phoneNo,
      //     widget.token);

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

      registerResponse = await apiService.register(
          context,
          emailController.text,
          companyController.text,
          firstNameController.text,
          lastNameController.text,
          widget.countryCode,
          widget.phoneNo,
          widget.token,
          companyController.text,
          '',
          '',
          '',
          false,
          '',
          '',
          '',
          '',
          '');
      final refreshTokenResponse =
          await apiService.refreshToken(context, widget.token);
      await SharedPreferencesUtil().saveString('token', refreshTokenResponse.token!);
      await SharedPreferencesUtil().saveMap(
          'customer', registerResponse?.customer?.toJson() ?? {});

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
          setState(() {
            apiCalling = true;
          });
          await getHomePageApi();
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

  Future<void> getHomePageApi() async {
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
    final withPhone = widget.contacts.where((c) => c.phones.isNotEmpty).toList();
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
