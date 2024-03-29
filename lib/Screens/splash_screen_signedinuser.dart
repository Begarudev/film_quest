import 'package:film_quest/Screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/riverpod.dart';

class SplashScreenSignedInUser extends ConsumerWidget {
  const SplashScreenSignedInUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlayingMovies =
        ref.watch(nowMoviesProvider).whenData((value) => value);

    return nowPlayingMovies.when(
      data: (data) {
        return const MainScreen();
      },
      error: (error, stackTrace) {
        return Center(
          child: Text("Error: $error"),
        );
      },
      loading: () {
        return const SplashContainer();
      },
    );
  }
}

class SplashContainer extends StatelessWidget {
  const SplashContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        backgroundBlendMode: BlendMode.darken,
        gradient: LinearGradient(
          colors: [
            Colors.red,
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
      child: Center(
          child: DefaultTextStyle(
        style: GoogleFonts.lato(color: Colors.white, fontSize: 40),
        child: Text(
          "Welcome Back",
          style: GoogleFonts.lato(color: Colors.white, fontSize: 40),
        ),
      )),
    );
  }
}
