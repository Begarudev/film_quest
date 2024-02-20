// To parse this JSON data, do
//
//     final nowPlayingMovie = nowPlayingMovieFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

NowPlayingMovie nowPlayingMovieFromJson(String str) =>
    NowPlayingMovie.fromJson(json.decode(str));

class NowPlayingMovie {
  final List<MovieResult> movieResults;
  final int results;
  final String totalResults;
  final String status;
  final String statusMessage;

  NowPlayingMovie({
    required this.movieResults,
    required this.results,
    required this.totalResults,
    required this.status,
    required this.statusMessage,
  });

  factory NowPlayingMovie.fromJson(Map<String, dynamic> json) =>
      NowPlayingMovie(
        movieResults: List<MovieResult>.from(
            json["movie_results"].map((x) => MovieResult.fromJson(x))),
        results: json["results"],
        totalResults: json["Total_results"],
        status: json["status"],
        statusMessage: json["status_message"],
      );
}

class MovieResult {
  final String title;
  final String year;
  final String imdbId;
  final likeStateProvider = StateProvider((ref) => false);

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
