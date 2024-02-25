import 'package:film_quest/Screens/splash_screen_newuser.dart';
import 'package:film_quest/Screens/splash_screen_signedinuser.dart';
import 'package:film_quest/services/riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUserSignedIn = ref.watch(userProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.black,
                brightness: Brightness.dark,
                onPrimary: Colors.red)),
        home: ref.watch(userProvider).when(
          data: (data) {
            return (data == null)
                ? const SplashScreenNewUser()
                : const SplashScreenSignedInUser();
          },
          error: (error, stackTrace) {
            showDialog(
              context: context,
              builder: (context) => Center(
                child: Text("Error: $error"),
              ),
            );
            return const SplashScreenNewUser();
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        ));
  }
}
