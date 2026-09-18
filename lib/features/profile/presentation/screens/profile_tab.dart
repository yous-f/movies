import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:movies/core/state/ui_state.dart';
import 'package:movies/core/theme/app_colors.dart';

import 'package:movies/features/auth/presentation/screens/login_screen.dart';
import 'package:movies/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:movies/features/profile/data/models/library_movie_model.dart';
import 'package:movies/features/profile/data/repositories/profile_repository.dart';
import 'package:movies/features/profile/presentation/screens/update_profile_screen.dart';
import 'package:movies/features/profile/presentation/widgets/empty_watchlist.dart';
import 'package:movies/features/profile/presentation/widgets/movie_grid.dart';
import 'package:movies/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:movies/features/profile/presentation/widgets/profile_header.dart';
import 'package:movies/features/profile/presentation/widgets/profile_tabs.dart';
import '../view_models/profile_view_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int _selectedTab = 0;

  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ProfileViewModel(
      profileRepository: ProfileRepository(
        remoteDataSource: ProfileRemoteDataSource(
          firestore: FirebaseFirestore.instance,
          auth: FirebaseAuth.instance,
        ),
      ),
    );

    _viewModel.loadProfileData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel.loadProfileData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onExit() async {
    await _viewModel.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  Widget _buildTabContent(
    UiState<List<LibraryMovieModel>> state, {
    required VoidCallback onRetry,
  }) {
    switch (state.status) {
      case UiStateStatus.loading:
      case UiStateStatus.initial:
        return const Center(child: CircularProgressIndicator());

      case UiStateStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Something went wrong',
                style: const TextStyle(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        );
      case UiStateStatus.empty:
        return const EmptyWatchlist();

      case UiStateStatus.success:
        final List<Map<String, dynamic>> movies = state.data!
            .map((movie) => movie.toGridItem())
            .toList();
        return MovieGrid(movies: movies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 20),
                ProfileHeader(
                  userName: _viewModel.userName,
                  wishListCount: _viewModel.watchlistCount,
                  historyCount: _viewModel.historyCount,
                ),
                const SizedBox(height: 20),
                ProfileActionButtons(
                  onEditProfile: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateProfileScreen(),
                      ),
                    );
                  },
                  onExit: _onExit,
                ),
                const SizedBox(height: 20),
                ProfileTabs(
                  selectedIndex: _selectedTab,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),
                Expanded(
                  child: _selectedTab == 0
                      ? _buildTabContent(
                          _viewModel.watchlistState,
                          onRetry: _viewModel.fetchWatchlist,
                        )
                      : _buildTabContent(
                          _viewModel.historyState,
                          onRetry: _viewModel.fetchHistory,
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
