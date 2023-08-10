import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;







class ProfileController extends ChangeNotifier {
  
  
  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userEmail => firebase.currentUser!.email;
  bool isLoading = false;
  final formKey = GlobalKey();

  //final TextEditingController userNameTextController = TextEditingController();  
  final TextEditingController userLink = TextEditingController();  //save to db
  final TextEditingController userBio = TextEditingController();  //save to db
  String? selectedDate = '';  //save to db (for user's DOB)
  final ScrollController scrollController = ScrollController();
  
  @override
  void dispose() {
    // TODO: implement dispose
    //userNameTextController.dispose();
    userLink.dispose();
    userBio.dispose();
    scrollController.dispose();
    super.dispose();
  }
  
  //stream of logged-in user's document snapshot (i am correct)
  Stream<DocumentSnapshot<Map<String, dynamic>>> userSnapshot() async*{
    var snapshot = firestore
    .collection('users')
    .doc(userID)
    .snapshots();
    yield* snapshot;
  }

  //functions for url_launcher (to launch user socials link)
  Future<void> launchLink({required String link}) async{
    //String myPhoneNumber = "+234 07040571471";
    //Uri uri = Uri.parse(myPhoneNumber);
    Uri linkUri = Uri(
      scheme: 'https',
      path: link
    );
    if(await launcher.canLaunchUrl(linkUri)) {
      launcher.launchUrl(
        linkUri,
        mode: launcher.LaunchMode.inAppWebView
      );
    }
    else {
      throw Exception('Can not launch uri: $linkUri');
    }
  }

  //functions for url_launcher(for support contact)
  Future<void> launchEmail() async{
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries.map((MapEntry<String, String> e) =>
        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    }
    Uri emailUri = Uri(
      scheme: 'mailto', 
      path: 'japhetebelechukwu@gmail.com',
      query: encodeQueryParameters(
        <String, String>{
          'subject': 'Type Your Subject',
          'body': 'Type your Message'
        }
      ),
    );
    
    if(await launcher.canLaunchUrl(emailUri)) {
      launcher.launchUrl(emailUri);
    }
    else {
      throw Exception('Can not launch uri: $emailUri');
    }
  }
  

}