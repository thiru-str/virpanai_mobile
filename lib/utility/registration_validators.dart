/// Pure validation helpers shared by the login and registration forms.
///
/// These functions deliberately validate the submitted value as entered. In
/// particular, email whitespace is rejected instead of silently trimmed.
String? validateRegistrationEmail(
  String? value, {
  String requiredMessage = 'Please enter Email',
  String invalidMessage = 'Please enter a valid email',
}) {
  final email = value ?? '';
  if (email.isEmpty) return requiredMessage;
  if (RegExp(r'\s').hasMatch(email) ||
      !RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
          .hasMatch(email)) {
    return invalidMessage;
  }
  return null;
}

String? validateRegistrationPassword(
  String? value, {
  String requiredMessage = 'Password is required',
}) {
  final password = value ?? '';
  if (password.isEmpty) return requiredMessage;
  if (password.length < 8 || password.length > 128) {
    return 'Password must be between 8 and 128 characters';
  }
  return null;
}

String? validateAadhaarNumber(String? value) {
  final aadhaar = value ?? '';
  if (aadhaar.isEmpty) return 'Please enter Aadhaar Number';
  if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
    return 'Aadhaar Number must contain exactly 12 digits';
  }
  return null;
}

String? validateDrugLicenceNumber(String? value) {
  final licence = value ?? '';
  if (licence.isEmpty) return 'Please enter Drug Licence Number';
  if (!RegExp(r'^[A-Z0-9/-]{3,50}$').hasMatch(licence)) {
    return 'Use 3-50 uppercase letters, numbers, / or -';
  }
  return null;
}

String? validatePanNumber(String? value) {
  final pan = value ?? '';
  if (pan.isEmpty) return 'Please enter PAN Number';
  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
    return 'Enter a valid 10-character PAN Number';
  }
  return null;
}

String? validateGstNumber(String? value) {
  final gst = value ?? '';
  if (gst.isEmpty) return 'Please enter GST Number';
  if (!RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  ).hasMatch(gst)) {
    return 'Enter a valid 15-character GST Number';
  }
  return null;
}

String? validateDrugLicenceValidFrom(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter Drug Licence Valid From';
  }
  if (parseRegistrationDate(value) == null) {
    return 'Enter a valid Drug Licence Valid From date';
  }
  return null;
}

String? validateDrugLicenceValidTo(
  String? value,
  String? validFrom, {
  DateTime? today,
}) {
  if (value == null || value.isEmpty) {
    return 'Please enter Drug Licence Valid To';
  }

  final validToDate = parseRegistrationDate(value);
  if (validToDate == null) {
    return 'Enter a valid Drug Licence Valid To date';
  }

  final validFromDate = parseRegistrationDate(validFrom ?? '');
  if (validFromDate != null && validToDate.isBefore(validFromDate)) {
    return 'Valid To date cannot be before Valid From date';
  }

  final current = today ?? DateTime.now();
  final currentDate = DateTime(current.year, current.month, current.day);
  if (validToDate.isBefore(currentDate)) {
    return 'Drug Licence has expired';
  }
  return null;
}

/// Parses a strict `yyyy-MM-dd` calendar date without normalising impossible
/// values such as 2026-02-30.
DateTime? parseRegistrationDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return parsed;
}
