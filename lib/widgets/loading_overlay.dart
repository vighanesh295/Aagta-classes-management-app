// lib/widgets/loading_overlay.dart
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool     isLoading;
  final Widget   child;
  final String?  message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(
                  color: theme.colorScheme.secondary, 
                  strokeWidth: 3,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message!, style: theme.textTheme.bodyMedium),
                ],
              ]),
            ),
          ),
        ),
    ]);
  }
}
