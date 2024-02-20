import 'package:carousel_slider/carousel_slider.dart';
import 'package:film_quest/services/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/movie_by_id.dart';

class MovieDetails extends ConsumerWidget {
  const MovieDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String imdbID = ref.watch(movieSelectedProvider);
    final images = ref.watch(movieImagesProvider(imdbID));
    final movieDetails = ref.watch(getMoviesByIDProvider(imdbID));

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Column(
          children: [
            CarouselSlider(
                items: [
                  images.when(
                      data: (data) => Image.network(data.poster != null
                          ? data.poster!
                          : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png'),
                      error: (error, stackTrace) =>
                          Center(child: Text('Error: $error')),
                      loading: () =>
                          const Center(child: CircularProgressIndicator())),
                  images.when(
                      data: (data) => Image.network(data.fanart != null
                          ? data.fanart!
                          : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png'),
                      error: (error, stackTrace) =>
                          Center(child: Text('Error: $error')),
                      loading: () =>
                          const Center(child: CircularProgressIndicator())),
                ],
                options: CarouselOptions(
                  viewportFraction: 1,
                  autoPlay: true,
                  pageSnapping: true,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                )),
            movieDetails.when(
                data: (data) {
                  return Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Title",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data.title != null ? data.title! : "Not Available",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Tag Line",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data.tagline != null
                              ? data.tagline!
                              : "Not Available",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Description",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data.description != null
                              ? data.description!
                              : "Not Available",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Age Rating",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data.rated != null ? data.rated! : "Not Available",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Year of Release",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatter.format(data.releaseDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Rating",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        (data.rated != null)
                            ? Expanded(
                                child: RatingStars(
                                  value: double.parse(data.imdbRating!) / 2,
                                  maxValue: 5,
                                ),
                              )
                            : const Text(
                                "Not Available",
                                style: TextStyle(color: Colors.white),
                              ),
                        (data.youtubeTrailerKey != null)
                            ? TextButton(
                                onPressed: () => launchUrl(Uri.parse(
                                    "https://www.youtube.com/watch?v=${data.youtubeTrailerKey}")),
                                child: const Text("Open Trailer in Youtube"))
                            : const Text("Not Available")
                      ],
                    ),
                  );
                },
                error: (error, stackTrace) =>
                    Center(child: Text('Error: $error')),
                loading: () =>
                    const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}
