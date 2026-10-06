import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _client = http.Client();
  String? _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final url = '${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint';
    final response = await _client.get(
      Uri.parse(url),
      headers: _headers,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => http.Response('Request timeout', 408),
    );
    return _handleResponse(response);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = '${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint';
    final response = await _client.post(
      Uri.parse(url),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => http.Response('Request timeout', 408),
    );
    return _handleResponse(response);
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = '${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint';
    final response = await _client.put(
      Uri.parse(url),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => http.Response('Request timeout', 408),
    );
    return _handleResponse(response);
  }

  Future<http.Response> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required Map<String, File> files,
  }) async {
    final url = '${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    
    request.headers.addAll(_headers);
    fields.forEach((key, value) => request.fields[key] = value);
    
    for (final entry in files.entries) {
      final file = await http.MultipartFile.fromPath(
        entry.key,
        entry.value.path,
      );
      request.files.add(file);
    }
    
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception('Request timeout'),
    );
    
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    
    throw ApiException(
      statusCode: response.statusCode,
      message: _parseErrorMessage(response),
    );
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message']?.toString() ?? 
             data['error']?.toString() ?? 
             'An error occurred';
    } catch (_) {
      return 'An error occurred';
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}
