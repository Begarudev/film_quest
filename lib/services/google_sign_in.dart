import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Future<UserCredential> signInWithGoogle() async {
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//   final GoogleSignInAuthentication? googleAuth =
//       await googleUser?.authentication;
//
//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken,
//   );
//
//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }

class GoogleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get user => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get fireStoreMovies =>
      _firestore.collection('users').doc(user!.uid).collection('movies');

  Future<bool> signInWithGoogle(context) async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign-in
      } else {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          final email = user.email;

          if (email !=
              null /*&& email.endsWith("@pilani.bits-pilani.ac.in")*/) {
            print("Successfully signed in as: ${user.displayName}");

            await _firestore
                .collection('users')
                .doc(user.uid)
                .set({/*'username': user.displayName*/});
            print("Added user to firestore");
            res = true;
          } else {
            // Email condition not met, so sign out and display an error
            await _auth.signOut();
            await _googleSignIn.signOut();
            print("Login with an email from this domain is not allowed");
            showDialog(
              context: context,
              builder: (context) => const Center(
                child: Text("Domain is not Allowed"),
              ),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Text(e.message!),
        ),
      );
    }
    return res;
  }

  void signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
  }
}

// bool isEmailAllowed(String email) {
//   // Check if the email ends with "@pilani.bits-pilani.ac.in"
//   if (email.toLowerCase().endsWith("@pilani.bits-pilani.ac.in")) {
//     return true;
//   }
//   return false;
// }
