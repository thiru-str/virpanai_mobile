import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waioz/model/email_register_response.dart';
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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();


  bool apiCalling = false;
  RegisterResponse? registerResponse;
  EmailRegisterResponse? emailRegisterResponse;
  bool isEmailLogin = false;
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
    final loginType = await SharedPreferencesUtil().getBool('email_login')?? false;
    setState(() {
      isEmailLogin = loginType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                      if (!RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return AppStrings.enter_valid_email;
                      }
                      return null;
                    },
                  ),
                  if (isEmailLogin) ...[
                    const SizedBox(height: 16),

                    IntlPhoneField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        fillColor: AppColors.secondary,
                        filled: true,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: AppColors.secondary, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: AppColors.secondary, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: AppColors.secondary, width: 1.5),
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
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),)],
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
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),)],
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
                  const SizedBox(height: 16),
                  apiCalling?Center(child: CircularProgressIndicator(color: AppColors.primary,),):ElevatedButton(
                    onPressed:() {
                      if (_formKey.currentState!.validate()) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Icon(Icons.contacts_rounded, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              'Find your referrer easily',
              style: FontUtils.primaryFontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a contact whose phone number is registered as a referrer. '
              'We do not store or share your contact list.',
              style: FontUtils.secondaryFontStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Allow'),
                  ),
                ),
              ],
            ),
          ],
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
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null || !mounted) return;
      final full = await FlutterContacts.getContact(contact.id);
      final phone = full?.phones.isNotEmpty == true
          ? full!.phones.first.number
          : (contact.phones.isNotEmpty ? contact.phones.first.number : '');
      if (phone.trim().isNotEmpty) {
        referralCodeController.text = phone.trim();
      }
    } catch (_) {
      // External pick may not be available on all OEMs — fall through silently.
    }
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
          final validateResp = await apiService.validateReferralCode(referralCode);
          final validateData = validateResp.data as Map<String, dynamic>?;
          if (validateData?['valid'] != true) {
            final msg = validateData?['message'] as String? ?? 'Invalid referral code. Please check and try again.';
            if (mounted) {
              setState(() => apiCalling = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            }
            return;
          }
        } catch (e) {
          // If validate endpoint fails (e.g. loyalty extension not installed), skip and proceed
          final isNotFound = e.toString().contains('404') || e.toString().contains('DioExceptionType');
          if (!isNotFound) {
            // For 400 errors — code is invalid
            String errMsg = 'Invalid referral code. Please check and try again.';
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            }
            return;
          }
        }
      }

      if(!isEmailLogin) {
        registerResponse = await apiService.register(
            context,
            emailController.text,
            companyController.text,
            firstNameController.text,
            lastNameController.text,
            _countryCode??'',
            _phoneNo??'',
            widget.token);

        RefreshTokenResponse refreshTokenResponse =
        await apiService.refreshToken(context, widget.token);
        SharedPreferencesUtil().saveString('token', refreshTokenResponse.token!);
        SharedPreferencesUtil()
            .saveMap('customer', registerResponse?.customer?.toJson() ?? {});
      }
      else{
        emailRegisterResponse = await apiService.registerEmail(
            context,
            emailController.text,
            companyController.text,
            firstNameController.text,
            lastNameController.text,
            _countryCode??'',
            _phoneNo??'',
            passwordController.text);
        SharedPreferencesUtil().saveString('token', emailRegisterResponse?.token??'');
        SharedPreferencesUtil()
            .saveMap('customer', emailRegisterResponse?.customer?.toJson() ?? {});
      }


      // Apply referral code — already validated above, should always succeed
      if (referralCode.isNotEmpty) {
        try {
          final refResp = await apiService.applyReferralCode(referralCode);
          final refData = refResp.data as Map<String, dynamic>?;
          if (mounted && refData?['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Referral code applied! Welcome bonus points added.'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                recognizer: TapGestureRecognizer()
                  ..onTap = onRegisterTap,
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
