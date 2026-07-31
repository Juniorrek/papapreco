// lib/theme/theme.dart

import 'package:flutter/material.dart';
import 'button_styles.dart'; // Importa o arquivo de estilos dos botões

ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.yellow,
      primary: Colors.black,
      onPrimary: Colors.black,
      secondary: Colors.black,
      onSecondary: const Color(0xFF003366),
    ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // Define a cor de fundo do AppBar
        foregroundColor: Colors.black, // Define a cor do texto e ícones no AppBar
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Colors.white, // Define a cor de fundo do BottomAppBar
      ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle, // Aplica o estilo do ElevatedButton
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: outlinedButtonStyle, // Aplica o estilo do OutlinedButton
    ),
    textButtonTheme: TextButtonThemeData(
      style: textButtonStyle, // Aplica o estilo do TextButton
    ),
    
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        bodySmall: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        labelMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        labelSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    // Adicione outras configurações de tema conforme necessário
  );
}
