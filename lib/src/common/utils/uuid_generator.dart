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
import 'dart:math';
import 'dart:typed_data';

import 'package:uuid/data.dart';
import 'package:uuid/rng.dart';
import 'package:uuid/uuid.dart';

/// Unique user id generator
class UuidGenerator {
  const UuidGenerator._();
  static final _uuid = Uuid(goptions: GlobalOptions(CryptoRNG._()));

  /// Generate random user id based on ['Uuid'] library
  static String generateRandomv4Uid() => _uuid.v4();
}

/// {@template crypto_rng}
/// Math.Random()-based RNG. All platforms, fast, not cryptographically
/// strong.
/// {@endtemplate}
class CryptoRNG extends RNG {
  CryptoRNG._({
    Random? secureRandom,
  }) : _secureRandom = secureRandom ?? Random.secure();

  final Random _secureRandom;

  @override
  Uint8List generateInternal() {
    final b = Uint8List(16);

    for (var i = 0; i < 16; i += 4) {
      final k = _secureRandom.nextInt(1 << 32);
      b[i] = k;
      b[i + 1] = k >> 8;
      b[i + 2] = k >> 16;
      b[i + 3] = k >> 24;
    }

    return b;
  }
}
