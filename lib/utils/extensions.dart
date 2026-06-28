import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension StringExtension on String {
  String _toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str._toCapitalized()).join(' ');

  bool isInt() => this is int;

  /// To iterate a [String]: `"Hello".iterable()`
  /// This will use simple characters. If you want to use Unicode Grapheme
  /// from the [Characters] library, passa [chars] true.
  Iterable<String> iterable({bool unicode = false}) sync* {
    if (unicode) {
      var iterator = Characters(this).iterator;
      while (iterator.moveNext()) {
        yield iterator.current;
      }
    } else {
      for (var i = 0; i < length; i++) {
        yield this[i];
      }
    }
  }
}

extension StringFormateExtension on String? {
  bool isNullOrEmpty() {
    return (this == null || this!.isEmpty) ? true : false;
  }

  bool isNotNullAndNotEmpty() {
    return (this != null && this!.isNotEmpty) ? true : false;
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    ).hasMatch(this);
  }
}

extension BoolFormateExtension on bool? {
  bool isNull() {
    return (this == null) ? true : false;
  }

  bool isNullOrFalse() {
    return (this == null || this!) ? true : false;
  }

  bool isNotNullAndTrue() {
    return (this != null && this!) ? true : false;
  }

  bool isNotNullAndFalse() {
    return (this != null && !this!) ? true : false;
  }
}

extension ColorsExt on Color {
  MaterialColor toMaterialColor() {
    final int red = this.red;
    final int green = this.green;
    final int blue = this.blue;
    final int alpha = this.alpha;

    final Map<int, Color> shades = {
      50: Color.fromARGB(alpha, red, green, blue),
      100: Color.fromARGB(alpha, red, green, blue),
      200: Color.fromARGB(alpha, red, green, blue),
      300: Color.fromARGB(alpha, red, green, blue),
      400: Color.fromARGB(alpha, red, green, blue),
      500: Color.fromARGB(alpha, red, green, blue),
      600: Color.fromARGB(alpha, red, green, blue),
      700: Color.fromARGB(alpha, red, green, blue),
      800: Color.fromARGB(alpha, red, green, blue),
      900: Color.fromARGB(alpha, red, green, blue),
    };

    return MaterialColor(value, shades);
  }
}
