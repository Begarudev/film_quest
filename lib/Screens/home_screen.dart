import 'package:film_quest/services/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlayingMovies = ref.watch(nowMoviesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const SearchBarCustom(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 200.0),
        child: nowPlayingMovies.when(
            data: (data) {
              final movie = data.movieResults;
              return GridView.builder(
                physics: const PageScrollPhysics(),
                cacheExtent: 800,
                itemCount: movie.length,
                itemBuilder: (context, index) {
                  final String movieId = movie[index].imdbId;

                  final movieImage = ref.watch(movieImagesProvider(movieId));

                  return GestureDetector(
                    onTap: () {
                      context.push("/page2");
                      ref
                          .watch(movieSelectedProvider.notifier)
                          .update((state) => movie[index].imdbId);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Text(movie[index].title),
                          Row(children: [
                            Text(movie[index].year),
                            IconButton(
                                onPressed: () {
                                  ref
                                      .watch(movie[index]
                                          .likeStateProvider
                                          .notifier)
                                      .update((state) => !state);
                                },
                                icon: ref.watch(movie[index].likeStateProvider)
                                    ? const Icon(
                                        Icons.thumb_up_sharp,
                                        color: Colors.blue,
                                      )
                                    : const Icon(Icons.thumb_up_sharp))
                          ]),
                          // Text(movie[index].imdbId),
                          movieImage.when(
                              data: (data) {
                                return Expanded(
                                  child: Image.network(
                                    data.poster != null
                                        ? data.poster!
                                        : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                          'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                          gaplessPlayback: true);
                                    },
                                    fit: BoxFit.fitWidth,
                                  ),
                                );
                              },
                              error: (error, stackTrace) =>
                                  Center(child: Text('Error: $error')),
                              loading: () => const Center(
                                  child: CircularProgressIndicator()))
                        ],
                      ),
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),

                //   const SliverGridDelegateWithMaxCrossAxisExtent(
                //       maxCrossAxisExtent: 450, mainAxisExtent: 300),
                scrollDirection: Axis.horizontal,
              );
            },
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator())),
      ),
    );
  }
}

class SearchBarCustom extends ConsumerWidget {
  const SearchBarCustom({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onTap: () => context.push("/searchPage"),
    );
  }
}
