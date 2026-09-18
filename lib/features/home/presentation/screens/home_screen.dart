import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movies/features/browse/presentation/screens/browse_tab.dart';
import 'package:movies/features/home/presentation/screens/home_tab.dart';
import 'package:movies/features/profile/presentation/screens/profile_tab.dart';
import 'package:movies/features/search/presentation/screens/search_tab.dart';

import 'package:movies/shared/widgets/active_nav_bar_icon.dart';
import 'package:movies/shared/widgets/inactive_nav_bar_icon.dart';

import 'package:movies/features/data/repositories/movie_repository.dart';

import '../../../search/bloc/search_bloc.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const HomeTab(),

      BlocProvider(
        create: (context) => SearchBloc(
          movieRepository: context.read<MovieRepository>(),
        ),
        child: const SearchTab(),
      ),

      const BrowseTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[currentIndex]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: InactiveNavBarIcon(iconName: 'home'),
            activeIcon: ActiveNavBarIcon(iconName: 'home'),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: InactiveNavBarIcon(iconName: 'search'),
            activeIcon: ActiveNavBarIcon(iconName: 'search'),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: InactiveNavBarIcon(iconName: 'explore'),
            activeIcon: ActiveNavBarIcon(iconName: 'explore'),
            label: 'explore',
          ),
          BottomNavigationBarItem(
            icon: InactiveNavBarIcon(iconName: 'profile'),
            activeIcon: ActiveNavBarIcon(iconName: 'profile'),
            label: 'profile',
          ),
        ],
      ),
    );
  }
}