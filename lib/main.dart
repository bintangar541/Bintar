import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bintar/core/theme/app_theme.dart';
import 'package:bintar/shared/widgets/main_shell.dart';
import 'package:bintar/features/auth/presentation/pages/register_page.dart';
import 'package:bintar/features/auth/presentation/pages/login_page.dart';
import 'package:bintar/features/auth/presentation/pages/reset_password_page.dart';
import 'package:bintar/core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: BintarApp()));
}

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['reset_token'] ?? state.uri.queryParameters['token'] ?? '';
          debugPrint('ROUTER Builder: reset token=$token');
          return ResetPasswordPage(resetToken: token);
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => MainShell(key: MainShell.shellKey),
      ),
    ],
    redirect: (context, state) {
      final String path = state.uri.path;
      final bool isLoggingIn = path == '/login';
      final bool isSplash = path == '/splash';
      final bool isPublic = path.contains('password') || isLoggingIn || path == '/register';

      debugPrint('ROUTER: path=$path, isPublic=$isPublic, isLoading=${authState.isLoading}, isAuth=${authState.isAuthenticated}');

      // Public routes bypass all checks including loading state
      if (isPublic) {
        if (authState.isAuthenticated && isLoggingIn) return '/';
        return null;
      }

      if (authState.isLoading) return '/splash';

      if (isSplash) {
        return authState.isAuthenticated ? '/' : '/login';
      }

      if (!authState.isAuthenticated) {
        return '/login';
      }

      return null;
    },
  );
});

class BintarApp extends ConsumerWidget {
  const BintarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'Bintar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

class _SplashPage extends StatefulWidget {
  const _SplashPage();

  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 16),
                const Text(
                  '',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keuangan Pintar, Hidup Lebih Baik',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
