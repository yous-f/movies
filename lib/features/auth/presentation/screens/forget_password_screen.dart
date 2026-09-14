import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:movies/shared/widgets/default_elevated_button.dart';
import 'package:movies/shared/widgets/default_text_form_field.dart';

import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../view_models/forget_password_view_model.dart';
import '../../../../core/state/ui_state.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const String routeName = "/forgetpass";

  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  late final ForgetPasswordViewModel _viewModel = ForgetPasswordViewModel(
    AuthRepositoryImpl(AuthRemoteDataSourceImpl()),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forget Password")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final state = _viewModel.state;
                final isLoading = state.status == UiStateStatus.loading;

                // React to success once, then navigate back to Login.
                if (state.status == UiStateStatus.success) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reset link sent! Check your email inbox.',
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  });
                }

                return Column(
                  children: [
                    SvgPicture.asset(
                      "assets/images/Forgot password-bro 1.svg",
                      height: MediaQuery.sizeOf(context).height * .46,
                    ),

                    const SizedBox(height: 24),

                    DefaultTextFormField(
                      controller: _emailController,
                      hintText: "Email",
                      prefixIconImageName: "email_icon",
                    ),

                    if (state.status == UiStateStatus.error) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.errorMessage ?? 'Something went wrong.',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    isLoading
                        ? const CircularProgressIndicator()
                        : DefaultElevatedButton(
                          label: "Verify Email",
                          onPressed: () {
                            _viewModel.sendResetEmail(_emailController.text);
                          },
                        ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
