// lib/widgets/stat_card.dart
import 'package:flutter/material.dart';

export 'premium_card.dart' show PremiumCard, GoldenGradientCard;

/// Modern stat card with warm ivory surface and subtle shadow
class StatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color?   iconColor;
  final Color?   iconBg;
  final Color?   valueColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconBg,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final finalIconColor = iconColor ?? theme.colorScheme.secondary;
    final finalIconBg    = iconBg    ?? theme.colorScheme.secondary.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: finalIconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: finalIconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor ?? theme.textTheme.headlineSmall?.color,
              )),
              const SizedBox(height: 2),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              )),
            ],
          )),
        ]),
      ),
    );
  }
}

// Section Header widget - used across all screens
class SectionHeader extends StatelessWidget {
  final String    title;
  final String?   actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Container(
        width: 4, height: 20,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(title, style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      )),
      const Spacer(),
      if (actionLabel != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}
