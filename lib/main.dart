import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movies/core/network/api_client.dart';
import 'package:movies/features/data/data_sources/move_remote_data_source.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';

import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:movies/features/auth/presentation/screens/login_screen.dart';
import 'package:movies/features/auth/presentation/screens/register_screen.dart';
import 'package:movies/features/home/presentation/screens/home_screen.dart';
import 'package:movies/features/home/presentation/screens/movie_details_screen.dart';
import 'package:movies/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:movies/features/profile/presentation/screens/update_profile_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<MovieRepository>(
      create: (context) => MovieRepositoryImpl(
        remoteDataSource: MovieRemoteDataSourceImpl(
          apiClient: ApiClient(),
        ),
      ),
      child: MaterialApp(
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
          MovieDetailsScreen.routeName: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final movieId = (args is int) ? args : 0;
            return MovieDetailsScreen(movieId: movieId);
          },
        },

        initialRoute: HomeScreen.routeName,
      ),
    );
  }
}