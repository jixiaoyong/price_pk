import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PriceInputFormatter extends TextInputFormatter {
  final int decimalRange;
  PriceInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String value = newValue.text;

    if (value.isEmpty) return newValue;

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
      return oldValue;
    }

    if ('.'.allMatches(value).length > 1) {
      return oldValue;
    }

    if (value.contains('.')) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > decimalRange) {
        return oldValue;
      }
    }

    if (value.startsWith('00') && !value.startsWith('0.')) {
      return oldValue;
    }
    if (value.startsWith('0') && value.length > 1 && !value.startsWith('0.')) {
      return oldValue;
    }

    return newValue;
  }
}
