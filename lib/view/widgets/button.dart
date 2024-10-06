import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final Color? buttonColor;
  final double borderRadius;
  final IconData icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 0.5,
    this.icon = Icons.lock_open_outlined,
    this.buttonColor,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: buttonColor ?? Theme.of(context).colorScheme.primary,
          ),
          width: MediaQuery.of(context).size.width * width,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Text(
                "  $label",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
