import 'dart:ui';

import 'package:film_quest/model/now_playing_movie.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:film_quest/services/riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = GoogleSignInService().user;
    final nowPlayingMovies = ref.watch(nowMoviesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        toolbarHeight: 130,
        title: SearchBarCustom(user),
      ),
      body: nowPlayingMovies.when(
          data: (data) {
            final movie = data.movieResults;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Now Playing",
                  style: GoogleFonts.lato(fontSize: 20),
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const PageScrollPhysics(),
                    itemCount: movie.length,
                    itemBuilder: (context, index) {
                      final String movieId = movie[index].imdbId == null
                          ? 'doesnotexist'
                          : movie[index].imdbId!;
                      //
                      final movieImage =
                          ref.watch(movieImagesProvider(movieId));
                      //
                      // final isLikedProvider = FutureProvider((ref) => FirebaseFirestore.instance
                      //     .collection('users')
                      //     .doc(user!.uid)
                      //     .collection('movies')
                      //     .doc(movieId)
                      //     .get());
                      //
                      // final isTick = ref.read(isLikedProvider).when(
                      //       data: (doc) => doc.data() != null ? doc.data()!['isLiked'] : false,
                      //       error: (error, stackTrace) => false,
                      //       loading: () => false,
                      //     );
                      // ref
                      //     .watch(movie[index].likeStateProvider.notifier)
                      //     .update((state) => isTick);

                      final asyncLikeState = ref.watch(asyncLikeStateProvider);
                      // final tempListState = StateProvider(
                      //     (ref) => ref.read(asyncLikeStateProvider).when(
                      //           data: (data) => data,
                      //           error: (error, stackTrace) => [error],
                      //           loading: () => [],
                      //         ));

                      return GestureDetector(
                        onTap: () {
                          context.push("/HomeScreen/movieDetails");
                          ref.watch(movieSelectedProvider.notifier).update(
                              (state) => movie[index].imdbId == null
                                  ? 'doesnotexist'
                                  : movie[index].imdbId!);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              // Text(movie[index].imdbId),
                              Expanded(
                                child: movieImage.when(
                                    data: (data) {
                                      return Image.network(
                                        data.poster != null
                                            ? data.poster!
                                            : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.network(
                                              'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                              gaplessPlayback: true);
                                        },
                                        gaplessPlayback: true,
                                        colorBlendMode: BlendMode.lighten,
                                      );
                                    },
                                    error: (error, stackTrace) =>
                                        Center(child: Text('Error: $error')),
                                    loading: () => const Center(
                                        child: CircularProgressIndicator())),
                              ),
                              Column(
                                children: [
                                  Text(
                                    movie[index].title == null
                                        ? "Not Available"
                                        : movie[index].title!,
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.redAccent),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.center,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          movie[index].year == null
                                              ? '2000'
                                              : movie[index].year!,
                                          style: GoogleFonts.lato(
                                              color: const Color(0x86DC6565)),
                                        ),
                                        switch (asyncLikeState) {
                                          AsyncData(:final value) => IconButton(
                                              onPressed: () {
                                                value.contains(movieId)
                                                    ? ref
                                                        .read(
                                                            asyncLikeStateProvider
                                                                .notifier)
                                                        .removeLikeState(
                                                            user!.uid, movieId)
                                                    : ref
                                                        .read(
                                                            asyncLikeStateProvider
                                                                .notifier)
                                                        .addLikeState(
                                                            user!.uid, movieId);
                                              },
                                              icon: value.contains(movieId)
                                                  ? const Icon(
                                                      CupertinoIcons.heart_fill,
                                                      color: Colors.red,
                                                    )
                                                  : const Icon(
                                                      CupertinoIcons.heart,
                                                      color: Colors.red,
                                                    )),
                                          AsyncError(:final error) => Expanded(
                                              child: Text('error: $error')),
                                          _ => /* (ref
                                                  .read(tempListState)
                                                  .contains(movieId))
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
                                              icon: const Icon(
                                                  CupertinoIcons.heart),
                                              color: Colors.red,
                                            )
                                        },
                                      ]),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: MediaQuery.of(context).size.width / 2),

                    // SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: null),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}

class SearchBarCustom extends ConsumerWidget {
  final user;
  const SearchBarCustom(
    this.user, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = user!.displayName!.split(' ')[0];
    final userEmail = user.email;
    final userProfile = user.photoURL;
    return Column(
      children: [
        Row(
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "Hello $userName\n",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600, fontSize: 30)),
              TextSpan(
                  text: "What to Watch?",
                  style: GoogleFonts.lato(color: Colors.white70))
            ])),
            const Spacer(),
            IconButton(
              color: const Color.fromRGBO(51, 12, 12, 0.6196078431372549),
              icon: const Icon(
                Icons.person_outline_outlined,
                color: Colors.red,
                size: 30,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 3,
                        sigmaY: 3,
                      ),
                      child: BottomSheet(
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  minRadius: 40,
                                  child: (userProfile != null)
                                      ? ClipOval(
                                          child: Image.network(userProfile))
                                      : const Center(child: Text("No Image")),
                                ),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: "User Name\n",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white54, fontSize: 10)),
                                  TextSpan(
                                      text: userName,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          height: 1,
                                          color: Colors.white70))
                                ])),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: "User Name\n",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white54, fontSize: 10)),
                                  TextSpan(
                                      text: "$userEmail",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          height: 1,
                                          color: Colors.white70))
                                ])),
                                Row(
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("Close")),
                                    const Spacer(),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          GoogleSignInService().signOut();
                                        },
                                        child: const Text(
                                          "Sign Out",
                                          style: TextStyle(color: Colors.red),
                                        )),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                        onClosing: () {
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                );
              },
            ),
            IconButton(
                onPressed: () {
                  context.push('/HomeScreen/likedMovies');
                },
                icon: const Icon(
                  CupertinoIcons.heart_fill,
                  color: Colors.red,
                  size: 30,
                ))
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: const Color(0xFF292B37),
              borderRadius: BorderRadius.circular(10)),
          child: TextField(
            canRequestFocus: false,
            decoration: InputDecoration(
              icon: const Icon(Icons.search),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              hintText: "Search Movies...",
              hintStyle: GoogleFonts.lato(),
              // filled: true,
              border: InputBorder.none,
            ),
            onTap: () => context.push("/HomeScreen/searchPage"),
          ),
        ),
      ],
    );
  }
}
