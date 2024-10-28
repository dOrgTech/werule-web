


import 'dart:ui';

import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;
  for (var i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  // ignore: avoid_function_literals_in_foreach_calls 
  strengths.forEach((strength) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch as Map<int, Color>);
}



  ThemeData light = ThemeData(
      textTheme: TextTheme(
        //all text is white
        bodyLarge: TextStyle(color: Colors.black),
        displayLarge: TextStyle(color: Color(0xff363636)),
        displayMedium: TextStyle(color: Colors.black),
        displaySmall: TextStyle(color: Colors.black),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
        labelLarge: TextStyle(color: Colors.black),
        labelSmall: TextStyle(color: Colors.black),
        
      ),
        brightness: Brightness.light,
        dividerColor: createMaterialColor(Color(0xff4454238)),
        hintColor: Colors.black87,
        primaryColor: createMaterialColor(Color(0xffffffff)),
        highlightColor: Color(0xff6e6e6e),
        splashColor: Color(0xffffffff),
        canvasColor: Color(0xfff0f0f0), colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0xff4d4d4d))).copyWith(secondary: Color(0xffe0deda)).copyWith(background: createMaterialColor(Color(0xeecacaca))));

        
    ThemeData dark = ThemeData(
      indicatorColor: Color.fromARGB(255, 109, 134, 210),
      buttonColor: Color(0xff4d4d4d),
      splashColor: Color(0xff000000),
      dividerColor: createMaterialColor(Color(0xffcfc099)),
      brightness: Brightness.dark,
      hintColor: Colors.white70,
      primaryColor: createMaterialColor(Color(0xff4d4d4d)),
      highlightColor: Color(0xff6e6e6e), colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0xffefefef))).copyWith(secondary: createMaterialColor(Color(0xff383736))),
    );
