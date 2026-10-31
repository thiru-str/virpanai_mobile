import 'package:flutter_test/flutter_test.dart';
import 'package:waioz/model/verify_otp_response.dart';

void main() {
  test('parses pending approval responses without requiring a token', () {
    final response = VerifyOtpResponse.fromJson({
      'success': false,
      'message': 'Your account is pending administrator approval.',
    });

    expect(response.hasFailure, isTrue);
    expect(
      response.failureMessage,
      'Your account is pending administrator approval.',
    );
    expect(response.token, isNull);
    expect(response.newUser, isNull);
  });

  test('uses structured backend error messages', () {
    final response = VerifyOtpResponse.fromJson({
      'status': 'error',
      'error': {
        'code': 'ACCOUNT_BLOCKED',
        'message': 'Your account is blocked.',
      },
    });

    expect(response.hasFailure, isTrue);
    expect(response.failureMessage, 'Your account is blocked.');
  });

  test('reads the email-login approval refusals', () {
    final codes = {
      'APPROVAL_PENDING': 'Your account is pending administrator approval.',
      'ACCOUNT_REJECTED': 'Your registration was rejected.',
      'ACCOUNT_BLOCKED': 'Your account has been blocked.',
      'APPROVAL_CHECK_FAILED':
          'We could not sign you in right now. Please try again shortly.',
    };

    codes.forEach((code, message) {
      final response = VerifyOtpResponse.fromJson({
        'status': false,
        'newUser': false,
        'token': '',
        'error': {'code': code, 'message': message},
      });

      expect(response.hasFailure, isTrue);
      expect(response.error?.code, code);
      expect(response.failureMessage, message);
    });
  });

  test('does not treat an empty error object as a login failure', () {
    final response = VerifyOtpResponse.fromJson({
      'status': 'success',
      'error': <String, dynamic>{},
      'token': 'valid-token',
      'newUser': false,
    });

    expect(response.hasFailure, isFalse);
    expect(response.token, 'valid-token');
    expect(response.newUser, isFalse);
  });
}
