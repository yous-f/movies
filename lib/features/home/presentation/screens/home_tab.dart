import 'package:flutter/material.dart';
import 'package:movies/core/constants/app_assets.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/movie_card.dart';
import 'package:movies/core/state/ui_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../data/data_sources/move_remote_data_source.dart';
import '../../../data/repositories/movie_repository.dart';
import '../view_models.dart';


class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late PageController pageController;
  int currentIndex = 1;

  late HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.45, initialPage: 1);

    viewModel = HomeViewModel(
      movieRepository: MovieRepository(
        remoteDataSource: MovieRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    viewModel.fetchMovies();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.moviesState;

        switch (state.status) {
          case UiStateStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case UiStateStatus.error:
            return Center(child: Text(state.errorMessage ?? "An error occurred"));

          case UiStateStatus.empty:
            return const Center(child: Text("No movies available right now."));

          case UiStateStatus.success:
            final movies = state.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 82, left: 81, top: 7),
                    child: Image.asset(
                      AppAssets.available,
                      height: screenSize.height * .14,
                      width: screenSize.width * .62,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: 21),

                  SizedBox(
                    height: screenSize.height * .25,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: movies.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return AnimatedScale(
                          scale: currentIndex == index ? 1.0 : 0.78,
                          duration: const Duration(milliseconds: 200),
                          child: MovieCard(
                            imageUrl: movie.largeCoverImage.isNotEmpty
                                ? movie.largeCoverImage
                                : 'assets/images/card.png',
                            rating: movie.rating,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 21),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38),
                    child: Image.asset(
                      AppAssets.watchNow,
                      height: screenSize.height * .14,
                      width: screenSize.width * .62,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text('Action', style: textTheme.titleLarge),
                        const Spacer(),
                        Text(
                          'See More',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: screenSize.height * .20,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(left: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 16);
                      },
                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return SizedBox(
                          width: screenSize.width * 0.35,
                          child: MovieCard(
                            imageUrl: movie.mediumCoverImage.isNotEmpty
                                ? movie.mediumCoverImage
                                : 'assets/images/card.png',
                            rating: movie.rating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );

          case UiStateStatus.initial:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}