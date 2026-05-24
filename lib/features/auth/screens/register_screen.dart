// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/golden_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool     _obscurePass  = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = await ref.read(authNotifierProvider.notifier).signUp(
      name:        _nameCtrl.text,
      email:       _emailCtrl.text,
      password:    _passCtrl.text,
      role:        _selectedRole,
    );

    if (!mounted) return;
    if (user != null) {
      switch (user.role) {
        case UserRole.student:
          context.go(Routes.studentDashboard);
          break;
        case UserRole.teacher:
          context.go(Routes.teacherDashboard);
          break;
        case UserRole.admin:
          context.go(Routes.adminDashboard);
          break;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;
    final h = MediaQuery.of(context).size.height;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: theme.colorScheme.error),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.04),

              // ── Branding ────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor.withValues(alpha: 0.1),
                        border: Border.all(color: secondaryColor.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryColor.withValues(alpha: 0.2),
                            blurRadius: 20, spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.school_rounded,
                        color: secondaryColor, size: 40,
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.7, 0.7)),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.createAccount,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  ],
                ),
              ),
              SizedBox(height: h * 0.04),

              // ── Card ────────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.05),
                      blurRadius: 24, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Join Us',
                          style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text('Sign up to start learning',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          )),
                      const SizedBox(height: 24),

                      // Role selector
                      _RoleSelector(
                        selected: _selectedRole,
                        onChanged: (r) => setState(() => _selectedRole = r),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller:  _nameCtrl,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (val) => val == null || val.trim().isEmpty ? AppStrings.errorRequired : null,
                        decoration: const InputDecoration(
                          labelText: AppStrings.fullName,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller:  _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          labelText: AppStrings.email,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller:    _passCtrl,
                        obscureText:   _obscurePass,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onFieldSubmitted: (_) => _register(),
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      GoldenButton(
                        label:     AppStrings.signUp,
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading ? null : _register,
                        icon: Icons.person_add_rounded,
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () => context.go(Routes.login),
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.alreadyHaveAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: ' ${AppStrings.login}',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms)
               .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role Selector Widget ────────────────────────────────────────────────────
class _RoleSelector extends StatelessWidget {
  final UserRole  selected;
  final ValueChanged<UserRole> onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  static const _roles = [
    (UserRole.student, 'Student',  Icons.school_rounded),
    (UserRole.teacher, 'Teacher',  Icons.person_rounded),
    (UserRole.admin,   'Admin',    Icons.admin_panel_settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.selectRole,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            )),
        const SizedBox(height: 10),
        Row(
          children: _roles.map((r) {
            final isSelected = selected == r.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(r.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? secondaryColor.withValues(alpha: 0.1)
                        : theme.dividerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? secondaryColor
                          : theme.dividerColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        r.$3,
                        color: isSelected ? secondaryColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.$2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? secondaryColor
                              : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
