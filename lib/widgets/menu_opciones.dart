import 'package:flutter/material.dart';

class MenuOpciones {
  static PopupMenuItem<String> buildMenuItem(String value, IconData icon, String text, [Color? color]) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black, size: 16),
        title: Text(text),
      ),
    );
  }
}
