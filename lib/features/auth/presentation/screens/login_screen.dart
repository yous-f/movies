import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:movies/core/constants/app_assets.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_text_styles.dart';

import 'package:movies/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:movies/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movies/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:movies/features/auth/presentation/screens/register_screen.dart';
import 'package:movies/features/auth/presentation/view_models/login_view_model.dart';
import 'package:movies/features/auth/presentation/widgets/language_selector.dart';
import 'package:movies/features/home/presentation/screens/home_screen.dart';

import 'package:movies/shared/widgets/default_elevated_button.dart';
import 'package:movies/shared/widgets/default_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _viewModel = LoginViewModel(
      AuthRepositoryImpl(AuthRemoteDataSource()),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final state = _viewModel.state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (state.status == UiStateStatus.success) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        return;
      }

      if (state.status == UiStateStatus.error &&
          state.errorMessage != null &&
          state.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final isLoading =
                _viewModel.state.status == UiStateStatus.loading;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * .072),

                          Image.asset(
                            AppAssets.logoImage,
                            height: screenHeight * .13,
                            width: screenWidth * .30,
                            fit: BoxFit.contain,
                          ),

                          SizedBox(height: screenHeight * .074),

                          DefaultTextFormField(
                            hintText: "Email",
                            prefixIconImageName: "email_icon",
                            controller: _emailController,
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            hintText: "Password",
                            prefixIconImageName: "lock_Passowrd",
                            isPassword: true,
                            controller: _passwordController,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  ForgetPasswordScreen.routeName,
                                );
                              },
                              child: const Text("Forget Password?"),
                            ),
                          ),

                          SizedBox(height: screenHeight * .02),

                          DefaultElevatedButton(
                            label: "Login",
                            onPressed: () {
                              if (isLoading) {
                                return;
                              }
                              _viewModel.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                            },
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t Have Account ?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    RegisterScreen.routeName,
                                  );
                                },
                                child: const Text("Create One"),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * .02),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.primary,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.textTheme.titleMedium,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.primary,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * .03),

                          DefaultElevatedButton(
                            label: 'Login With Google',
                            onPressed: () {
                              if (isLoading) {
                                return;
                              }
                              _viewModel.signInWithGoogle();
                            },
                            icon: SvgPicture.asset(
                              'assets/icons/google_icon.svg',
                            ),
                          ),

                          SizedBox(height: screenHeight * .03),

                          LanguageSelector(
                            firstLanguage: "🇺🇸",
                            secondLanguage: "🇪🇬",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: AbsorbPointer(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
