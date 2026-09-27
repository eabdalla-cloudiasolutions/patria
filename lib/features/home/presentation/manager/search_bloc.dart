import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/features/home/data/repos/search_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepo;

  SearchBloc({SearchRepository? searchRepo})
    : _searchRepo = searchRepo ?? SearchRepository(),
      super(SearchHistoryInitial()) {
    on<LoadSearchHistory>(_onLoadAll);
    on<LogSearchQuery>(_onLogQuery);
    on<ClearSearchHistory>(_onClearHistory);
  }

  // ✅ Load both history and trending together
  Future<void> _onLoadAll(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchHistoryLoading());
    final results = await Future.wait([
      _searchRepo.getSearchHistory(),
      _searchRepo.getTrending(),
    ]);
    emit(SearchTrendingLoaded(history: results[0], trending: results[1]));
  }

  Future<void> _onLogQuery(
    LogSearchQuery event,
    Emitter<SearchState> emit,
  ) async {
    await _searchRepo.logSearch(event.query);
    final results = await Future.wait([
      _searchRepo.getSearchHistory(),
      _searchRepo.getTrending(),
    ]);
    emit(SearchTrendingLoaded(history: results[0], trending: results[1]));
  }

  Future<void> _onClearHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    await _searchRepo.clearHistory();
    // ✅ Reload after clearing
    final results = await Future.wait([
      _searchRepo.getSearchHistory(),
      _searchRepo.getTrending(),
    ]);
    emit(SearchTrendingLoaded(history: results[0], trending: results[1]));
  }
}
