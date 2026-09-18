import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.movieRepository}) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  final MovieRepository movieRepository;

  Future<void> _onQueryChanged(
      SearchQueryChanged event,
      Emitter<SearchState> emit,
      ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    try {
      final movies = await movieRepository.searchMovies(query);

      if (movies.isEmpty) {
        emit(const SearchEmpty());
      } else {
        emit(SearchSuccess(movies));
      }
    } catch (e) {
      emit(SearchFailure(e.toString()));
    }
  }
}