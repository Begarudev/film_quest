import 'package:film_quest/Screens/home_screen.dart';
import 'package:film_quest/Screens/movie_details.dart';
import 'package:film_quest/Screens/splash_screen_newuser.dart';
import 'package:film_quest/Screens/splash_screen_signedinuser.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'liked_movies_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
            onPrimary: Colors.red,
          ),
          dialogBackgroundColor:
              const Color.fromRGBO(87, 31, 19, 0.7803921568627451)),
      debugShowCheckedModeBanner: false,
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/HomeScreen',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
        path: '/HomeScreen',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'likedMovies',
            builder: (context, state) => const LikedMoviesScreen(),
          ),
          GoRoute(
            path: 'searchPage',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: 'movieDetails',
            builder: (context, state) => const MovieDetails(),
          ),
        ]),
    GoRoute(
      path: '/splashScreenNewUser',
      builder: (context, state) => const SplashScreenNewUser(),
    ),
    GoRoute(
      path: '/splashScreenOldUser',
      builder: (context, state) => const SplashScreenSignedInUser(),
    ),
  ],
);
