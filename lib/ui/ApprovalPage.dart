import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/splash_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_colors.dart';

import '../utility/app_assets.dart';
import '../utility/page_route_utils.dart';

class ApprovalPage extends StatelessWidget {
  final String errorCode;
  final bool isFromDealer;
  const ApprovalPage({super.key,required this.errorCode,this.isFromDealer = false});

  String _getStatusText() {
    final prefix = isFromDealer ? "Dealer" : "Agent";
    switch (errorCode) {
      case '00004':
        return "$prefix Registration\nSubmitted!";
      case '00005':
        return "$prefix Registration\nRejected!";
      case '00006':
        return "$prefix Registration\nBlocked!";
      default:
        return "$prefix Registration \nSubmitted!";
    }
  }

  String _getStatusDesc() {
    final prefix = isFromDealer ? "Dealer" : "Agent";
    switch (errorCode) {
      case '00004':
        return 'Your $prefix details have been submitted successfully. Our team will review them and get back to you shortly. A confirmation has been sent to your email or whatsapp';
      case '00005':
        return 'Please review your details and try again. If this seems like a mistake, contact our support team.We’ve sent you a message via email or WhatsApp.';
      case '00006':
        return "This may be due to a policy issue or unusual activity.lf this seems incorrect, please contact support.We've sent you a notification via email or WhatsApp.";
      default:
        return 'Your store details have been submitted successfully. Our team will review them and get back to you shortly. A confirmation has been sent to your email or whatsapp';
    }
  }

  Color _getStatusColor() {
    switch (errorCode) {
      case '00005':
      case '00006':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF69BC46);
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 48;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top green circle
          Positioned(
            top: -30,
            right: 0,
            child: SvgPicture.asset(
              AppAssets.bg_top,
            ),
          ),
          // Bottom teal circle
          Positioned(
            bottom: -10,
            left: -10,
            child: SvgPicture.asset(
              AppAssets.bg_bottom,
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Layered card with teal visible ONLY on top-left
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Teal shadow container (shifted UP & LEFT)
                    Positioned(
                      top: -10,
                      left: -10,
                      child: Container(
                        width: cardWidth + 10,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFF075E66),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // White foreground card
                    Container(
                      width: cardWidth,
                      padding: const EdgeInsets.fromLTRB(16, 86, 16, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getStatusText(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getStatusDesc(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Floating green check icon
                    Positioned(
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor().withValues(alpha: 0.25),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: _getStatusColor(),
                          child: const Icon(Icons.check, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: errorCode == '00005' || errorCode == '00006',
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Have an issue? '),
                        TextSpan(
                          text: 'Please contact us',
                          style: TextStyle(
                            color: AppColors.primary, // Make clickable part stand out
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Add your contact action here

                            },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ Green button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Back To Home",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }



}
