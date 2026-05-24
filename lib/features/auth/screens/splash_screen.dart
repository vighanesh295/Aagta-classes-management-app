// lib/features/auth/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final Animation<double>   _logoScale;
  late final Animation<double>   _logoOpacity;
  late final Animation<double>   _textOpacity;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    _logoCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _textCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _navigate();
  }

  void _navigate() {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (!mounted) return;
    if (user == null) {
      context.go(Routes.login);
    } else {
      switch (user.role) {
        case UserRole.student: context.go(Routes.studentDashboard); break;
        case UserRole.teacher: context.go(Routes.teacherDashboard); break;
        case UserRole.admin:   context.go(Routes.adminDashboard);   break;
      }
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.black, // Black background as requested
      body: Stack(
        children: [
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, child) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: child,
                ),
              ),
              child: Container(
                width: 280, 
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.3), // Stronger golden/orange glow for black background
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  SizedBox(
                    width: 40, height: 40,
                    child: CircularProgressIndicator(
                      color: secondaryColor, // Golden/Orange color
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appVersion,
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
