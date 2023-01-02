import 'package:flutter/material.dart';

const Color c1A = Color(0xFF0067b9);
const Color c1B = Color(0xFF003965);
const Color c1C = Color(0xFF005ea9);
const Color c1D = Color(0xFF7392ca);
const Color c1E = Color(0xFFa1b4dc);
const Color c1F = Color(0xFFcbd4eb);
const Color c1G = Color(0xFFe7ebf6);

MaterialColor c1MaterialColor = MaterialColor(c1A.value, const <int, Color>{
  50: c1G,
  100: c1G,
  200: c1F,
  300: c1F,
  400: c1E,
  500: c1A,
  600: c1D,
  700: c1C,
  800: c1B,
  900: c1B,
});

const Color c2A = Color(0xFF101820);
const Color c2B = Color(0xFF3d3f3f);
const Color c2C = Color(0xFF767989);
const Color c2D = Color(0xFFa3a6b4);
const Color c2E = Color(0xFFbdbfca);
const Color c2F = Color(0xFFe0e1e7);
const Color c2G = Color(0xFFFFFFFF);

const Color c3A = Color(0xFF8637ba);
const Color c3B = Color(0xFF4e2a66);
const Color c3C = Color(0xFF61397f);
const Color c3D = Color(0xFF977bb4);
const Color c3E = Color(0xFFb8a6cd);
const Color c3F = Color(0xFFd7cfe5);
const Color c3G = Color(0xFFece8f3);

MaterialColor c3MaterialColor = MaterialColor(c3A.value, const <int, Color>{
  50: c3G,
  100: c3G,
  200: c3F,
  300: c3F,
  400: c3E,
  500: c3A,
  600: c3D,
  700: c3C,
  800: c3B,
  900: c3B,
});

ThemeData adiTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: c1MaterialColor,
      accentColor: c1MaterialColor,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: c3A,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: c1A,
      selectedItemColor: c1G,
      unselectedItemColor: c1B,
    ),
  );
}
