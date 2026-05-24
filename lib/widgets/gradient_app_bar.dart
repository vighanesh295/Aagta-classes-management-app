// lib/widgets/gradient_app_bar.dart
import 'package:flutter/material.dart';

/// A reusable Premium AppBar that delegates to the theme.
class GoldenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String    title;
  final List<Widget>? actions;
  final bool      showBack;
  final Widget?   leading;

  const GoldenAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ?? (showBack && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () => Navigator.pop(context),
            )
          : null),
      title: Text(title),
      actions: actions,
    );
  }
}
