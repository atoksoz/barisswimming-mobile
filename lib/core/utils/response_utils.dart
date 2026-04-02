import 'dart:convert';

Map<String, dynamic>? extractOutputIfFound(String responseBody) {
  try {
    final jsonMap = json.decode(responseBody);

    if ((jsonMap['status'] == 200 || jsonMap['status'] == 'FOUND' || 
         jsonMap['messages'] == 'FOUND' || jsonMap['messages'] == 'UPDATED' ||
         jsonMap['messages'] == 'DELETED') &&
        jsonMap['output'] != null) {
      final output = jsonMap['output'];

      if (output is Map<String, dynamic>) {
        return output;
      } else if (output is List && output.isNotEmpty && output.first is Map) {
        return Map<String, dynamic>.from(output.first);
      } else {
        print('output beklenmedik format: ${output.runtimeType}');
      }
    }
  } catch (e) {
    print('JSON ayrıştırma hatası: $e');
  }

  return null;
}

List<Map<String, dynamic>>? extractOutputListIfFound(String responseBody) {
  try {
    final jsonMap = json.decode(responseBody);

    if ((jsonMap['status'] == 200 || jsonMap['status'] == 'FOUND' || jsonMap['messages'] == 'FOUND') &&
        jsonMap['output'] != null) {
      final output = jsonMap['output'];

      if (output is List && output.isNotEmpty && output.first is Map) {
        return output.cast<Map<String, dynamic>>();
      } else {
        print('output beklenmedik format: ${output.runtimeType}');
      }
    }
  } catch (e) {
    print('JSON ayrıştırma hatası: $e');
  }

  return null;
}

/*
Map<String, dynamic>? extractOutputIfFound(String responseBody) {
  try {
    final jsonMap = json.decode(responseBody);

    if (jsonMap['status'] == 'FOUND' && jsonMap['output'] != null) {
      return Map<String, dynamic>.from(jsonMap['output']);
    }
  } catch (e) {
    print(e);
    // JSON parse hatası olabilir
    return null;
  }

  return null;
}
*/
bool isTokenValidResponse(String responseBody) {
  try {
    final jsonMap = json.decode(responseBody);

    return jsonMap['status'] == 200 && jsonMap['messages'] == 'VALID';
  } catch (e) {
    // JSON parse hatası ya da beklenmeyen veri
    return false;
  }
}
