import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';

const appBarTheme = AppBarTheme(
  elevation: 0,
);

enum MyThemeKeys { pink, green, blue }

class MyThemes {
  static const TextTheme _textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
      ));

  static final ColorScheme _colorScheme =
      ColorScheme.fromSwatch(brightness: Brightness.dark);

  static const Color _primaryPink = Color(0xff813961);
  static const Color _hoverPink = Color(0xffbb99bb);
  static const Color _focusPink = Color(0xff301025);

  static const Color _primaryGreen = Color(0xff398161);
  static const Color _hoverGreen = Color(0xff99bbbb);
  static const Color _focusGreen = Color(0xff103025);

  static const Color _primaryBlue = Color(0xff396181);
  static const Color _hoverBlue = Color(0xff99bbbb);
  static const Color _focusBlue = Color(0xff103025);

  static const TimePickerThemeData _timePickerThemePink = TimePickerThemeData(
    backgroundColor: _primaryPink,
    hourMinuteColor: _primaryPink,
    dayPeriodColor: _primaryPink,
    dayPeriodTextColor: _primaryPink,
    dialHandColor: _hoverPink,
    dialBackgroundColor: _primaryPink,
    entryModeIconColor: _primaryPink,
    hourMinuteTextColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _focusPink),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryPink),
      ),
    ),
  );

  static const TimePickerThemeData _timePickerThemeGreen = TimePickerThemeData(
    backgroundColor: _primaryGreen,
    hourMinuteColor: _primaryGreen,
    dayPeriodColor: _primaryGreen,
    dayPeriodTextColor: _primaryGreen,
    dialHandColor: _hoverGreen,
    dialBackgroundColor: _primaryGreen,
    entryModeIconColor: _primaryGreen,
    hourMinuteTextColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _focusGreen),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryGreen),
      ),
    ),
  );

  static const TimePickerThemeData _timePickerThemeBlue = TimePickerThemeData(
    backgroundColor: _primaryBlue,
    hourMinuteColor: _primaryBlue,
    dayPeriodColor: _primaryBlue,
    dayPeriodTextColor: _primaryBlue,
    dialHandColor: _hoverBlue,
    dialBackgroundColor: _primaryBlue,
    entryModeIconColor: _primaryBlue,
    hourMinuteTextColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _focusBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryBlue),
      ),
    ),
  );

  static final ThemeData pinkTheme = ThemeData(
      primaryColor: _primaryPink,
      hoverColor: _hoverPink,
      focusColor: _focusPink,
      textTheme: _textTheme,
      timePickerTheme: _timePickerThemePink,
      colorScheme: _colorScheme.copyWith(
        primary: Colors.white,
        secondary: Colors.pink,
        onPrimary: _primaryPink,
        surface: _primaryPink,
        onSurface: Colors.white,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: _primaryPink));

  static final ThemeData greenTheme = ThemeData(
      primaryColor: _primaryGreen,
      hoverColor: _hoverGreen,
      focusColor: _focusGreen,
      textTheme: _textTheme,
      timePickerTheme: _timePickerThemeGreen,
      colorScheme: _colorScheme.copyWith(
        primary: Colors.white,
        secondary: Colors.green,
        onPrimary: _primaryGreen,
        surface: _primaryGreen,
        onSurface: Colors.white,
      ),
      dialogTheme: DialogThemeData(backgroundColor: _primaryGreen));

  static final ThemeData blueTheme = ThemeData(
      primaryColor: _primaryBlue,
      hoverColor: _hoverBlue,
      focusColor: _focusBlue,
      textTheme: _textTheme,
      timePickerTheme: _timePickerThemeBlue,
      colorScheme: _colorScheme.copyWith(
          primary: Colors.white,
          secondary: Colors.blue,
          onPrimary: _primaryBlue,
          surface: _primaryBlue,
          onSurface: Colors.white),
      dialogTheme: const DialogThemeData(backgroundColor: _primaryBlue));

  static String greenImage = 'assets/green.jpeg';
  static String blueImage = 'assets/blue.jpeg';
  static String pinkImage = 'assets/gare.jpeg';

  static ThemeData getThemeFromKey(MyThemeKeys? themeKey) {
    switch (themeKey) {
      case MyThemeKeys.pink:
        return pinkTheme;
      case MyThemeKeys.green:
        return greenTheme;
      case MyThemeKeys.blue:
        return blueTheme;
      default:
        return pinkTheme;
    }
  }

  static ThemeData getThemeFromString(String colorString) {
    if (kDebugMode) {
      print("ThemeData getThemeFromString: $colorString");
    }
    switch (colorString) {
      case "PINK":
        return pinkTheme;
      case "GREEN":
        return greenTheme;
      case "BLUE":
        return blueTheme;
      default:
        return pinkTheme;
    }
  }
}

const TextStyle styleTextWhiteBig =
    TextStyle(fontSize: 30, color: Colors.white);
