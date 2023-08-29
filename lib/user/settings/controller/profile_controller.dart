import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Ezio/utils/snackbar.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:country_code_picker/country_code_picker.dart';







class ProfileController extends ChangeNotifier {
  
  
  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userEmail => firebase.currentUser!.email;
  bool isLoading = false; 

  //for selecting country (save to db) //save to db
  CountryCode? selectedCountryCode;
  String? selectedCountry;

  //for radio widget for selecting gender when a user is trying to edit and update profile
  bool isActivated = false;
  String? gender; //save to db

  
  
  //for textformfields to perform validation operations
  final GlobalKey<FormState> formKey = GlobalKey();
  //for textformfields to automatically scroll to the next seamlessly
  final FocusScopeNode focusScopeNode = FocusScopeNode();


  //final TextEditingController userNameTextController = TextEditingController();  
  final TextEditingController userLink = TextEditingController();  //save to db
  final TextEditingController userBio = TextEditingController();  //save to db
  String? selectedDate = '';  //save to db (for user's DOB)
  final ScrollController scrollController = ScrollController();
  
  
  @override
  void dispose() {
    // TODO: implement dispose
    //dispose the disposables
    focusScopeNode.dispose();
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
      path: link.replaceFirst("https://", "")
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
  
  //update user prfile
  Future<void> updateUserProfile({required BuildContext context, required String gender, required String name, required String email, required String biography, required String url, required String dob, required bool isProfileUpdated}) async{
    try {
      await firestore
      .collection('users')
      .doc(userID)
      .update({
        'name': name,
        'email': email,
        'bio': biography,
        'link': url,
        'dob': dob,
        'gender': gender, //male or female
        'country': selectedCountry,
        'isProfileUpdated': isProfileUpdated
      });
    }
    catch (e) {
      customGetXSnackBar(title: 'Uh-Oh', subtitle: '$e');
    }
  }
  



  //picked image from gallery
  File? imageFromGallery;
  //picked image from camera snap
  File? imageFromCamera;

  ////check if the image is taken from gallery or not
  bool isImageSelectedFromGallery = false;
  /// check if any image is selected at all
  bool isAnyImageSelected = false;
  
  //uploads the image to the cloud and the stores the image url to firestore database
  Future<void> uploadImageToFirebaseStorage({required File? imageFile}) async {
    //name of the folder we are first storing the file to
    String? folderName = userEmail;
    //name the file we are sending to firebase cloud storage
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    //set the storage reference as "users_photos" and the "filename" as the image reference
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('$folderName/$fileName');
    //upload the image to the cloud storage
    firebase_storage.UploadTask uploadTask = ref.putFile(imageFile!);
    //call the object and then show that it has already been uploaded to the cloud storage or bucket
    firebase_storage.TaskSnapshot taskSnapshot = 
    await uploadTask
    .whenComplete(() => debugPrint("image uploaded succesfully to fire storage"));
    //get the imageUrl from the above taskSnapshot
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    //store the imageURL to the uploader's database
    await firestore.collection('users').doc(userID).update({
      'photo': imageUrl
    });
    // to see what the url looks like
    debugPrint("Image URL: $imageUrl");
  }


  

}