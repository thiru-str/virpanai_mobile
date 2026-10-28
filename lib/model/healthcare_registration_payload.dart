import 'dart:convert';

Map<String, dynamic> buildHealthcareRegistrationPayload({
  required String phone,
  required String countryCode,
  required String fullName,
  required String email,
  required String userType,
  String aadhaarNumber = '',
  String drugLicenceNumber = '',
  String drugLicenceValidFrom = '',
  String drugLicenceValidTo = '',
  String panNumber = '',
  String gstNumber = '',
  Map<String, List<String>> documentIds = const {},
}) {
  final payload = <String, dynamic>{
    'phone': phone,
    'country_code': countryCode,
    'full_name': fullName.trim(),
    'email': email.trim(),
    'user_type': userType,
  };

  if (userType != 'doctor') return payload;

  payload.addAll({
    'aadhaar_number': aadhaarNumber.trim(),
    'aadhaar_document_url':
        jsonEncode(documentIds['aadhaar_document'] ?? const <String>[]),
    'drug_licence_number': drugLicenceNumber.trim(),
    'drug_licence_document_url':
        jsonEncode(documentIds['drug_licence_document'] ?? const <String>[]),
    'drug_licence_valid_from': drugLicenceValidFrom,
    'drug_licence_valid_to': drugLicenceValidTo,
    'pan_number': panNumber.trim(),
    'pan_document_url':
        jsonEncode(documentIds['pan_document'] ?? const <String>[]),
    'gst_number': gstNumber.trim(),
    'gst_document_url':
        jsonEncode(documentIds['gst_document'] ?? const <String>[]),
  });

  return payload;
}
