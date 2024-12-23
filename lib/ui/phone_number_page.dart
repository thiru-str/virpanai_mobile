import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:waioz/ui/otp_verification_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

class PhoneNumberPage extends StatefulWidget {
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white, // Full page background color
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Title
            Text(
              'Enter your mobile\nnumber',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Form for phone input
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // IntlPhoneField for phone input
                  IntlPhoneField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.secondary, // Full background color
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12), // Adjust content padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none, // Remove border
                      ),
                    ),
                    initialCountryCode: 'IN', // Default country code
                    showDropdownIcon: false,
                    onChanged: (phone) {
                      setState(() {
                        _phoneNumber = phone.completeNumber; // Full phone number
                      });
                    },
                    validator: (value) {
                      if (value == null || value.number.isEmpty) {
                        return 'Please enter a valid phone number';
                      } else if (value.number.length < 10 ||
                          value.number.length > 15) {
                        return 'Phone number must be between 10 to 15 digits';
                      }
                      return null;
                    },
                    dropdownTextStyle: FontUtils.circularStdStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const Spacer(),
            // Submit button
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Proceed if validation passes
                    print('Phone Number: $_phoneNumber');
                    PageRouteUtils.push(context, OtpVerificationPage());
                  }
                },
                backgroundColor: Color(0xFF6A4BF6), // Purple color
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
