import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/healthcare_registration_payload.dart';

void main() {
  test('general user payload excludes doctor-only fields', () {
    final payload = buildHealthcareRegistrationPayload(
      phone: '9876543210',
      countryCode: '+91',
      firstName: ' General ',
      lastName: ' User ',
      email: ' general@example.com ',
      userType: 'general_user',
      aadhaarNumber: 'ignored',
    );

    expect(payload, {
      'phone': '9876543210',
      'country_code': '+91',
      'first_name': 'General',
      'last_name': 'User',
      'full_name': 'General User',
      'email': 'general@example.com',
      'user_type': 'general_user',
    });
  });

  test('doctor payload matches the website backend contract', () {
    final payload = buildHealthcareRegistrationPayload(
      phone: '9876543210',
      countryCode: '+91',
      firstName: 'Doctor',
      lastName: 'One',
      email: 'doctor@example.com',
      userType: 'doctor',
      aadhaarNumber: '1234',
      drugLicenceNumber: 'DL-1',
      drugLicenceValidFrom: '2026-01-01',
      drugLicenceValidTo: '2027-01-01',
      panNumber: 'PAN-1',
      gstNumber: 'GST-1',
      documentIds: const {
        'aadhaar_front_document': ['file_a_front'],
        'aadhaar_back_document': ['file_a_back'],
        'drug_licence_document': ['file_d'],
        'pan_document': ['file_p'],
        'gst_document': ['file_g'],
      },
    );

    expect(payload['user_type'], 'doctor');
    expect(payload['first_name'], 'Doctor');
    expect(payload['last_name'], 'One');
    expect(payload['full_name'], 'Doctor One');
    expect(
      payload['aadhaar_document_url'],
      '["file_a_front","file_a_back"]',
    );
    expect(payload['drug_licence_document_url'], '["file_d"]');
    expect(payload['pan_document_url'], '["file_p"]');
    expect(payload['gst_document_url'], '["file_g"]');
    expect(payload['drug_licence_valid_from'], '2026-01-01');
    expect(payload['drug_licence_valid_to'], '2027-01-01');
  });

  test('email registration adds the password and device id', () {
    final payload = buildHealthcareRegistrationPayload(
      phone: '9876543210',
      countryCode: '+91',
      firstName: 'General',
      lastName: 'User',
      email: 'general@example.com',
      userType: 'general_user',
      password: ' pass word ',
      deviceId: 'device-1',
    );

    expect(payload, {
      'phone': '9876543210',
      'country_code': '+91',
      'first_name': 'General',
      'last_name': 'User',
      'full_name': 'General User',
      'email': 'general@example.com',
      'user_type': 'general_user',
      'password': ' pass word ',
      'device_id': 'device-1',
    });
  });

  test('doctor email registration keeps the password', () {
    final payload = buildHealthcareRegistrationPayload(
      phone: '9876543210',
      countryCode: '+91',
      firstName: 'Doctor',
      lastName: 'One',
      email: 'doctor@example.com',
      userType: 'doctor',
      password: 'secret',
      deviceId: 'device-1',
    );

    expect(payload['password'], 'secret');
    expect(payload['device_id'], 'device-1');
    expect(payload['aadhaar_document_url'], '[]');
  });

  test('empty password and device id are left out of the OTP payload', () {
    for (final userType in ['general_user', 'doctor']) {
      final payload = buildHealthcareRegistrationPayload(
        phone: '9876543210',
        countryCode: '+91',
        firstName: 'Test',
        lastName: 'User',
        email: 'user@example.com',
        userType: userType,
        password: '',
        deviceId: '',
      );

      expect(payload.containsKey('password'), isFalse);
      expect(payload.containsKey('device_id'), isFalse);
    }
  });
}
