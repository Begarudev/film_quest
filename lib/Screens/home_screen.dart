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
    final nowPlayingMovies = ref.watch(nowMoviesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        toolbarHeight: 130,
        // flexibleSpace: SearchBarCustom(),
        title: const SearchBarCustom(),
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
                    cacheExtent: 800,
                    itemCount: movie.length,
                    itemBuilder: (context, index) {
                      final String movieId = movie[index].imdbId;

                      final movieImage =
                          ref.watch(movieImagesProvider(movieId));

                      return GestureDetector(
                        onTap: () {
                          context.push("/page2");
                          ref
                              .watch(movieSelectedProvider.notifier)
                              .update((state) => movie[index].imdbId);
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
                                    movie[index].title,
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
                                          movie[index].year,
                                          style: GoogleFonts.lato(
                                              color: const Color(0x86DC6565)),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              ref
                                                  .watch(movie[index]
                                                      .likeStateProvider
                                                      .notifier)
                                                  .update((state) => !state);
                                            },
                                            icon: ref.watch(movie[index]
                                                    .likeStateProvider)
                                                ? const Icon(
                                                    CupertinoIcons.heart_fill,
                                                    color: Colors.red,
                                                  )
                                                : const Icon(
                                                    CupertinoIcons.heart))
                                      ]),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 16 / 9, crossAxisCount: 2),

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
  const SearchBarCustom({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "Hello Garuda\n",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600, fontSize: 30)),
              TextSpan(
                  text: "What to Watch?",
                  style: GoogleFonts.lato(color: Colors.white70))
            ])),
            const CircleAvatar(
              backgroundColor: Color.fromRGBO(51, 12, 12, 0.6196078431372549),
              child: Icon(
                Icons.person_outline_outlined,
                color: Colors.red,
              ),
            ),
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
            onTap: () => context.push("/searchPage"),
          ),
        ),
      ],
    );
  }
}
