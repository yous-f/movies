import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:movies/features/auth/presentation/screens/login_screen.dart';
import 'package:movies/features/auth/presentation/screens/register_screen.dart';
import 'package:movies/features/home/presentation/screens/home_screen.dart';
import 'package:movies/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:movies/features/profile/presentation/screens/update_profile_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      routes: {
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        UpdateProfileScreen.routeName: (_) => const UpdateProfileScreen(),
        ForgetPasswordScreen.routeName: (_) => const ForgetPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },

      initialRoute: HomeScreen.routeName,
    );
  }
}
