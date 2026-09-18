import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/features/browse/presentation/widgets/browse_movie_grid.dart';

import '../../bloc/search_bloc.dart';
import '../../bloc/search_event.dart';
import '../../bloc/search_state.dart';


class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Search Body
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchInitial() => Center(
                      child: Image.asset(
                        'assets/images/Empty1.png',
                        width: 150,
                        height: 150,
                      ),
                    ),

                    SearchLoading() => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),

                  // Re-using your responsive grid (Matches image_9c9266.png)
                    SearchSuccess(:final movies) => BrowseMovieGrid(movies: movies),

                    SearchEmpty() => const Center(
                      child: Text(
                        'No movies found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),

                    SearchFailure(:final message) => Center(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}