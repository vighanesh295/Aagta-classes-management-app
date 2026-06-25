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
      body: Container(
        height: h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFB8B24), Color(0xFFFFF4EB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Card ────────────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Learn Today, Lead Tomorrow',
                                style: TextStyle(
                                  color: Color(0xFF0D7377),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        
                            
                      
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
