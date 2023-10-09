#!/bin/bash

# Check if the script was run with the correct number of arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <file_name> <route_name> <method_name>"
    exit 1
fi

# Extract arguments
file_name="$1"
route_name="$2"
method_name="$3"
file_header="
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
"
cd routes/ && pwd && touch "${file_name}.dart" &&
echo "${file_header}
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.$method_name => $route_name(context),
    _ => Future.value(
        Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: {
            'error': 'Method \${context.request.method} is not allowed',
            'code': ErrorCode.methodNotAllowed.value,
          },
        ),
      ),
  };
}

Future<Response> "$route_name"(RequestContext context) async {
    return Response();
}
" >> "${file_name}.dart" && cd .. && pwd &&

cd routes/${file_name}.dart && git add .