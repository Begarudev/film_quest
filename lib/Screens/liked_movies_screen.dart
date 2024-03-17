import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:film_quest/model/now_playing_movie.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/riverpod.dart';

class LikedMoviesScreen extends ConsumerWidget {
  const LikedMoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = GoogleSignInService().user;
    final likeStateRef =
        db.collection("users").doc(GoogleSignInService().user!.uid).snapshots();
    // final String imdbID = ref.watch(movieSelectedProvider);
    // final movieDetails = ref.watch(getMoviesByIDProvider(imdbID));
    // final asyncLikeState = ref.watch(asyncLikeStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Movies"),
      ),
      body: StreamBuilder(
        stream: likeStateRef,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data();
            final likeList = data!['likedmovies'] ?? [];
            if (likeList.isEmpty) {
              return  Center(child: Text("You Have No Favourites", style: GoogleFonts.lato(fontSize: 20),),);
            } else {
              return ListView.builder(
              itemCount: likeList.length,
              itemBuilder: (context, index) {
                final images = ref.watch(movieImagesProvider(likeList[index]));
                return images.when(
                  data: (d) => Card(
                    child: ListTile(
                      onTap: () {
                        context.push("/HomeScreen/movieDetails");
                        ref
                            .watch(movieSelectedProvider.notifier)
                            .update((state) => likeList[index]);
                      },
                      title: Text(d.title!),
                      leading: Hero(
                        tag: d.imdb!,
                        child: CachedNetworkImage(
                          imageUrl: d.poster != null
                              ? d.poster!
                              : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                        ),
                      ),
                      trailing: IconButton(
                          onPressed: () async {
                            if (likeList.contains(d.imdb)) {
                              try {
                                await db
                                    .collection("users")
                                    .doc(user!.uid)
                                    .update({
                                  'likedmovies':
                                      FieldValue.arrayRemove([d.imdb])
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
                                await db
                                    .collection("users")
                                    .doc(user!.uid)
                                    .update({
                                  'likedmovies': FieldValue.arrayUnion([d.imdb])
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
                          icon: likeList.contains(d.imdb)
                              ? const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  CupertinoIcons.heart,
                                  color: Colors.red,
                                )),
                    ),
                  ),
                  error: (e, stackTrace) => Text("Error: $e"),
                  loading: () => const CircularProgressIndicator(),
                );
              },
            );
            };
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
