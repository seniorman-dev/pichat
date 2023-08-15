import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pichat/auth/screen/login_screen.dart';
import 'package:pichat/auth/screen/successful_registration_screen.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/utils/snackbar.dart';
import 'package:pichat/utils/toast.dart';








class AuthController extends ChangeNotifier{
  
  //locage storage courtesy of GetX, used to persist little amount of data
  final box = GetStorage('auth');


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
  

  //for textformfields in the (edit profile) screen to perform validation operations
  //final formKey = GlobalKey<FormState>();

  //for registration textformfields to automatically scroll to the next seamlessly
  final FocusScopeNode focusScopeNodesForReg = FocusScopeNode();
  //final GlobalKey<FormState> formkeyForReg = GlobalKey();
  final ScrollController scrollControllerForRegisteration = ScrollController();

  //for login textformfields to automatically scroll to the next seamlessly
  final FocusScopeNode focusScopeNodesForLogin = FocusScopeNode();
  //final GlobalKey<FormState> formkeyForLogin = GlobalKey();
  final ScrollController scrollControllerForLogin = ScrollController();

  //for reset piassword textformfields to automatically scroll to the next seamlessly
  final FocusScopeNode focusNodesForResetPasswordPage = FocusScopeNode();
  //final GlobalKey<FormState> formkeyForResetPasswrdPage = GlobalKey();
  final ScrollController scrollControllerForResetPasswordPage = ScrollController();

  //////////////////////////////
  bool isChecked = false;
  bool blindText1 = false;
  bool blindText2 = false;
  ////////////////////////////////////
  




  ///FOR LOGIN SCREEN
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  bool blindText3 = false;



  ///FOR RESET PASSWORD SCREEN
  final TextEditingController resetPasswordController = TextEditingController();
  

  ///dispose all
  @override
  void dispose() {
    focusScopeNodesForLogin.dispose();
    focusScopeNodesForReg.dispose();
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
  Future signUp({required BuildContext context}) async {
    try {
      //get fcm token
      String? token = await messaging.getToken();
      if(registerNameController.text.isNotEmpty && registerEmailController.text.isNotEmpty && registerPasswordController.text == registerConfirmPasswordController.text && isChecked == true) {
        UserCredential userCredential = await firebase.createUserWithEmailAndPassword(email: registerEmailController.text, password: registerPasswordController.text);
        if(userCredential.user != null) {

          //save these data of the current user so that you can persist data with get storage
          box.write('name', registerNameController.text);
          box.write('email', userCredential.user!.email);
          box.write('id', userCredential.user!.uid);
          debugPrint("My Details: ${box.read('name')} ${box.read('email')} ${box.read('id')}");

          //call firestore to add the new user
          await firestore.collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': registerNameController.text,
            'email': registerEmailController.text,
            'password': registerConfirmPasswordController.text,
            'photo': 'photo', //put dummy image link pending when the user updates his/her photo
            'id': userCredential.user!.uid,
            'isOnline': true,
            'isVerified': false,
            'location': 'location', //get from geolocator,
            'agreedToT&C': isChecked,
            'isProfileUpdated': false,
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
          // ignore: use_build_context_synchronously
          getToast(context: context, text: 'Uh-oh, something went wrong');
          //return customGetXSnackBar(title: 'Uh-Oh!', subtitle: 'Something went wrong');
        }
      }
      else {
        // ignore: use_build_context_synchronously
        getToast(context: context, text: 'Invalid credentials');
        //return customGetXSnackBar(title: 'Error', subtitle: "Invalid credentials");
      }
    } on FirebaseAuthException catch (e) {
      getToast(context: context, text: 'Erro: ${e.message}');
      //customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }
  
  //SIGN IN OR LOGIN METHOD
  Future signIn({required BuildContext context}) async {
    try {
      //get fcm token
      String? token = await messaging.getToken();

      if(loginEmailController.text.isNotEmpty && loginPasswordController.text.isNotEmpty) {
        //sign in user credentials
        UserCredential userCredential = await firebase.signInWithEmailAndPassword(email: loginEmailController.text, password: loginPasswordController.text);
        if(userCredential.user != null) {

          //do this if you want to get any logged in user property 
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();
          String userName = snapshot.get('name');
          
          //save these data of the current user so that you can persist data with get storage
          box.write('name', userName);
          box.write('email', userEmail);
          box.write('id', userID);
          debugPrint("My Details: ${box.read('name')} ${box.read('email')} ${box.read('id')}");
          
          await firestore.collection('users').doc(userCredential.user!.uid).update({"isOnline": true});
          //always update fcm_token
          await firestore.collection('users').doc(userCredential.user!.uid).update({'FCMToken': token})
          .whenComplete(() {
            Get.offAll(() => const MainPage());
            loginEmailController.clear();
            loginPasswordController.clear();
          });  //.whenComplete(() => getToast(context: context, text: 'logged in as, $userEmail'));
          getToast(context: context, text: 'logged in as, $userEmail');
        }
        else {
          return getToast(context: context, text: 'Uh-oh, something went wrong');
          //return customGetXSnackBar(title: 'Uh-Oh!', subtitle: 'Something went wrong');
        }
      }
      else {
        return getToast(context: context, text: 'Invalid credentials');
        //customGetXSnackBar(title: 'Error', subtitle: "Invalid credentials");
      }
    } on FirebaseAuthException catch (e) {
      return getToast(context: context, text: 'Error: ${e.message}');
      //customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }


  //SIGN OUT METHOD
  Future<void> signOut({required BuildContext context}) async {
    try {
      //delete the data of the exiting user so that you create room to persist data for the next user
      box.remove('name');
      box.remove('email');
      box.remove('id');
      debugPrint("My Details: ${box.read('name')} ${box.read('email')} ${box.read('id')}");

      await firestore.collection('users').doc(userID).update({"isOnline": false});
      await firebase.signOut()
      .whenComplete(() => Get.offAll(() => LoginScreen())); //.then((value) => getToast(context: context, text: 'user logged out'));
      getToast(context: context, text: 'user logged out');
    } on FirebaseAuthException catch (e) {
      return getToast(context: context, text: 'Error: ${e.message}');
      //customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
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







