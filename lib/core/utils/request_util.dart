import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../services/jwt_storage_service.dart';

class ApiResponse {
  final int statusCode;
  final dynamic body;
  final bool isSuccess;

  const ApiResponse({
    required this.statusCode,
    required this.body,
    required this.isSuccess,
  });

  dynamic get output => body is Map ? (body['output'] ?? body['data']) : null;

  List<dynamic>? get outputList {
    final o = output;
    return o is List ? o : null;
  }

  Map<String, dynamic>? get outputMap {
    final o = output;
    return o is Map<String, dynamic> ? o : null;
  }

  String? get message =>
      body is Map ? (body['message'] ?? body['error']) : null;
}

class RequestUtil {
  /// Token'ı otomatik alır, response'u parse eder.
  static Future<ApiResponse> getJson(String url, {String? token}) async {
    final t = token ?? await JwtStorageService.getToken();
    final response = await get(url, token: t);
    return _toApiResponse(response);
  }

  static Future<ApiResponse> postJson(String url,
      {Map<String, dynamic>? body, String? token}) async {
    final t = token ?? await JwtStorageService.getToken();
    final response = await post(url, body: body, token: t);
    return _toApiResponse(response);
  }

  static Future<ApiResponse> putJson(String url,
      {Map<String, dynamic>? body, String? token}) async {
    final t = token ?? await JwtStorageService.getToken();
    final response = await put(url, body: body, token: t);
    return _toApiResponse(response);
  }

  static Future<ApiResponse> deleteJson(String url,
      {Map<String, dynamic>? body, String? token}) async {
    final t = token ?? await JwtStorageService.getToken();
    final response = await delete(url, body: body, token: t);
    return _toApiResponse(response);
  }

  static ApiResponse parseResponse(http.Response? response) =>
      _toApiResponse(response);

  static ApiResponse _toApiResponse(http.Response? response) {
    if (response == null) {
      return const ApiResponse(statusCode: 0, body: null, isSuccess: false);
    }
    try {
      final decoded = json.decode(response.body);
      return ApiResponse(
        statusCode: response.statusCode,
        body: decoded,
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
      );
    } catch (_) {
      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        isSuccess: false,
      );
    }
  }

  static Future<http.Response?> get(String url,
      {String? token, String? secondaryToken, Duration timeout = const Duration(seconds: 10)}) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      if (secondaryToken != null && secondaryToken.isNotEmpty) {
        headers['X-Authorization'] = 'Bearer $secondaryToken';
      }

      print('HTTP GET Request: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeout);
      return response;
    } catch (e) {
      print('GET error: $e');
      return null;
    }
  }

  static Future<http.Response?> post(
    String url, {
    Map<String, dynamic>? body,
    String? token,
    String? secondaryToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      if (secondaryToken != null && secondaryToken.isNotEmpty) {
        headers['X-Authorization'] = 'Bearer $secondaryToken';
      }

      print('HTTP POST Request: $url');
      
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);
      return response;
    } catch (e) {
      print('POST error: $e');
      return null;
    }
  }

  static Future<http.Response?> put(
    String url, {
    Map<String, dynamic>? body,
    String? token,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('HTTP PUT Request: $url');

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);
      print('HTTP PUT Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      print('PUT error: $e');
      return null;
    }
  }

  static Future<http.Response?> delete(String url,
      {Map<String, dynamic>? body,
      String? token,
      Duration timeout = const Duration(seconds: 10)}) async {
    try {
      print('HTTP DELETE Request: $url');
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);
      return response;
    } catch (e) {
      print('DELETE error: $e');
      return null;
    }
  }

  static Future<http.Response?> postMultipart(
    String url, {
    required File file,
    String? token,
    String fieldName = 'file',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );
      
      print('HTTP POST Multipart Request: $url');
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      print('HTTP POST Multipart Response [${response.statusCode}]: ${response.body}');
      return response;
    } catch (e) {
      print('POST Multipart error: $e');
      return null;
    }
  }

  static Future<http.Response?> postMultipartWithFields(
    String url, {
    required Map<String, String> fields,
    List<File>? files,
    String? token,
    String fileFieldName = 'attachments',
    bool useIndexedFieldNames = false, // attachment_1, attachment_2, etc.
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add fields
      request.fields.addAll(fields);
      
      // Add files
      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final fieldName = useIndexedFieldNames
              ? '${fileFieldName}_${i + 1}' // attachment_1, attachment_2, etc.
              : fileFieldName;
          request.files.add(
            await http.MultipartFile.fromPath(fieldName, file.path),
          );
        }
      }
      
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return response;
    } catch (e) {
      print('POST Multipart with fields error: $e');
      return null;
    }
  }
}
