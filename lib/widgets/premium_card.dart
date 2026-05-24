// lib/widgets/premium_card.dart
import 'package:flutter/material.dart';

/// Premium clean card with soft ivory surface and elegant shadows
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final bool showAccentBorder;
  // Keep old param name for backward compat
  final bool showGoldBorder;
  final VoidCallback? onTap;
  final double elevation;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 16,
    this.showAccentBorder = false,
    this.showGoldBorder = false,
    this.onTap,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final hasAccent = showAccentBorder || showGoldBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasAccent
            ? Border.all(color: theme.colorScheme.secondary, width: 1.5)
            : Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 10 * elevation,
              offset: Offset(0, 2 * elevation),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: theme.colorScheme.secondary.withValues(alpha: 0.06),
          highlightColor: theme.colorScheme.secondary.withValues(alpha: 0.03),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Primary Orange Card (replaces GoldenGradientCard) ──────────────────────
class GoldenGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GoldenGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
