// To parse this JSON data, do
//
//     final movieImage = movieImageFromJson(jsonString);

import 'dart:convert';

MovieImage movieImageFromJson(String str) =>
    MovieImage.fromJson(json.decode(str));

class MovieImage {
  final String title;
  final String imdb;
  final String poster;
  final String fanart;
  final String status;
  final String statusMessage;

  MovieImage({
    required this.title,
    required this.imdb,
    required this.poster,
    required this.fanart,
    required this.status,
    required this.statusMessage,
  });

  factory MovieImage.fromJson(Map<String, dynamic> json) => MovieImage(
        title: json["title"],
        imdb: json["IMDB"],
        poster: json["poster"],
        fanart: json["fanart"],
        status: json["status"],
        statusMessage: json["status_message"],
      );
}
