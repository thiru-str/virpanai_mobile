import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/utility/registration_input_formatters.dart';
import 'package:waioz/utility/registration_validators.dart';

void main() {
  group('registration email validation', () {
    test('accepts a conventional email address', () {
      expect(validateRegistrationEmail('doctor@example.com'), isNull);
    });

    test('rejects leading, trailing, and internal whitespace', () {
      expect(validateRegistrationEmail(' doctor@example.com'), isNotNull);
      expect(validateRegistrationEmail('doctor@example.com '), isNotNull);
      expect(validateRegistrationEmail('doctor @example.com'), isNotNull);
    });
  });

  group('registration password validation', () {
    test('accepts the 8 and 128 character boundaries', () {
      expect(validateRegistrationPassword('a' * 8), isNull);
      expect(validateRegistrationPassword('a' * 128), isNull);
    });

    test('rejects values outside the 8 to 128 character range', () {
      expect(validateRegistrationPassword('a' * 7), isNotNull);
      expect(validateRegistrationPassword('a' * 129), isNotNull);
    });
  });

  group('doctor identifier validation', () {
    test('Aadhaar must contain exactly 12 digits', () {
      expect(validateAadhaarNumber('123456789012'), isNull);
      expect(validateAadhaarNumber('12345678901'), isNotNull);
      expect(validateAadhaarNumber('12345678901A'), isNotNull);
    });

    test('drug licence allows only the supported uppercase format', () {
      expect(validateDrugLicenceNumber('TN-12/3456'), isNull);
      expect(validateDrugLicenceNumber('ab-123'), isNotNull);
      expect(validateDrugLicenceNumber('AB 123'), isNotNull);
      expect(validateDrugLicenceNumber('AB'), isNotNull);
    });

    test('PAN follows the standard ten-character format', () {
      expect(validatePanNumber('ABCDE1234F'), isNull);
      expect(validatePanNumber('ABCD1234EF'), isNotNull);
      expect(validatePanNumber('abcde1234f'), isNotNull);
    });

    test('GSTIN follows the standard PAN-based 15-character format', () {
      expect(validateGstNumber('33ABCDE1234F1Z5'), isNull);
      expect(validateGstNumber('3ABCDE1234F1Z5'), isNotNull);
      expect(validateGstNumber('33abcde1234f1z5'), isNotNull);
    });
  });

  group('drug licence date validation', () {
    final today = DateTime(2026, 11, 4);

    test('rejects impossible calendar dates', () {
      expect(validateDrugLicenceValidFrom('2026-02-30'), isNotNull);
      expect(
        validateDrugLicenceValidTo(
          '2026-02-30',
          '2026-01-01',
          today: today,
        ),
        isNotNull,
      );
    });

    test('valid-to cannot precede valid-from', () {
      expect(
        validateDrugLicenceValidTo(
          '2027-01-01',
          '2027-01-02',
          today: today,
        ),
        'Valid To date cannot be before Valid From date',
      );
    });

    test('valid-to cannot be expired and may be today', () {
      expect(
        validateDrugLicenceValidTo(
          '2026-11-03',
          '2026-01-01',
          today: today,
        ),
        'Drug Licence has expired',
      );
      expect(
        validateDrugLicenceValidTo(
          '2026-11-04',
          '2026-01-01',
          today: today,
        ),
        isNull,
      );
    });
  });

  test('uppercase formatter normalises pasted identifier input', () {
    const formatter = UpperCaseTextFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: 'tn-12/abc',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );

    expect(result.text, 'TN-12/ABC');
    expect(result.selection, const TextSelection.collapsed(offset: 9));
  });
}
