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

import 'package:intl/intl.dart';

final _formatter = NumberFormat();
final _currency = NumberFormat.currency(locale: 'ru_RU', symbol: '₸');
final _date = DateFormat('HH:mm - dd.MM.yyyy', 'en_US');

/// Extension for parsing [String] to [num].
extension Parse on String {
  bool get _isNumeric {
    try {
      parse;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parses [String] to [num].
  num get parse {
    if (!_isNumeric) return 0;
    if (isEmpty) return 0;
    return _formatter.parse(clearValue);
  }
}

/// Extension for parsing [String] to [num].
extension ParseNullable on String? {
  bool get _isNumeric {
    try {
      parse;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parses [String] to [num].
  num? get parse {
    if (!_isNumeric) return null;
    if (this == null) return null;
    return _formatter.parse(this!);
  }

  /// Parses [String] to [int].
  int? get parseInt => parse?.toInt();

  /// Parses [String] to [double].
  double? get parseDouble => parse?.toDouble();
}

/// Extension for formatting [String].
extension FormatString on String {
  /// Formats [num] to [String].
  String format({bool separate = true}) =>
      separate ? _formatter.format(parse) : this;

  /// Formats [num] to [String].
  num formatToNum({bool separate = true}) => format(separate: separate).parse;

  /// Returns [String] or empty string if it is null.
  String get stringOrEmpty => isEmpty ? '' : this;

  /// Returns [String] or 0 if it is null.
  String get stringOrZero => isEmpty ? '0' : this;

  /// Returns [String] with currency symbol.
  String currencyFormat({bool separate = true}) =>
      _currency.format(formatToNum(separate: separate));
}

/// Extension for formatting [String].
extension FormatStringNullable on String? {
  /// Formats [num] to [String].
  String? format({bool separate = true}) =>
      separate ? _formatter.format(parse) : this;

  /// Formats [num] to [String].
  num? formatToNum({bool separate = true}) => format(separate: separate).parse;

  /// Returns [String] or empty string if it is null.
  String get stringOrEmpty => this ?? '';

  /// Returns [String] or 0 if it is null.
  String get stringOrZero => this ?? '0';
}

/// Extension for formatting [num] to [String].
extension FormatNum on num {
  /// Formats [num] to [String].
  String format({bool separate = true}) =>
      separate ? _formatter.format(this) : toString();

  /// Returns [String] with currency symbol.
  String currencyFormat({bool separate = true}) =>
      separate ? _currency.format(this).format() : _currency.format(this);
}

/// Extension for formatting [num] to [String].
extension FormatNullable on num? {
  /// Formats [num] to [String].
  String? formatNullable({bool separate = true}) =>
      separate ? _formatter.format(this) : null;

  /// Returns [num] or 0 if it is null.
  num get numberOrZero => this ?? 0;

  /// Returns [String] with currency symbol.
  String currencyFormat({bool separate = true}) =>
      separate ? _currency.format(numberOrZero) : _currency.format(this);
}

/// Extension for removing all non-digit characters from a string.
extension ClearValue on String {
  /// Removes all non-digits from string.
  String get clearValue => replaceAll(RegExp(r'[^\d]'), '');
}

/// Extension for removing all non-digit characters from a string.
extension ClearValueNullable on String? {
  /// Removes all non-digits from string.
  String? get clearValue => this?.replaceAll(RegExp(r'[^\d]'), '');
}

/// Extension for formatting [DateTime] to [String].
extension DateFormatter on DateTime {
  /// Formats [DateTime] to [String].
  String get format => _date.format(this);
}
