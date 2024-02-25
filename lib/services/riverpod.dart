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
        'X-RapidAPI-Key': '0b08ab071amsh02486fb63313df5p15f03cjsne9edab23b7d8',
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
        'X-RapidAPI-Key': '0b08ab071amsh02486fb63313df5p15f03cjsne9edab23b7d8',
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
      'X-RapidAPI-Key': '0b08ab071amsh02486fb63313df5p15f03cjsne9edab23b7d8',
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
      'X-RapidAPI-Key': '0b08ab071amsh02486fb63313df5p15f03cjsne9edab23b7d8',
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
        'X-RapidAPI-Key': '0b08ab071amsh02486fb63313df5p15f03cjsne9edab23b7d8',
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
