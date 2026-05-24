// lib/widgets/golden_button.dart
import 'package:flutter/material.dart';

class GoldenButton extends StatelessWidget {
  final String    label;
  final VoidCallback? onPressed;
  final bool      isLoading;
  final IconData? icon;
  final double    height;
  final bool      outline;

  const GoldenButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : (icon != null ? Icon(icon) : const SizedBox.shrink()),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        child: isLoading
            ? SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5, 
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
