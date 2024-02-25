// To parse this JSON data, do
//
//     final nowPlayingMovie = nowPlayingMovieFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final db = FirebaseFirestore.instance;

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
  final String? title;
  final String? year;
  final String? imdbId;

  MovieResult({
    required this.title,
    required this.year,
    required this.imdbId,
  });

  factory MovieResult.fromJson(Map<String, dynamic> json) {
    return MovieResult(
      title: json["title"],
      year: json["year"],
      imdbId: json["imdb_id"],
    );
  }
}

// class LikeState {
//   LikeState({required this.likeState});
//
//   factory LikeState.fromFireStore(
//       DocumentSnapshot<Map<String, dynamic>> snapshot,
//       SnapshotOptions? options) {
//     final map = snapshot.data() ?? {'likeState': false};
//     return LikeState(
//         likeState:
//             (map['likeState'] == null) ? false : (map['likeState'] as bool));
//   }
//
//   final bool? likeState;
//
//   Map<String, dynamic> toFireStore() =>
//       <String, dynamic>{'likeState': likeState};
// }

class AsyncMovieLikedNotifier extends AsyncNotifier<List<String>> {
  Future<List<String>> _getLikeState(String userUID) async {
    final likeStateRef =
        await db.collection("users").doc(userUID).collection('movies').get();

    final likeStateSnap = likeStateRef.docs.map((e) => e.id).toList();
    return likeStateSnap;
  }

  @override
  Future<List<String>> build() async {
    return _getLikeState(GoogleSignInService().user!.uid);
  }

  void defState(String userUID, String imdbID) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      db
          .collection("users")
          .doc(userUID)
          .collection('movies')
          .doc(imdbID)
          .set({});

      return _getLikeState(userUID);
    });
  }

  void addLikeState(String userUID, String imdbID) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      db
          .collection("users")
          .doc(userUID)
          .collection('movies')
          .doc(imdbID)
          .set({});

      return _getLikeState(userUID);
    });
  }

  void removeLikeState(String userUID, String imdbID) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      db
          .collection("users")
          .doc(userUID)
          .collection('movies')
          .doc(imdbID)
          .delete();

      return _getLikeState(userUID);
    });
  }
}

final asyncLikeStateProvider =
    AsyncNotifierProvider<AsyncMovieLikedNotifier, List<String>>(() {
  return AsyncMovieLikedNotifier();
});
