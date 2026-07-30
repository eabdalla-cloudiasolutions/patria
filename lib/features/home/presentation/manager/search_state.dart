abstract class SearchState {}

class SearchHistoryInitial extends SearchState {}

class SearchHistoryLoading extends SearchState {}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;
  SearchHistoryLoaded(this.history);
}

class SearchHistoryError extends SearchState {
  final String message;
  SearchHistoryError(this.message);
}

class SearchTrendingLoaded extends SearchState {
  final List<String> history;
  final List<String> trending;

  SearchTrendingLoaded({required this.history, required this.trending});
}
