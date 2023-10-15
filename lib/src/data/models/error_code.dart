/*
 * ----------------------------------------------------------------------------
 *
 * This file is part of the metal_bonus_backend project, available at:
 * https://github.com/Gambley1/realtime_server/
 *
 * Created by: Emil Zulufov
 * ----------------------------------------------------------------------------
 *
 * Copyright (c) 2020 Emil Zulufov
 *
 * Licensed under the MIT License.
 *
 * ----------------------------------------------------------------------------
*/

enum ErrorCode {
  unexpectedError('UNEXPECTED_ERROR'),

  databaseConnectionError('DATABASE_CONNECTION_ERROR'),

  missingRequestBody('MISSING_REQUEST_BODY'),

  methodNotAllowed('METHOD_NOT_ALLOWED'),

  postNotFound('POST_NOT_FOUND');

  const ErrorCode(this.value);

  final String value;
}

extension ErrorCodeX on String {
  ErrorCode? get toErrorCode {
    for (final code in ErrorCode.values) {
      if (code.value == this) return code;
    }
    return null;
  }
}
