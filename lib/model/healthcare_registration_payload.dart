import 'dart:convert';

Map<String, dynamic> buildHealthcareRegistrationPayload({
  required String phone,
  required String countryCode,
  required String firstName,
  required String lastName,
  required String email,
  required String userType,
  String aadhaarNumber = '',
  String drugLicenceNumber = '',
  String drugLicenceValidFrom = '',
  String drugLicenceValidTo = '',
  String panNumber = '',
  String gstNumber = '',
  Map<String, List<String>> documentIds = const {},
  String password = '',
  String deviceId = '',
}) {
  final normalizedFirstName = firstName.trim();
  final normalizedLastName = lastName.trim();

  final payload = <String, dynamic>{
    'phone': phone,
    'country_code': countryCode,
    'first_name': normalizedFirstName,
    'last_name': normalizedLastName,
    'full_name': [normalizedFirstName, normalizedLastName]
        .where((part) => part.isNotEmpty)
        .join(' '),
    'email': email.trim(),
    'user_type': userType,
    if (password.isNotEmpty) 'password': password,
    if (deviceId.isNotEmpty) 'device_id': deviceId,
  };

  if (userType != 'doctor') return payload;

  final aadhaarDocumentIds = <String>[
    ...documentIds['aadhaar_front_document'] ?? const <String>[],
    ...documentIds['aadhaar_back_document'] ?? const <String>[],
  ];

  payload.addAll({
    'aadhaar_number': aadhaarNumber.trim(),
    'aadhaar_document_url': jsonEncode(aadhaarDocumentIds),
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
