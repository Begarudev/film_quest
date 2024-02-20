// To parse this JSON data, do
//
//     final movie = movieFromJson(jsonString);

import 'dart:convert';

TrendingMovie movieFromJson(String str) =>
    TrendingMovie.fromJson(json.decode(str));

class TrendingMovie {
  final List<TrendingMovieResult> movieResults;
  final int results;
  final String totalResults;
  final String status;
  final String statusMessage;

  TrendingMovie({
    required this.movieResults,
    required this.results,
    required this.totalResults,
    required this.status,
    required this.statusMessage,
  });

  factory TrendingMovie.fromJson(Map<String, dynamic> json) => TrendingMovie(
        movieResults: List<TrendingMovieResult>.from(
            json["movie_results"].map((x) => TrendingMovieResult.fromJson(x))),
        results: json["results"],
        totalResults: json["Total_results"],
        status: json["status"],
        statusMessage: json["status_message"],
      );
}

class TrendingMovieResult {
  final String title;
  final String year;
  final String imdbId;

  TrendingMovieResult({
    required this.title,
    required this.year,
    required this.imdbId,
  });

  factory TrendingMovieResult.fromJson(Map<String, dynamic> json) =>
      TrendingMovieResult(
        title: json["title"],
        year: json["year"],
        imdbId: json["imdb_id"],
      );
}
