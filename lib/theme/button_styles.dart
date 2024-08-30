// lib/theme/button_styles.dart

import 'package:flutter/material.dart';

ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFFFC531), // Fundo amarelo
  foregroundColor: Colors.black, // Texto preto
  textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
);

ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: Colors.black, side: const BorderSide(color: Colors.black), // Borda preta
  textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
).copyWith(
  backgroundColor: MaterialStateProperty.all(const Color(0xFFFFC531)), // Configura o fundo para o estado padrão
);

ButtonStyle textButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.black, textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
);
