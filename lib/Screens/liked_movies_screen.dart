import 'package:film_quest/model/now_playing_movie.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/riverpod.dart';

class LikedMoviesScreen extends ConsumerWidget {
  const LikedMoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = GoogleSignInService().user;
    // final String imdbID = ref.watch(movieSelectedProvider);
    // final movieDetails = ref.watch(getMoviesByIDProvider(imdbID));
    final asyncLikeState = ref.watch(asyncLikeStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Movies"),
      ),
      body: asyncLikeState.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final images = ref.watch(movieImagesProvider(data[index]));
              return images.when(
                data: (d) => Card(
                  child: ListTile(
                    onTap: () {
                      context.push("/HomeScreen/movieDetails");
                      ref
                          .watch(movieSelectedProvider.notifier)
                          .update((state) => data[index]);
                    },
                    title: Text(d.title!),
                    leading: Image.network(
                      d.poster != null
                          ? d.poster!
                          : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                      errorBuilder: (context, error, stackTrace) => Image.network(
                          "https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png"),
                    ),
                    trailing: switch (asyncLikeState) {
                      AsyncData(:final value) => IconButton(
                          onPressed: () {
                            value.contains(d.imdb)
                                ? ref
                                    .read(asyncLikeStateProvider.notifier)
                                    .removeLikeState(user!.uid, d.imdb!)
                                : ref
                                    .read(asyncLikeStateProvider.notifier)
                                    .addLikeState(user!.uid, d.imdb!);
                          },
                          icon: value.contains(d.imdb)
                              ? const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.red,
                                  size: 30,
                                )
                              : const Icon(
                                  CupertinoIcons.heart,
                                  color: Colors.red,
                                  size: 30,
                                )),
                      AsyncError(:final error) =>
                        Expanded(child: Text('error: $error')),
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
                          iconSize: 30,
                        )
                    },
                  ),
                ),
                error: (e, stackTrace) => Text("Error: $e"),
                loading: () => const CircularProgressIndicator(),
              );
            },
          );
        },
        error: (error, stackTrace) => Text("Error: $error"),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
