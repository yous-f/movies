import 'package:flutter/material.dart';

import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:movies/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movies/features/auth/presentation/view_models/update_profile_view_model.dart';
import 'package:movies/features/auth/presentation/widgets/avatar_selector.dart';

import 'package:movies/shared/widgets/default_elevated_button.dart';
import 'package:movies/shared/widgets/default_text_form_field.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String routeName = "/update-profile";

  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final UpdateProfileViewModel _viewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    _viewModel = UpdateProfileViewModel(
      AuthRepositoryImpl(AuthRemoteDataSource()),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final state = _viewModel.updateState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (state.status == UiStateStatus.success) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
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

  void _onUpdatePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.updateProfile(name: _nameController.text.trim());
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
        title: const Text("Pick Avatar"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final isLoading =
                _viewModel.updateState.status == UiStateStatus.loading;

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

                          SizedBox(height: screenHeight * .04),

                          DefaultTextFormField(
                            controller: _nameController,
                            hintText: "Name",
                            prefixIconImageName: "name_icon",
                          ),

                          SizedBox(height: screenHeight * .024),

                          DefaultTextFormField(
                            controller: _phoneController,
                            hintText: "Phone Number",
                            prefixIconImageName: "phone_icon",
                          ),

                          SizedBox(height: screenHeight * .04),

                          DefaultElevatedButton(
                            label: "Update Data",
                            onPressed: () {
                              if (isLoading) return;
                              _onUpdatePressed();
                            },
                          ),

                          SizedBox(height: screenHeight * .02),

                          TextButton(
                            onPressed: () {
                              // Reset Password Navigation/Action
                            },
                            child: const Text(
                              "Reset Password",
                              style: TextStyle(color: Colors.red),
                            ),
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
