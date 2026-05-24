// lib/features/auth/screens/login_screen.dart
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool     _rememberMe   = false;
  bool     _obscurePass  = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await ref.read(authNotifierProvider.notifier)
        .getSavedCredentials();
    if (!mounted) return;
    if (creds['email'] != null) {
      _emailCtrl.text = creds['email']!;
      setState(() => _rememberMe = true);
    }
    if (creds['role'] != null) {
      setState(() {
        _selectedRole = UserRoleX.fromString(creds['role']!);
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = await ref.read(authNotifierProvider.notifier).signIn(
      email:        _emailCtrl.text,
      password:     _passCtrl.text,
      expectedRole: _selectedRole,
      rememberMe:   _rememberMe,
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
              SizedBox(height: h * 0.06),

              // ── Branding ────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90, height: 90,
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
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        Icons.school_rounded,
                        color: secondaryColor, size: 46,
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.7, 0.7)),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.tagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  ],
                ),
              ),
              SizedBox(height: h * 0.05),

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
                      Text('Welcome Back',
                          style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text('Sign in to continue learning',
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
                        onFieldSubmitted: (_) => _login(),
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
                      const SizedBox(height: 12),

                      // Remember me + Forgot
                      Row(
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(AppStrings.rememberMe,
                              style: TextStyle(fontSize: 13)),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                context.push(Routes.forgotPassword),
                            child: const Text(AppStrings.forgotPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      GoldenButton(
                        label:     AppStrings.login,
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading ? null : _login,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () => context.go(Routes.register),
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.dontHaveAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: ' ${AppStrings.signUp}',
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
                      
                      // ── Debug UI Bypass ──────────────────────────────────────────
                      const SizedBox(height: 32),
                      Center(
                        child: Text('Debug: Jump to Dashboards', 
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 12)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(onPressed: () => context.push(Routes.studentDashboard), child: const Text('Student')),
                          TextButton(onPressed: () => context.push(Routes.teacherDashboard), child: const Text('Teacher')),
                          TextButton(onPressed: () => context.push(Routes.adminDashboard),   child: const Text('Admin')),
                        ],
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
