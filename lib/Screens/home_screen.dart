import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:film_quest/model/now_playing_movie.dart';
import 'package:film_quest/services/google_sign_in.dart';
import 'package:film_quest/services/riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final uid = GoogleSignInService().user!.uid;

  final likeStateRef =
      db.collection("users").doc(GoogleSignInService().user!.uid).snapshots();

  @override
  Widget build(BuildContext context) {
    final user = GoogleSignInService().user;
    final nowPlayingMovies = ref.watch(nowMoviesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          leading: null, toolbarHeight: 130, title: SearchBarCustom(user)),
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
                      ref.watch(getMoviesByIDProvider(movie[index].imdbId!));

                      final String movieId = movie[index].imdbId == null
                          ? 'nonexistent'
                          : movie[index].imdbId!;
                      final movieImage =
                          ref.watch(movieImagesProvider(movieId));

                      return GestureDetector(
                        onTap: () {
                          context.push("/HomeScreen/movieDetails");
                          ref.watch(movieSelectedProvider.notifier).update(
                              (state) => movie[index].imdbId == null
                                  ? 'nonexistent'
                                  : movie[index].imdbId!);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              children: [
                                // Text(movie[index].imdbId),
                                Expanded(
                                  child: movieImage.when(
                                    data: (data) {
                                      return Hero(
                                        tag: data.imdb!,
                                        child: CachedNetworkImage(
                                          imageUrl: data.poster != null
                                              ? data.poster!
                                              : 'https://www.indieactivity.com/wp-content/uploads/2022/03/File-Not-Found-Poster.png',
                                          // colorBlendMode: BlendMode.lighten,
                                        ),
                                      );
                                    },
                                    error: (error, stackTrace) =>
                                        Center(child: Text('Error: $error')),
                                    loading: () => Expanded(
                                      child: Container(
                                        color: Colors.white10,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                      )
                                          .animate(
                                            onPlay: (controller) =>
                                                controller.repeat(),
                                          )
                                          .shimmer(
                                              color: Colors.black,
                                              duration: const Duration(
                                                  milliseconds: 1000)),
                                    ),
                                  ),
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
                                          StreamBuilder(
                                            stream: likeStateRef,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                final data =
                                                    snapshot.data!.data();
                                                final likeList =
                                                    data!['likedmovies'] ?? [];
                                                return IconButton(
                                                    onPressed: () async {
                                                      if (likeList
                                                          .contains(movieId)) {
                                                        try {
                                                          await db
                                                              .collection(
                                                                  "users")
                                                              .doc(uid)
                                                              .update({
                                                            'likedmovies':
                                                                FieldValue
                                                                    .arrayRemove([
                                                              movieId
                                                            ])
                                                          });
                                                        } on FirebaseException {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Error liking'),
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        try {
                                                          await db
                                                              .collection(
                                                                  "users")
                                                              .doc(uid)
                                                              .update({
                                                            'likedmovies':
                                                                FieldValue
                                                                    .arrayUnion([
                                                              movieId
                                                            ])
                                                          });
                                                        } on FirebaseException {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Error liking post'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    icon: likeList
                                                            .contains(movieId)
                                                        ? const Icon(
                                                            CupertinoIcons
                                                                .heart_fill,
                                                            color: Colors.red,
                                                          )
                                                        : const Icon(
                                                            CupertinoIcons
                                                                .heart,
                                                            color: Colors.red,
                                                          ));
                                              }

                                              return const Center(
                                                child:
                                                    Icon(CupertinoIcons.heart),
                                              );
                                            },
                                          )
                                        ]),
                                  ],
                                )
                              ],
                            ),
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
                                          child: CachedNetworkImage(
                                              imageUrl: userProfile))
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
            Hero(
              tag: 'FavouriteMovies',
              child: IconButton(
                  onPressed: () {
                    context.push('/HomeScreen/likedMovies');
                  },
                  icon: const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                    size: 30,
                  )),
            )
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
