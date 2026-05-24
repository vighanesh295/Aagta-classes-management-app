// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/golden_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authNotifierProvider.notifier)
        .sendPasswordReset(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: theme.colorScheme.error),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Icon
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withValues(alpha: 0.35),
                        blurRadius: 20, spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: theme.colorScheme.onSecondary, size: 36,
                  ),
                ).animate().scale(begin: const Offset(0.6, 0.6)).fadeIn(),
              ),
              const SizedBox(height: 32),

              Text(
                AppStrings.resetPassword,
                style: theme.textTheme.displaySmall,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                "Enter your registered email and we'll send you a reset link.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),

              if (authState.isPasswordResetSent)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reset link sent! Check your email inbox.',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ).animate().fadeIn().slideY(begin: -0.1)
              else
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller:   _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator:    Validators.email,
                      decoration: const InputDecoration(
                        labelText: AppStrings.email,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),
                    GoldenButton(
                      label:     AppStrings.sendResetLink,
                      isLoading: authState.isLoading,
                      onPressed: authState.isLoading ? null : _submit,
                      icon: Icons.send_rounded,
                    ).animate().fadeIn(delay: 400.ms),
                  ]),
                ),

              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(AppStrings.backToLogin),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
