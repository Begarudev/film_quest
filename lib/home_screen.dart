import 'package:film_quest/riverpod.dart';
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
        title: const SearchBar(),
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
                          Text(movie[index].year),
                          // Text(movie[index].imdbId),
                          movieImage.when(
                              data: (data) {
                                return Expanded(
                                  child: Image.network(
                                    data.poster,
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

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({
    super.key,
  });

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  @override
  Widget build(BuildContext context) {
    Iterable<Widget> getSuggestions(SearchController controller) {
      final String input = controller.value.text;
      // final String input = ref.watch(searchInputTextProvider.notifier).update((state) => controller.text);

      final moviesByName = ref.watch(getMoviesByNameProvider(input));
      return moviesByName.when(
          data: (data) {
            return data.movieResults.map((e) => Text(e.title));
          },
          error: (error, stackTrace) => [Center(child: Text('Error: $error'))],
          loading: () => [const Center(child: CircularProgressIndicator())]);
    }

    return SearchAnchor.bar(
      // onTap: () => getSuggestions(controller),
      isFullScreen: true,
      barHintText: "Search Your Favourite Movie...",
      barLeading: const Icon(Icons.search),
      suggestionsBuilder: (context, controller) => getSuggestions(controller),
    );
  }
}
