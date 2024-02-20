import 'package:film_quest/Screens/home_screen.dart';
import 'package:film_quest/Screens/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'search_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/page2',
      builder: (context, state) => const MovieDetails(),
    ),
    GoRoute(
      path: '/searchPage',
      builder: (context, state) => const SearchScreen(),
    )
  ],
);
