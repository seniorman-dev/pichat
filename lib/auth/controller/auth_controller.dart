import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pichat/auth/screen/login_screen.dart';
import 'package:pichat/auth/screen/onboarding_screen.dart';
import 'package:pichat/auth/screen/successful_registration_screen.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/utils/snackbar.dart';








class AuthController extends ChangeNotifier{


  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userDisplayName => firebase.currentUser!.displayName;
  String? get userEmail => firebase.currentUser!.email;
  bool isLoading = false;
  //final whenACurrentUserSwitchesAccountOrChanges = GoogleSignIn().onCurrentUserChanged;
  //final GoogleSignInAccount? googleUser = GoogleSignIn().currentUser;  //use this to fetch current user details
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  

  ///FOR REGISTERATION SCREEN
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerConfirmPasswordController = TextEditingController();
  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
    ? 'Enter a valid email address'
    : null;
  }

  bool isChecked = false;
  bool blindText1 = false;
  bool blindText2 = false;
  ////////////////////////////////////
  


  ///FOR LOGIN SCREEN
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  String? validateEmailForLogin(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
    ? 'Enter a valid email address'
    : null;
  }
  bool blindText3 = false;

  ///FOR RESET PASSWORD SCREEN
  final TextEditingController resetPasswordController = TextEditingController();
  
  ///dispose all
  @override
  void dispose() {
    // TODO: implement dispose
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    resetPasswordController.dispose();
    super.dispose();
  }



  //SIGN UP / REGISTER METHOD
  Future signUp() async {
    try {
      //get fcm token
      String? token = await messaging.getToken();
      if(registerNameController.text.isNotEmpty && registerEmailController.text.isNotEmpty && registerPasswordController.text == registerConfirmPasswordController.text && isChecked == true) {
        UserCredential userCredential = await firebase.createUserWithEmailAndPassword(email: registerEmailController.text, password: registerPasswordController.text);
        if(userCredential.user != null) {
          //save these data of the current user so that you can persist data with get storage
          final box = GetStorage();
          box.write('name', registerNameController.text);
          box.write('id', userCredential.user!.uid);
          debugPrint("My Name: ${box.read('name')}");

          //call firestore to add the new user
          await firestore.collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': registerNameController.text,
            'email': registerEmailController.text,
            'password': registerConfirmPasswordController.text,
            //'photo': 'photoURL', //upload photo from profile
            'id': userCredential.user!.uid,
            'isOnline': true,
            'isVerified': false,
            'location': 'location', //get from geolocator,
            'agreedToT&C': isChecked,
            'timestamp': Timestamp.now()
          })
          .then((val) async => await firestore.collection('users').doc(userCredential.user!.uid).update({'FCMToken': token}))
          .then((val) {
            Get.offAll(() => const SuccessfulRegistrationScreen());
            registerNameController.clear();
            registerEmailController.clear();
            registerPasswordController.clear();
            registerConfirmPasswordController.clear();
          });
        }

        else {
          return customGetXSnackBar(title: 'Uh-Oh!', subtitle: 'Something went wrong');
        }
      }
      else {
        customGetXSnackBar(title: 'Error', subtitle: "Invalid credentials");
      }
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }
  
  //SIGN IN OR LOGIN METHOD
  Future signIn() async {
    try {
      //get fcm token
      String? token = await messaging.getToken();

      if(loginEmailController.text.isNotEmpty && loginPasswordController.text.isNotEmpty) {
        //sign in user credentials
        UserCredential userCredential = await firebase.signInWithEmailAndPassword(email: loginEmailController.text, password: loginPasswordController.text);
        if(userCredential.user != null) {
          //always update fcm_token
          await firestore.collection('users').doc(userCredential.user!.uid).update({'FCMToken': token})
          .whenComplete(() {
            Get.offAll(() => MainPage());
            loginEmailController.clear();
            loginPasswordController.clear();
          });
        }
        else {
          return customGetXSnackBar(title: 'Uh-Oh!', subtitle: 'Something went wrong');
        }
      }
      else {
        customGetXSnackBar(title: 'Error', subtitle: "Invalid credentials");
      }
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }


  //SIGN OUT METHOD
  Future<void> signOut() async {
    try {
      await firebase.signOut().whenComplete(() => Get.offAll(() => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }

  //ResetPassword Method
  Future resetPassword () async {
    try {
      await firebase.sendPasswordResetEmail(email: resetPasswordController.text)
      .whenComplete(() => customGetXSnackBar(title: 'Request Successful', subtitle: "we've sent a link to your mail to reset your password"));
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }

  






  ////////////////////////////////////////////////////////////////////////////////////
  /*Future<void> signInWithGoogle() async{
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
  }*/


}







