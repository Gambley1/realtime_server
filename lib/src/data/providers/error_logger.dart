import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Middleware errorLogger() {
  return (handler) {
    return (context) async {
      final response = await handler(context);
      if (response.statusCode.isNotOk) {
        final msg = _errorMessage(
          requestTime: DateTime.now(),
          requestedUri: context.request.uri,
          method: context.request.method.value,
          error: response.statusCode._errorMessage,
        );

        _defaultLogger(msg, true);
      }
      return response;
    };
  };
}

String _errorMessage({
  required DateTime requestTime,
  required Uri requestedUri,
  required String method,
  required Object error,
}) {
  final msg = '$requestTime\t$method\t${requestedUri.path}'
      '${_formatQuery(requestedUri.query)}\n$error';

  return msg;
}

void _defaultLogger(String msg, bool isError) {
  if (isError) {
    print('[ERROR] $msg');
  } else {
    print(msg);
  }
}

String _formatQuery(String query) {
  return query == '' ? '' : '?$query';
}

extension StatusCodeState on int {
  bool get isOk =>
      this == HttpStatus.ok ||
      this == HttpStatus.accepted ||
      this == HttpStatus.created;

  bool get isNotOk => !isOk;

  String get _errorMessage => _errorMessages[this] ?? _unknownMessage(this);
}

Map<int, String> get _errorMessages => {
      HttpStatus.badRequest:
          'Bad Request - The server cannot fulfill the request.',
      HttpStatus.unauthorized:
          'Unauthorized - Authentication is required to access the resource.',
      HttpStatus.forbidden:
          'Forbidden - The server refuses to fulfill the request.',
      HttpStatus.notFound:
          'Not Found - The requested resource could not be found.',
      HttpStatus.serviceUnavailable:
          'Service unavailable - The connection to the database was failed.',
      HttpStatus.internalServerError:
          'Internal Server Error - An unexpected condition was encountered.',
    };

String _unknownMessage(int statusCode) =>
    'Unknown Error - An unknown error occurred with status code: $statusCode';
