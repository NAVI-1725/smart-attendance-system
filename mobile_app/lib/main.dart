// mobile_app\lib\main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_bootstrap.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/faculty/presentation/faculty_dashboard_screen.dart';
import 'features/admin/presentation/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();

  runApp(
    const ProviderScope(
      child: SmartAttendanceApp(),
    ),
  );
}

class SmartAttendanceApp extends ConsumerWidget {
  const SmartAttendanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    Widget home;

    if (!authState.isAuthenticated) {
      home = const LoginScreen();
    } else if (authState.role == 'admin') {
      home = const AdminDashboardScreen();
    } else if (authState.role == 'faculty') {
      home = const FacultyDashboardScreen();
    } else {
      home = const HomeScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}