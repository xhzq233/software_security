import 'package:flutter/material.dart';
import 'package:software_security/ffi/ffi_channel.dart';

class Constant {
  Constant._();

  static const shadow = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 10,
    color: Color.fromRGBO(255, 255, 255, 0.04),
  );
  static const grey = Color.fromARGB(255, 33, 33, 33);
  static const on = Color.fromARGB(255, 255, 255, 255);
  static const primary = Color.fromRGBO(101, 212, 110, 1);

  static const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.black,
      secondary: grey,
      onSecondary: on,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.black,
      onBackground: on,
      surface: Colors.black,
      onSurface: on);

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    displayMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    displaySmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    headlineLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    headlineMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    headlineSmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    labelLarge: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(fontFamily: 'JBMono', color: Colors.white, decoration: TextDecoration.none),
  );
}

extension MsgTypeBackgroundColor on MsgType {
  static const a = Color(0xff9f369e);
  static const b = Color(0xff396adb);
  static const c = Color.fromARGB(255, 26, 246, 228);

  Color get hintColor {
    switch (this) {
      case MsgType.heap:
        return const Color(0xff5c72ff);
      case MsgType.file:
        return const Color(0xffe71fff);
      case MsgType.reg:
        return const Color(0xffeac822);
      case MsgType.net:
        return const Color(0xff9d4cff);
      case MsgType.memcpy:
        return const Color(0xff2eea86);
      case MsgType.msgBox:
        return c;
    }
  }
}

extension BackgroundColor on LocalizedSentData {
  Color get hintColor {
    return msgType.hintColor;
  }
}
