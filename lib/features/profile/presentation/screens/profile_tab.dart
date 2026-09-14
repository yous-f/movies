import 'package:flutter/material.dart';
import 'package:movies/features/auth/presentation/screens/login_screen.dart';
import 'package:movies/features/profile/presentation/screens/update_profile_screen.dart';
import 'package:movies/features/profile/presentation/widgets/empty_watchlist.dart';
import 'package:movies/features/profile/presentation/widgets/movie_grid.dart';
import 'package:movies/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:movies/features/profile/presentation/widgets/profile_header.dart';
import 'package:movies/features/profile/presentation/widgets/profile_tabs.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int _selectedTab = 0;

  final String _userName = 'John Safwat';
  final int _wishListCount = 12;
  final int _historyCount = 10;

  final List<Map<String, dynamic>> _watchlistMovies = [
    {'title': 'Black Widow', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Hobbs & Shaw', 'rating': 7.7, 'imageUrl': null},
    {'title': '1917', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Avengers', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Avengers Endgame', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Black Widow 2', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Black Panther', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Doctor Strange', 'rating': 7.7, 'imageUrl': null},
    {'title': 'Doctor Who', 'rating': 7.7, 'imageUrl': null},
  ];

  final List<Map<String, dynamic>> _historyMovies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileHeader(
              userName: _userName,
              wishListCount: _wishListCount,
              historyCount: _historyCount,
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
              onExit: () {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
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
                  ? _watchlistMovies.isEmpty
                        ? const EmptyWatchlist()
                        : MovieGrid(movies: _watchlistMovies)
                  : _historyMovies.isEmpty
                  ? const EmptyWatchlist()
                  : MovieGrid(movies: _historyMovies),
            ),
          ],
        ),
      ),
    );
  }
}
