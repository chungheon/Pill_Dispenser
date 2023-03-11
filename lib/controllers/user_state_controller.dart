import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pill_dispenser/controllers/patient_info_mixin.dart';
import 'package:pill_dispenser/controllers/user_info_mixin.dart';

class UserStateController extends GetxController
    with UserInfoMixin, PatientInfoMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final RxInt syncProgress = 0.obs;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>['email', 'profile']);

  @override
  void onInit() {
    super.onInit();
    firebaseAuth.authStateChanges().listen((event) {
      user.value = event;
      if (event != null) {
        displayName.value = event.displayName ?? '';
      } else {
        displayName.value = '';
      }
    });
  }

  Future<bool> updateDetails(
      String name, String contact, DateTime? bday) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      return await updateUserDetails(name, contact, bday);
    } else {
      return false;
    }
  }

  void logOut() {
    flutterLocalNotificationsPlugin.cancelAll();
    syncProgress.value = 0;
    clearUserData();
    firebaseAuth.signOut();
  }

  void fetchDefaultName() {
    displayName.value = user.value?.displayName ?? '';
  }

  Future<UserCredential> loginWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
      return Future.error('Unable to sign in with Google');
    }

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> sendRecoverPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      return Future.error(e);
    }
  }

  Future<UserCredential> loginWithEmailPassword(
      String email, String password) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return Future.error(e);
    }
  }

  Future<UserCredential> registerEmailPassword(
      String email, String password) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return Future.error(e);
    }
  }
}
