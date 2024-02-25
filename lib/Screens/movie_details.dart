import 'package:carousel_slider/carousel_slider.dart';
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

class MovieDetails extends ConsumerWidget {
  const MovieDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String imdbID = ref.watch(movieSelectedProvider);
    final user = GoogleSignInService().user;
    final images = ref.watch(movieImagesProvider(imdbID));
    final movieDetails = ref.watch(getMoviesByIDProvider(imdbID));
    final asyncLikeState = ref.watch(asyncLikeStateProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: () {},
        child: switch (asyncLikeState) {
          AsyncData(:final value) => IconButton(
              onPressed: () {
                value.contains(imdbID)
                    ? ref
                        .read(asyncLikeStateProvider.notifier)
                        .removeLikeState(user!.uid, imdbID)
                    : ref
                        .read(asyncLikeStateProvider.notifier)
                        .addLikeState(user!.uid, imdbID);
              },
              icon: value.contains(imdbID)
                  ? const Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                      size: 45,
                    )
                  : const Icon(
                      CupertinoIcons.heart,
                      color: Colors.red,
                      size: 45,
                    )),
          AsyncError(:final error) => Expanded(child: Text('error: $error')),
          _ => /* (ref
                                                  .read(tempListState)
                                                  .contains(imdbID))
                                              ? IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                      CupertinoIcons
                                                          .heart_fill),
                                                  color: Colors.red,
                                                )
                                              : */
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.heart),
              color: Colors.red,
              iconSize: 45,
            )
        },
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
        child: movieDetails.when(
            data: (data) {
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CarouselSlider(
                          items: [
                            images.when(
                                data: (data) => Image.network(
                                      data.poster != null
                                          ? data.poster!
                                          : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                      gaplessPlayback: true,
                                    ),
                                error: (error, stackTrace) =>
                                    Center(child: Text('Error: $error')),
                                loading: () => const Center(
                                    child: CircularProgressIndicator())),
                            images.when(
                                data: (d) => Image.network(
                                      d.fanart != null
                                          ? d.fanart!
                                          : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                      gaplessPlayback: true,
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
                            launchUrl(Uri.parse(
                                "https://www.youtube.com/watch?v=${(data.youtubeTrailerKey == null) ? "dQw4w9WgXcQ" : data.youtubeTrailerKey}"));
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
              );
            },
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
