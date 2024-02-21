import 'package:film_quest/services/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final searchText = ref.watch(searchInputTextProvider);

    final moviesList = ref.watch(getMoviesByNameProvider(searchText));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              ctx.pop();
            },
            icon: const Icon(Icons.arrow_back_outlined)),
        title: TextField(
          autofocus: true,
          onChanged: (value) {
            ref
                .watch(searchInputTextProvider.notifier)
                .update((state) => value);
          },
        ),
      ),
      body: moviesList.when(
          data: (data) {
            if (data.movieResults == null) {
              return const Center(
                child: Text("No Results Found Try Something else.."),
              );
            } else if (searchText.isEmpty) {
              return Container();
            } else {
              return ListView.builder(
                itemCount: data.movieResults!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(data.movieResults![index].title != null
                        ? data.movieResults![index].title!
                        : ""),
                    onTap: () {
                      context.push("/page2");
                      ref
                          .watch(movieSelectedProvider.notifier)
                          .update((state) => data.movieResults![index].imdbId!);
                    },
                  );
                },
              );
            }
          },
          error: (error, stackTrace) => Center(child: Text("Error: $error")),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
