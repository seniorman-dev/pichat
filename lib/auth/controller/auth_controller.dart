import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Ezio/api/api.dart';
import 'package:Ezio/auth/screen/login_screen.dart';
import 'package:Ezio/auth/screen/successful_registration_screen.dart';
import 'package:Ezio/main_page/screen/main_page.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:Ezio/utils/snackbar.dart';








class AuthController extends ChangeNotifier{

  FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  
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

  //Registration screen focus node
  final FocusNode nameRegNode = FocusNode();
  final FocusNode emailRegNode =  FocusNode();
  final FocusNode passwordRegNode =  FocusNode();
  final FocusNode cpasswordRegNode =  FocusNode();

  

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
            'friend_requests': [],
            'timestamp': Timestamp.now()
          })
          .then((val) async => await firestore.collection('users').doc(userCredential.user!.uid).update({'FCMToken': token}))
          .then((value) {
            //API().showFLNP(title: 'Registration Successful', body: "Welcome onboard ${getFirstName(fullName: registerNameController.text)}", fln: fln);
            API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: token!, title: 'Registration Successful', content: "Welcome onboard ${getFirstName(fullName: registerNameController.text)}");
          })
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
          return customGetXSnackBar(title: 'Uh-Oh!', subtitle: 'Something went wrong');
        }
      }
      else {
        // ignore: use_build_context_synchronously
        return customGetXSnackBar(title: 'Error', subtitle: "Invalid credentials");
      }
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
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
          .then((value) {
            Get.offAll(() => const MainPage());
            loginEmailController.clear();
            loginPasswordController.clear();
          })
          .then((value) {
            //API().showFLNP(title: 'Registration Successful', body: "Welcome onboard ${getFirstName(fullName: registerNameController.text)}", fln: fln);
            API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: token!, title: 'Login Successful', content: "Welcome Back ${getFirstName(fullName: userName)}!");
          });
          customGetXSnackBar(title: 'Yayy! 🎈 ', subtitle: "logged in as, $userEmail");
          
        }
        else {
          return customGetXSnackBar(title: 'Uh-Oh!', subtitle: 'Something went wrong');
        }
      }
      else {
        return customGetXSnackBar(title: 'Error', subtitle: "Invalid credentials");
      }
    } on FirebaseAuthException catch (e) {
      return customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }


  //SIGN OUT METHOD
  Future<void> signOut({required BuildContext context}) async {
    try {
      //get fcm token
      String? token = await messaging.getToken();
      //do this if you want to get any logged in user property 
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .get();
      String userName = snapshot.get('name');
      String FCMToken = snapshot.get('FCMToken');
      //delete the data of the exiting user so that you create room to persist data for the next user
      box.remove('name');
      box.remove('email');
      box.remove('id');
      debugPrint("My Details: ${box.read('name')} ${box.read('email')} ${box.read('id')}");

      await firestore.collection('users').doc(userID).update({"isOnline": false});
      await firebase.signOut()
      .then((value) => Get.offAll(() => const LoginScreen()))
      .then((value) {
        //API().showFLNP(title: 'Registration Successful', body: "Welcome onboard ${getFirstName(fullName: registerNameController.text)}", fln: fln);
        API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: token!, title: 'Exit Successful', content: "User logged out");
      });
    } on FirebaseAuthException catch (e) {
      return customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }

  //ResetPassword Method
  Future resetPassword () async {
    try {  
      //get fcm token
      String? token = await messaging.getToken();
      await firebase.sendPasswordResetEmail(email: resetPasswordController.text)
      .then((value) {
        API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: token!, title: 'Reset Request Approved', content: "Please check your mail for more information.");
      });
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }

  

  final googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly', //'https://www.googleapis.com/auth/drive',
    ],
  );

  Future<void> handleGoogleSignIn({required BuildContext context})async{
    //get fcm token
    String? token = await messaging.getToken();

    final res = await googleSignIn.signIn();
    final auth = await res!.authentication;
    final credentials = GoogleAuthProvider.credential(accessToken: auth.accessToken, idToken: auth.idToken);
    final firebaseUser = (await firebase.signInWithCredential(credentials)).user;
    if(firebaseUser != null){
      final results = (await firestore.collection('users').where('id', isEqualTo: firebaseUser.uid).get()).docs;

      if(results.isEmpty){
        //save these data of the current user so that you can persist data with get storage
        box.write('name', firebaseUser.displayName);
        box.write('email', firebaseUser.email);
        box.write('id', firebaseUser.uid);
        debugPrint("My Details: ${box.read('name')} ${box.read('email')} ${box.read('id')}");
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'email': firebaseUser.email,
          "id": firebaseUser.uid,
          "name": firebaseUser.displayName,
          'password': registerConfirmPasswordController.text,
          'photo': 'photo', //put dummy image link pending when the user updates his/her photo
          'isOnline': true,
          'isVerified': firebaseUser.emailVerified,
          'location': 'location', //get from geolocator or google maps,
          'agreedToT&C': isChecked,
          'isProfileUpdated': false,
          "timestamp": Timestamp.now()
        })
        .then((val) async => await firestore.collection('users').doc(firebaseUser.uid).update({'FCMToken': token}))
        .then((value) {API().showFLNP(title: 'Sign In Successful', body: "Welcome onboard ${getFirstName(fullName: firebaseUser.displayName!)} ✨", fln: fln);})
        .then((val) {
          Get.offAll(() => const SuccessfulRegistrationScreen());
        });  
      } 
      else{
        Get.to(() => const MainPage());
      }
    } else {
      customGetXSnackBar(title: 'Uh-Oh', subtitle: 'User does not exit');
    }

  }
  
  //use "whenComplete" to navigate to the login screen after you've signed ou
  Future handleGoogleSignOut() async{
    final res = await googleSignIn.signOut();
    return res;
  }





  ////////////////////////////////////////////////////////////////////////////////////


}







