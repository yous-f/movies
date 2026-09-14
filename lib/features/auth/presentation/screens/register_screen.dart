import 'package:flutter/material.dart';

import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:movies/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movies/features/auth/presentation/screens/login_screen.dart';
import 'package:movies/features/auth/presentation/view_models/register_view_model.dart';
import 'package:movies/features/auth/presentation/widgets/avatar_selector.dart';
import 'package:movies/features/auth/presentation/widgets/language_selector.dart';

import 'package:movies/shared/widgets/default_elevated_button.dart';
import 'package:movies/shared/widgets/default_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "/register";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final RegisterViewModel _viewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();

    _viewModel = RegisterViewModel(
      AuthRepositoryImpl(AuthRemoteDataSource()),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final state = _viewModel.registerState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (state.status == UiStateStatus.success) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phone: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final isLoading =
                _viewModel.registerState.status == UiStateStatus.loading;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const AvatarSelector(),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            controller: _nameController,
                            hintText: "Name",
                            prefixIconImageName: "name_icon",
                            validator: _viewModel.validateName,
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            controller: _emailController,
                            hintText: "Email",
                            prefixIconImageName: "email_icon",
                            validator: _viewModel.validateEmail,
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            controller: _passwordController,
                            hintText: "Password",
                            prefixIconImageName: "lock_Passowrd",
                            isPassword: true,
                            validator: _viewModel.validatePassword,
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            controller: _confirmPasswordController,
                            hintText: "Confirm Password",
                            prefixIconImageName: "lock_Passowrd",
                            isPassword: true,
                            validator: (value) =>
                                _viewModel.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            controller: _phoneController,
                            hintText: "Phone Number",
                            prefixIconImageName: "phone_icon",
                            validator: _viewModel.validatePhone,
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultElevatedButton(
                            label: "Create Account",
                            onPressed: () {
                              if (isLoading) return;
                              _onRegisterPressed();
                            },
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already Have Account ?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    LoginScreen.routeName,
                                  );
                                },
                                child: const Text("Login"),
                              ),
                            ],
                          ),

                          const LanguageSelector(
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