import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/splash_page.dart';
import 'package:waioz/ui/welcome_page.dart';

import '../utility/app_assets.dart';
import '../utility/page_route_utils.dart';

class ApprovalPage extends StatelessWidget {
  final String errorCode;
  const ApprovalPage({super.key,required this.errorCode});

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
                      child: const Column(
                        children: [
                          Text(
                            "Store Registration\nSubmitted!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Your store details have been submitted successfully. Our team will review them and get back to you shortly. A confirmation has been sent to your email or whatsapp",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
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
                          color: Colors.green.shade100,
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF6AC259),
                          child: Icon(Icons.check, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
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
                        backgroundColor: const Color(0xFF6AC259),
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
