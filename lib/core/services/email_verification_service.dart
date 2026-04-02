import '../constants/url/iam_url_constants.dart';
import '../utils/request_util.dart';

class EmailVerificationService {
  /// Sends email verification resend request
  /// Returns true if successful, false otherwise
  static Future<bool> resendEmailVerification({
    required String token,
  }) async {
    try {
      final url = IamUrlConstants.getEmailVerificationResendUrl();
      final response = await RequestUtil.post(
        url,
        token: token,
        body: {},
      );

      if (response != null && response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print("Email verification resend error: $e");
      return false;
    }
  }
}

