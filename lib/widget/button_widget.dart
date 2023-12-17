import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: const Color(0xFF5bc8e5),
      minimumSize: const Size.fromHeight(50),
    ),
    onPressed: onClicked,
    child: buildContent(),
  );

  Widget buildContent() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 28),
      const SizedBox(width: 16),
      Text(
        text,
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    ],
  );
}