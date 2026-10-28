import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/healthcare_registration_payload.dart';

void main() {
  test('general user payload excludes doctor-only fields', () {
    final payload = buildHealthcareRegistrationPayload(
      phone: '9876543210',
      countryCode: '+91',
      fullName: ' General User ',
      email: ' general@example.com ',
      userType: 'general_user',
      aadhaarNumber: 'ignored',
    );

    expect(payload, {
      'phone': '9876543210',
      'country_code': '+91',
      'full_name': 'General User',
      'email': 'general@example.com',
      'user_type': 'general_user',
    });
  });

  test('doctor payload matches the website backend contract', () {
    final payload = buildHealthcareRegistrationPayload(
      phone: '9876543210',
      countryCode: '+91',
      fullName: 'Doctor One',
      email: 'doctor@example.com',
      userType: 'doctor',
      aadhaarNumber: '1234',
      drugLicenceNumber: 'DL-1',
      drugLicenceValidFrom: '2026-01-01',
      drugLicenceValidTo: '2027-01-01',
      panNumber: 'PAN-1',
      gstNumber: 'GST-1',
      documentIds: const {
        'aadhaar_document': ['file_a'],
        'drug_licence_document': ['file_d1', 'file_d2'],
        'pan_document': ['file_p'],
        'gst_document': ['file_g'],
      },
    );

    expect(payload['user_type'], 'doctor');
    expect(payload['aadhaar_document_url'], '["file_a"]');
    expect(payload['drug_licence_document_url'], '["file_d1","file_d2"]');
    expect(payload['pan_document_url'], '["file_p"]');
    expect(payload['gst_document_url'], '["file_g"]');
    expect(payload['drug_licence_valid_from'], '2026-01-01');
    expect(payload['drug_licence_valid_to'], '2027-01-01');
  });
}
