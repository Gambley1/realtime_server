import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

/// Exception for request errors.
sealed class RequestException implements Exception {
  /// {@macro request_exception}
  const RequestException(this.message);

  /// Error message.
  final String message;

  @override
  String toString() => 'RequestException: $message';
}

/// Exception for request body errors.
final class RequestBodyException extends RequestException {
  /// {@macro request_body_exception}
  const RequestBodyException(super.message);
}

/// Extension for [RequestContext] to safely get JSON from request. Returns null
/// if request body is empty.
extension SafeRequestJSON on RequestContext {
  /// Returns JSON from request body.
  Future<Map<String, dynamic>?> safeRequestJSON() async {
    try {
      final body = await request.body();
      if (body.isEmpty) return null;
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      print('Failed to get request body. $e');
      throw RequestBodyException(e.toString());
    }
  }
}

/// Extension for [RequestContext] to get query parameters from request.
extension RequestQueryParameters on RequestContext {
  /// Returns query parameters from request.
  Map<String, String> get _queryParameters => request.url.queryParameters;

  /// Returns query parameter by [key].
  String? query(String key) => _queryParameters[key];
}
