/*
 * ----------------------------------------------------------------------------
 *
 * This file is part of the metal_bonus_backend project, available at:
 * https://github.com/Gambley1/metal_bonus_backend/
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

import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:realtime_server/_internal.dart';

/// {@template dotenv_cofig}
/// This config allows to manipulate with [DotEnv] itself, making it easier
/// to access secret variables from environment in the root of project, e.g
/// ".env".
/// {@endtemplate}
class Env {
  /// {@macro dotenv_config}
  Env() {
    _initEnv();
  }

  final DotEnv _env = DotEnv(includePlatformEnvironment: true);

  Future<void> _initEnv() async {
    final file = File('.env');
    while (!file.existsSync()) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    _env.load();
  }

  /// Access secret variable by provided path to data.
  String? env(String path) => _env[path];

  /// Value of secret pg host from environment.
  String? get pgHost => env('PGHOST');

  /// Value of secret pg database variable from environment.
  String? get pgDatabase => env('PGDATABASE');

  /// Value of secret pg password variable from environment.
  String? get pgPassword => env('PGPASSWORD');

  /// Value of secret pg user variable from environment.
  String? get pgUser => env('PGUSER');

  /// Value of pg port variable from environment.
  int? get pgPort => env('PGPORT').parseInt;
}
