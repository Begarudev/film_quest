import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/google_sign_in.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
          onPressed: () async {
            await GoogleSignInService().signInWithGoogle(context);
          },
          child: Text(
            "Sign in With Google",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 20),
          )),
      body: const SplashContainer(),
      backgroundColor: Colors.transparent,
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
            Colors.black,
            Colors.red,
          ],
          begin: Alignment.center,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
          child: DefaultTextStyle(
        style: GoogleFonts.lato(color: Colors.white, fontSize: 40),
        child: Text(
          "Login to Continue",
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 40),
        ),
      )),
    );
  }
}
