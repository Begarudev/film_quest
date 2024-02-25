import 'dart:convert';

import 'package:film_quest/model/movie_by_id.dart';
import 'package:film_quest/model/movie_by_title.dart';
import 'package:film_quest/model/movie_image.dart';
import 'package:film_quest/model/now_playing_movie.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final movieImagesProvider = FutureProvider.family<MovieImage, String>(
  (ref, movieId) {
    {
      var headers = {
        'Type': 'get-movies-images-by-imdb',
        'X-RapidAPI-Key': 'c3abde9dc5msh8d4f48500477eb0p1bc3a5jsna701f8b93624',
        'X-RapidAPI-Host': 'movies-tv-shows-database.p.rapidapi.com',
      };

      var uri = Uri.https(
          'movies-tv-shows-database.p.rapidapi.com', '/', {'movieid': movieId});

      return http.get(uri, headers: headers).then((value) =>
          MovieImage.fromJson(jsonDecode(value.body) as Map<String, dynamic>));
    }
  },
);

final nowMoviesProvider = FutureProvider(
  (ref) {
    {
      var headers = {
        'Type': 'get-nowplaying-movies',
        'X-RapidAPI-Key': 'c3abde9dc5msh8d4f48500477eb0p1bc3a5jsna701f8b93624',
        'X-RapidAPI-Host': 'movies-tv-shows-database.p.rapidapi.com',
      };

      var uri = Uri.https(
          'movies-tv-shows-database.p.rapidapi.com', '/', {'page': '1'});

      return http
          .get(uri, headers: headers)
          .then((value) => NowPlayingMovie.fromJson(
                jsonDecode(value.body) as Map<String, dynamic>,
              ));
    }
  },
);

final getMoviesByNameProvider =
    FutureProvider.family.autoDispose<MovieByTitle, String>((ref, inputText) {
  {
    var headers = {
      'Type': 'get-movies-by-title',
      'X-RapidAPI-Key': 'c3abde9dc5msh8d4f48500477eb0p1bc3a5jsna701f8b93624',
      'X-RapidAPI-Host': 'movies-tv-shows-database.p.rapidapi.com',
    };

    var uri = Uri.https(
        'movies-tv-shows-database.p.rapidapi.com', '/', {'title': inputText});

    return http.get(uri, headers: headers).then((value) =>
        MovieByTitle.fromJson(jsonDecode(value.body) as Map<String, dynamic>));
  }
});

final movieSelectedProvider = StateProvider((ref) => "");

final getMoviesByIDProvider =
    FutureProvider.family<MovieById, String>((ref, imdbID) {
  {
    var headers = {
      'Type': 'get-movie-details',
      'X-RapidAPI-Key': 'c3abde9dc5msh8d4f48500477eb0p1bc3a5jsna701f8b93624',
      'X-RapidAPI-Host': 'movies-tv-shows-database.p.rapidapi.com',
    };

    var uri = Uri.https(
        'movies-tv-shows-database.p.rapidapi.com', '/', {'movieid': imdbID});

    return http.get(uri, headers: headers).then((value) =>
        MovieById.fromJson(jsonDecode(value.body) as Map<String, dynamic>));
  }
});

class MovieRepository {
  MovieRepository({required this.movieTitle});

  final String movieTitle;
  Future<MovieByTitle> fetchMoviesData() {
    {
      var headers = {
        'Type': 'get-movies-by-title',
        'X-RapidAPI-Key': 'c3abde9dc5msh8d4f48500477eb0p1bc3a5jsna701f8b93624',
        'X-RapidAPI-Host': 'movies-tv-shows-database.p.rapidapi.com',
      };

      var uri = Uri.https('movies-tv-shows-database.p.rapidapi.com', '/',
          {'title': movieTitle});

      return http.get(uri, headers: headers).then((value) =>
          MovieByTitle.fromJson(
              jsonDecode(value.body) as Map<String, dynamic>));
    }
  }
}

final searchInputTextProvider = StateProvider((ref) => "");

// final userProvider = StateProvider<String?>((ref) => null);

final userProvider = StreamProvider((ref) => GoogleSignInService().authChanges);
