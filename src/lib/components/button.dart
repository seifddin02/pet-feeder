import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String label;
  final Function onPress;

  Button({required this.label, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPress(),
      child: Text(label),
    );
  }
}
