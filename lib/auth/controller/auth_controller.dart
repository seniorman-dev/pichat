import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pichat/auth/screen/google_sign_in_screen.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/utils/snackbar.dart';






class AuthController extends ChangeNotifier{

  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final whenACurrentUserSwitchesAccountOrChanges = GoogleSignIn().onCurrentUserChanged;
  final GoogleSignInAccount? googleUser = GoogleSignIn().currentUser;  //use this to fetch current user details
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  Future<void> signInWithGoogle() async{
    try {
      //begin interactive sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        serverClientId: '930937927575-ih02cie0tgno7in6ge9vapaeppj7dui6.apps.googleusercontent.com'
      ).signIn();
      //obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      //create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken
      );
      //get fcm token
      String? token = await messaging.getToken();

      //finally sign in the user and add their details or credentials to Firebase
      UserCredential userCredential = await firebase.signInWithCredential(credential);  //.whenComplete(() async =>
      debugPrint(userCredential.user!.displayName);
      debugPrint(userCredential.user!.email);
      debugPrint(userCredential.user!.uid);
      debugPrint("${userCredential.user!.emailVerified}");
      debugPrint(userCredential.user!.phoneNumber);
      debugPrint(userCredential.user!.photoURL);

      if(userCredential.user != null) {
        Get.to(() => MainPage());
        await firestore.collection('users')
        .doc(gUser.id)
        .set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photo': userCredential.user!.photoURL,
          'id': userCredential.user!.uid,
          'isOnline': true,
          'isVerified': false,
          'location': 'location' //get from geolocator,
        }).whenComplete(() async => await firestore.collection('users').doc(gUser.id).update({'FCMToken': token}));
      }
      /*else {
        return customGetXSnackBar(title: 'Uh - Oh!', subtitle: 'Something went wrong');
      }*/

    }
    catch(e) {
      debugPrint('Sign In Error: $e');
    }
  }


  /////////////////
  Future<void> handleSignIn() async {
    try {
      GoogleSignInAccount? account = await GoogleSignIn(serverClientId: '930937927575-ih02cie0tgno7in6ge9vapaeppj7dui6.apps.googleusercontent.com').signIn();
      if (account != null) {
        // The user signed in successfully, you can now use the account information.
        print('User signed in: ${account.displayName}');
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  //////////////
   Future<void> handleSignOut() async {
    try {
      await GoogleSignIn(serverClientId: '930937927575-ih02cie0tgno7in6ge9vapaeppj7dui6.apps.googleusercontent.com').signOut();
      await firebase.signOut();
      Get.offAll(() => GoogleSignInScreen());
      print('User signed out');
    } catch (error) {
      print('Error signing out: $error');
    }
  }


}







