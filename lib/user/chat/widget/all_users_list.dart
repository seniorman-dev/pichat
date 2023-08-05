import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/widget/buttons.dart';
import 'package:pichat/user/chat/widget/search_textfield.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';










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

  Stream<QuerySnapshot>? userStream;

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
                hintText: 'Search for connects',
                onChanged: (value) {
                  setState(() {
                    chatServiceController.isSearchingForUsers = true;
                    chatServiceController.allUsersTextEditingController.text = value;
                  });
                },
              ),

              SizedBox(height: 20.h,),

              //user stream
              StreamBuilder(
                stream: userStream ,
                builder: (context, snapshot) {

                  //filtered list. shown when a logged in user is trying to search for a user to connect with
                  var filteredList = snapshot.data!.docs.where((element) => element['name'].toString().contains(chatServiceController.allUsersTextEditingController.text)).toList();

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
                      itemCount: chatServiceController.isSearchingForUsers ? filteredList.length : snapshot.data!.docs.length,
                      itemBuilder: (context, index) {

                        var data2 = snapshot.data!.docs[index];  //normal list

                        var data = filteredList[index];  //filtered list
                         
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
                                  vertical: 15.h, //20.h
                                  horizontal: 15.w  //20.h
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme().whiteColor,
                                  borderRadius: BorderRadius.circular(20.r),
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
                                      radius: 32.r,
                                      backgroundColor: AppTheme().opacityBlue,
                                      child: CircleAvatar(
                                        radius: 30.r,
                                        backgroundColor: AppTheme().darkGreyColor,
                                      ),
                                    ),
                                    SizedBox(width: 10.w,),
                                    //details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chatServiceController.isSearchingForUsers ? data['name'] : data2['name'],
                                            style: GoogleFonts.poppins(
                                              color: AppTheme().blackColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
            
                                          SizedBox(height: 4.h,),
            
                                          //Row 2
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                chatServiceController.isSearchingForUsers
                                                ? data['isOnline'] ? 'online' : 'offline'
                                                : data2['isOnline'] ? 'online' : 'offline',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().darkGreyColor, //specify color when user is online or offline
                                                  fontSize: 14.sp, //14.sp
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              ),
                                              //connect button
                                              SendOrCancelRequestButton(
                                                receiverName: chatServiceController.isSearchingForUsers ? data['name'] : data2['name'],                                       
                                                receiverID: chatServiceController.isSearchingForUsers ? data['id'] : data2['id'], 
                                                isSelected: true, 
                                                FCMToken: chatServiceController.isSearchingForUsers ? data['FCMToken'] : data2['FCMToken'],  
                                              )                            
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
