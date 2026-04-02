import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtUtils {
  /// Decodes JWT token and returns payload as Map
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      if (!JwtDecoder.isExpired(token)) {
        return JwtDecoder.decode(token);
      }
      return null;
    } catch (e) {
      print("JWT decode error: $e");
      return null;
    }
  }

  /// Gets user email from JWT token
  static String? getUserEmail(String token) {
    final decoded = decodeToken(token);
    if (decoded != null && decoded['user'] != null) {
      final user = decoded['user'];
      if (user is Map<String, dynamic>) {
        return user['email']?.toString();
      }
    }
    return null;
  }

  /// Gets email_verified_at from JWT token
  static String? getEmailVerifiedAt(String token) {
    final decoded = decodeToken(token);
    if (decoded != null && decoded['user'] != null) {
      final user = decoded['user'];
      if (user is Map<String, dynamic>) {
        return user['email_verified_at']?.toString();
      }
    }
    return null;
  }

  /// Checks if email is verified (email_verified_at is not null or empty)
  static bool isEmailVerified(String token) {
    final emailVerifiedAt = getEmailVerifiedAt(token);
    return emailVerifiedAt != null && emailVerifiedAt.isNotEmpty;
  }
}

