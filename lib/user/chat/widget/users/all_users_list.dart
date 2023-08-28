import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:Ezio/user/chat/widget/buttons.dart';
import 'package:Ezio/user/chat/widget/search_textfield.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/logout_dialogue_box.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';

import '../../../../api/api.dart';
import '../../../../utils/extract_firstname.dart';










class AllUsersList extends StatefulWidget {
  const AllUsersList({super.key});

  @override
  State<AllUsersList> createState() => _AllUsersListState();
}

class _AllUsersListState extends State<AllUsersList> {

  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  

  //for loading animation
  bool isLoading = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? userStream;

  @override
  void initState() {
    //initialized the stream
    userStream = firestore.collection('users').where("id", isNotEqualTo: firebase.currentUser!.uid).snapshots();
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {

    //providers
    //var controller = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);

    
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: SizedBox(
            height: 50.h,
            width: 85.w,
            child: IconButton(
              onPressed: () {
                Get.back();
              }, 
              icon: Icon(
                CupertinoIcons.back,
                color: AppTheme().blackColor,
                size: 30.r,
              ),
            ),
          ),
          title: const Text(
            'Find Connects'
          ),
          titleSpacing: 2,
          titleTextStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            )
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20.h,),

              //search for users
              SearchTextField(
                textController: chatServiceController.allUsersTextEditingController, 
                hintText: 'Find connects',
                onChanged: (searchText) {
                  // Update userStream when search text changes
                  setState(() {
                    userStream = FirebaseFirestore.instance
                    .collection('users')
                    //.where('id', isNotEqualTo: userID)
                    .where(
                      "name",
                      isGreaterThanOrEqualTo: searchText,
                      isLessThan: '${searchText}z'
                    )
                    .snapshots();
                  });
                },
              ),

              SizedBox(height: 20.h,),

              //user stream
              StreamBuilder(
                stream: userStream,
                builder: (context, snapshot) {

                  //filtered list. shown when a logged in user is trying to search for a user to connect with
                  //var filteredList = snapshot.data!.docs.where((element) => element['name'].toString().contains(chatServiceController.allUsersTextEditingController.text)).toList();

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while waiting for data
                    return const Loader();
                  } 
                  else if (snapshot.hasError) {
                    // Handle error if any
                    return const ErrorLoader();
                  }
                  else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 20.h,
                      ),
                      child: Center(
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 150.h,),
                            CircleAvatar(
                              radius: 100.r,
                              backgroundColor: AppTheme().lightestOpacityBlue,
                                child: Icon(
                                CupertinoIcons.person_crop_circle_badge_exclam,
                                color: AppTheme().mainColor,
                                size: 70.r,
                              ),
                            ),
                            SizedBox(height: 50.h),
                            Text(
                              'No connects found',
                              style: GoogleFonts.poppins(
                                color: AppTheme().greyColor,
                                fontSize: 14.sp,
                                //fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  else {
                    
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),  //const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {

                        var data2 = snapshot.data!.docs[index];  //normal list

                        List<dynamic> requestList = data2['friend_requests'];

                        Future<void> _sendFriendRequest() async {
                          //did this to retrieve logged in user information
                          DocumentSnapshot snapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(chatServiceController.auth.currentUser!.uid)
                          .get();
                          String userName = snapshot.get('name');
                          String userId = snapshot.get('id');
                          ////////////////////////
                          await chatServiceController.sendFriendRequest(recipientId: data2['id'])
                          .then(
                            (value) => API().sendPushNotificationWithFirebaseAPI(content: '${getFirstName(fullName: userName)} wants to connect with you 🎈', receiverFCMToken: data2['FCMToken'], title: 'Hi, ${data2['name']}')
                          )
                          .then(
                            (value) => chatServiceController.firestore.collection('users').doc(data2['id']).collection('notifications')
                            .doc(userId)
                            .set({
                              'title': 'Hi, ${getFirstName(fullName: data2['name'])}',
                              'body': '${getFirstName(fullName: userName)} wants to connect with you 🎈',
                              'timestamp': Timestamp.now(),
                          })
                        );  
                      }

                      Future<void> _cancelFriendRequest() async {
                        await chatServiceController.cancelFriendRequest(recipientId: data2['id']);
                      }
                         
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 5.h //20.h
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 30.h,),

                              Container(
                                //height: 100.h,
                                padding: EdgeInsets.symmetric(
                                  vertical: 20.h, //15.h
                                  horizontal: 15.w  //15.w
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme().whiteColor,
                                  borderRadius: BorderRadius.circular(30.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 0.1.r,
                                      blurRadius: 8.0.r,
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ////profilePic  ===>> chatServiceontroller.isSearchingForUsers ? data['photo'] : data2['photo'],
                                    CircleAvatar(
                                      radius: 38.r,
                                      backgroundColor: AppTheme().opacityBlue,
                                      child: CircleAvatar(
                                        radius: 36.r,
                                        backgroundColor: data2['photo'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                        child: data2['photo'] == null 
                                        ?null
                                        :ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                          clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                          child: CachedNetworkImage(
                                            imageUrl: data2['photo'],
                                            width: 50.w,
                                            height: 50.h,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Loader(),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.error,
                                              color: AppTheme().lightestOpacityBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w,),
                                    //details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data2['name'],
                                            style: GoogleFonts.poppins(
                                              color: AppTheme().blackColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
            
                                          SizedBox(height: 4.h,),
            
                                          //Row 2
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                data2['isOnline'] ? 'online' : 'offline',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().darkGreyColor, //specify color when user is online or offline
                                                  fontSize: 15.sp, //14.sp
                                                  fontWeight: FontWeight.normal,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              ),
                                              //connect button
                                              SizedBox(
                                                height: 35.h,
                                                //width: 85.w,
                                                child: ElevatedButton(
                                                  onPressed: () async{

                                                    if (chatServiceController.selectedDocumentIdForAllUsers.contains(userID) || requestList.contains(userID)){
                                                      chatServiceController.selectedDocumentIdForAllUsers.remove(userID);
                                                      _cancelFriendRequest();
                                                    }
                                                    else{
                                                      chatServiceController.selectedDocumentIdForAllUsers.add(userID);
                                                      _sendFriendRequest();
                                                    }
             
                                                  },  //_sendFriendRequest(),
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor: AppTheme().lightestOpacityBlue,
                                                    minimumSize: Size.copy(Size(100.w, 50.h)),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),                                          
                                                  ),        
                                                  /*icon: Icon(
                                                    chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
                                                    color: AppTheme().whiteColor,
                                                    size: 18.r,
                                                  ),*/
                                                  child: Text(
                                                    chatServiceController.selectedDocumentIdForAllUsers.contains(userID) || requestList.contains(userID)
                                                    ?'connected' : 'connect',
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                        color: AppTheme().blackColor,
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w500
                                                      )
                                                    ),
                                                  )
                                                ),
                                              )
                                              /*SendOrCancelRequestButton(
                                                receiverName: data2['name'],                                       
                                                receiverID: data2['id'], 
                                                isSelected: true, 
                                                receiverFCMToken: data2['FCMToken'], 
                                                index: index,  
                                              )*/                           
                                            ]
                                          )
                                        ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }, 
                    );
                  }         
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
