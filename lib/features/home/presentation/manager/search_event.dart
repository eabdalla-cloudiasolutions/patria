abstract class SearchEvent {}

class LoadSearchHistory extends SearchEvent {}

class LogSearchQuery extends SearchEvent {
  final String query;
  LogSearchQuery(this.query);
}

class LoadTrending extends SearchEvent {}

class ClearSearchHistory extends SearchEvent {}
