import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/otp_verification_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';

class PhoneNumberPage extends StatefulWidget {
  final Widget? redirectPage;
  const PhoneNumberPage({super.key,this.redirectPage});

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneNumber;
  String? _countryCode;

  SendOtpResponse? sendOtpResponse;
  bool apiCalling = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevents Stack from resizing on keyboard open
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: Stack(
        children: [

          Positioned(top: 0, right: 0, child: SvgPicture.asset(AppAssets.bg_top)),
          Positioned(bottom: 0, left: 0, child: SvgPicture.asset(AppAssets.bg_bottom)),

          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.7)),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Enter your customer mobile number',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.mobile_number,
                                    style: FontUtils.primaryFontStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700]!,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IntlPhoneField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: AppColors.primary, width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: AppColors.primary, width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: AppColors.primary, width: 1.5),
                                      ),
                                    ),
                                    initialCountryCode: AppStrings.country_code,
                                    showDropdownIcon: true,
                                    onChanged: (phone) {
                                      setState(() {
                                        _phoneNumber = phone.number;
                                        _countryCode = phone.countryCode;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.number.isEmpty) {
                                        return AppStrings.enter_valid_mob_no;
                                      } else if (value.number.length < 10 ||
                                          value.number.length > 15) {
                                        return AppStrings.digit_range;
                                      }
                                      return null;
                                    },
                                    dropdownTextStyle: FontUtils.primaryFontStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 60,
            right: 24,
            child: FloatingActionButton(
              elevation: 0,
              shape: const CircleBorder(),
              backgroundColor: AppColors.primary,
              onPressed: () {
                AppLogger.print('pressed', 'message');
                if (_formKey.currentState!.validate()) {
                  if (_phoneNumber != null) {
                    sendOtp();
                  } else {
                    AppUtils.showToast(AppStrings.enter_mob_no);
                  }
                }
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );


  }

  void sendOtp() async {
    try {
      final ApiService apiService = ApiService();
      sendOtpResponse =
          await apiService.sendOtp(context, _countryCode!, _phoneNumber!);
      setState(() {
        apiCalling = false;
      });

      final result = await PageRouteUtils.pushWithSlide(
          context,
          OtpVerificationPage(
            countryCode: _countryCode!,
            phoneNo: _phoneNumber!,
            otp: sendOtpResponse!.otp!,
            redirectPage:widget.redirectPage,
          ));
      if(result == true)
        {
          Navigator.pop(context,true);
        }

    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }

}
