import 'dart:convert';

MovieByTitle movieByTitleFromJson(String str) =>
    MovieByTitle.fromJson(json.decode(str));

class MovieByTitle {
  final List<MovieResult>? movieResults;
  final int? searchResults;
  final String status;
  final String statusMessage;

  MovieByTitle({
    required this.movieResults,
    required this.searchResults,
    required this.status,
    required this.statusMessage,
  });

  factory MovieByTitle.fromJson(Map<String, dynamic> json) => MovieByTitle(
        movieResults: List<MovieResult>.from(
            json["movie_results"].map((x) => MovieResult.fromJson(x))),
        searchResults: json["search_results"],
        status: json["status"],
        statusMessage: json["status_message"],
      );
}

class MovieResult {
  final String? title;
  final int? year;
  final String? imdbId;

  MovieResult({
    required this.title,
    required this.year,
    required this.imdbId,
  });

  factory MovieResult.fromJson(Map<String, dynamic> json) => MovieResult(
        title: json["title"],
        year: json["year"],
        imdbId: json["imdb_id"],
      );
}
