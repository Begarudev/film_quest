import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:film_quest/services/riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/movie_by_id.dart';
import '../model/now_playing_movie.dart';

class MovieDetails extends ConsumerStatefulWidget {
  const MovieDetails({super.key});

  @override
  ConsumerState<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends ConsumerState<MovieDetails> {
  final uid = GoogleSignInService().user!.uid;

  @override
  Widget build(BuildContext context) {
    final String imdbID = ref.watch(movieSelectedProvider);
    final user = GoogleSignInService().user;
    final images = ref.watch(movieImagesProvider(imdbID));
    final movieDetails = ref.watch(getMoviesByIDProvider(imdbID));
    final likeStateRef = db.collection("users").doc(uid).snapshots();
    // final asyncLikeState = ref.watch(asyncLikeStateProvider);

    return movieDetails.when(
        data: (data) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () {},
              child: StreamBuilder(
                stream: likeStateRef,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!.data();
                    final likeList = data!['likedmovies'] ?? [];
                    return IconButton(
                        onPressed: () async {
                          if (likeList.contains(imdbID)) {
                            try {
                              await db.collection("users").doc(uid).update({
                                'likedmovies': FieldValue.arrayRemove([imdbID])
                              });
                            } on FirebaseException {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error liking'),
                                ),
                              );
                            }
                          } else {
                            try {
                              await db.collection("users").doc(uid).update({
                                'likedmovies': FieldValue.arrayUnion([imdbID])
                              });
                            } on FirebaseException {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error liking post'),
                                ),
                              );
                            }
                          }
                        },
                        icon: likeList.contains(imdbID)
                            ? const Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.red,
                                size: 45,
                              )
                            : const Icon(
                                CupertinoIcons.heart,
                                color: Colors.red,
                                size: 45,
                              ));
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                  backgroundBlendMode: BlendMode.darken,
                  gradient: LinearGradient(colors: [
                    Colors.red,
                    Colors.black,
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CarouselSlider(
                          items: [
                            images.when(
                                data: (data) => Hero(
                                      tag: data.imdb!,
                                      child: CachedNetworkImage(
                                        imageUrl: data.poster != null
                                            ? data.poster!
                                            : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                      ),
                                    ),
                                error: (error, stackTrace) =>
                                    Center(child: Text('Error: $error')),
                                loading: () => const Center(
                                    child: CircularProgressIndicator())),
                            images.when(
                                data: (d) => CachedNetworkImage(
                                      imageUrl: d.fanart != null
                                          ? d.fanart!
                                          : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                    ),
                                error: (error, stackTrace) =>
                                    Center(child: Text('Error: $error')),
                                loading: () => const Center(
                                    child: CircularProgressIndicator())),
                          ],
                          options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlay: true,
                            pageSnapping: true,
                            enlargeCenterPage: true,
                            enlargeFactor: 0.2,
                          )),
                      IconButton(
                          onPressed: () {
                            print(data.youtubeTrailerKey);
                            launchUrl(Uri.parse(
                                "https://www.youtube.com/watch?v=${(data.youtubeTrailerKey == null || data.youtubeTrailerKey!.isEmpty) ? "dQw4w9WgXcQ" : data.youtubeTrailerKey}"));
                          },
                          tooltip: "Play Trailer",
                          icon: const Icon(
                            color: Colors.red,
                            Icons.local_movies_outlined,
                            size: 80,
                          ))
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title != null ? data.title! : "Not Available",
                            style: GoogleFonts.lato(
                                fontSize: 40, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            data.tagline != null
                                ? data.tagline!
                                : "TagLine not Available",
                            style: const TextStyle(color: Colors.red),
                          ),
                          (data.rated != null)
                              ? Center(
                                  child: RatingStars(
                                    valueLabelVisibility: false,
                                    value: double.parse(data.imdbRating!) / 2,
                                    maxValue: 5,
                                  ),
                                )
                              : const Text(
                                  "Not Available",
                                  style: TextStyle(color: Colors.white),
                                ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text(
                            data.description != null
                                ? data.description!
                                : "Not Available",
                            style: const TextStyle(color: Colors.white60),
                          ),
                          Text(
                            data.rated != null
                                ? "Age Rating: ${data.rated!}"
                                : "Not Available",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Release Date: ${formatter.format(data.releaseDate)}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Hero(
            tag: 'nowPlay', child: Center(child: CircularProgressIndicator())));
  }
}
