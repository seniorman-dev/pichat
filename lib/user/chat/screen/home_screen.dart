import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:Ezio/user/chat/widget/users/all_users_list.dart';
import 'package:Ezio/user/chat/widget/users/friends_list.dart';
import 'package:Ezio/user/chat/widget/recent_chats_list.dart';
import 'package:Ezio/user/chat/widget/users/request_list.dart';
import 'package:Ezio/user/chat/widget/search_textfield.dart';
import 'package:Ezio/user/notifications/screen/notifications_sceen.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:provider/provider.dart';








class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver{
  //final TextEditingController textController = TextEditingController();
  bool isLoading = false;

  final auth = FirebaseAuth.instance;
  
  //seek for permission before getting location
  Future seekPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
  
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return _getCurrentLocation();
  }


  //get the user location neat
  Future<void> _getCurrentLocation() async {
    try {
      // Get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get the human-readable address from the position
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Format the address
      String formattedAddress = placemarks.first.street ?? '';
      if (placemarks.first.subLocality != null) {
        formattedAddress += ', ${placemarks.first.subLocality!}';
      }
      if (placemarks.first.locality != null) {
        formattedAddress += ', ${placemarks.first.locality!}';
      }
      if (placemarks.first.administrativeArea != null) {
        formattedAddress += ', ${placemarks.first.administrativeArea!}';
      }
      if (placemarks.first.country != null) {
        formattedAddress += ', ${placemarks.first.country!}';
      }

      setState(() {
        location = formattedAddress;
      });
    } catch (e) {
      setState(() {
        location = "couldn't fetch location";
        debugPrint("i got this location error: $e");
      });
    }
  }

  String location= '....';

  //check if logged in user is online
  bool _isOnline = false;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    //listenToUserOnlineStatus();
    seekPermission();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // widgets binding observer helps us to check if user is actively using the app (online) or not.
  // it check the state of our app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      updateUserOnlineStatus(true);
    } else if (state == AppLifecycleState.paused) {
      updateUserOnlineStatus(false);
    } else if (state == AppLifecycleState.inactive) {
      updateUserOnlineStatus(false);
    } else if (state == AppLifecycleState.detached) {
      updateUserOnlineStatus(false);
    }
  }

  void updateUserOnlineStatus(bool isOnline) {
    final userRef = FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid);
    userRef.update({
      'isOnline': isOnline,
      'lastActive': FieldValue.serverTimestamp()
    },);
  }

  /*void listenToUserOnlineStatus() {
    final userRef = FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid);

    userRef.snapshots().listen((snapshot) {
      bool onlineStatus = snapshot.data()?['isOnline'] ?? false;
      setState(() {
        _isOnline = onlineStatus;
      });
    });
  }*/



  @override
  Widget build(BuildContext context) {
    
    //Dependency injection by provider
    var controller = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w, //25.W
                  vertical: 20.h
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h,),
                       
                    //to get logged in user's name
                    StreamBuilder(
                      stream: controller.firestore.collection('users').doc(controller.userID).snapshots(),
                      builder: (context, snapshot) {
                        //var data = snapshot.data!.data();  //how to call document snapshots
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Show a loading indicator while waiting for data
                          return Text(
                            '...',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 14.sp, //12.sp
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                        } 
                        if (snapshot.hasError) {
                          // Handle error if any
                          return Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 14.sp, //12.sp
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                        } 
                        if (snapshot.hasData) {
                          // Check if the snapshot has data before accessing it
                          var data = snapshot.data!.data(); 
                          if (data != null) {
                            // Access the data safely
                            var firstName = getFirstName(fullName: data['name']);  
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //SizedBox(height: 20.h),

                                //check if user has updated their profile (so that it can ginger them to update their profile)
                                data['isProfileUpdated'] ? SizedBox() :
                                Center(
                                  child: Container(
                                    height: 30.h,
                                    width: 140.w,
                                    //padding: EdgeInsets.all(10),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 0.h, //0.h
                                      horizontal: 5.w  //10.w
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppTheme().opacityBlue, //.whiteColor,
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
                                        Icon(
                                          size: 20.r,
                                          CupertinoIcons.settings_solid,
                                          color: AppTheme().blackColor, //.opacityBlue,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text(
                                          'update profile',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              color: AppTheme().blackColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 11.sp, //12.sp
                                              overflow: TextOverflow.ellipsis
                                            )
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                /////////////////
                                SizedBox(height: 20.h),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hello $firstName,',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          color: AppTheme().greyColor,
                                          fontSize: 13.sp, //12.sp
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            CupertinoIcons.person_add,
                                            color: AppTheme().blackColor,
                                            size: 30.r,
                                          ),
                                          onPressed: () {
                                            Get.to(() => const AllUsersList());
                                          },          
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            CupertinoIcons.app_badge,
                                            color: AppTheme().blackColor,
                                            size: 30.r,
                                          ),
                                          onPressed: () {
                                            Get.to(() => const FriendsRequestList());
                                          },          
                                        ),
                                        //SizedBox(width: 2.w,),
                                        IconButton(
                                          icon: Icon(
                                            CupertinoIcons.bell,
                                            color: AppTheme().blackColor,
                                            size: 30.r,
                                          ),
                                          onPressed: () {
                                            Get.to(() => const NotificationScreen());
                                          },          
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }                        
                          return Text(
                            'Data not found',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 13.sp,  //12.sp
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                          
                        } 
                        else {
                          return const SizedBox();
                        }
                      }
                    ),
        
                    SizedBox(height: 0.h,),
                    
                    //online status of logged in user
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /*Icon(
                          CupertinoIcons.chevron_up_circle_fill,
                          size: 20.r,
                          color: AppTheme().blackColor,
                        ),
                        SizedBox(width: 5.w,),*/
                        Text(
                          'Pichat message',
                          style: GoogleFonts.poppins(
                            color: AppTheme().blackColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            textStyle: const TextStyle(
                              overflow: TextOverflow.ellipsis
                            )
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h,), //20.h

              //search for users
              SearchTextField(
                textController: chatServiceController.recentChatsTextController, 
                hintText: 'Search for recent messages',
                onChanged: (searchText) {
                // Update recentMessagesStream when search text changes
                setState(() {
                  chatServiceController.recentChatsStream = chatServiceController.firestore
                  .collection('users')
                  .doc(chatServiceController.auth.currentUser!.uid)
                  .collection('recent_chats')
                  //.orderBy('timestamp')
                  .where(
                    "name",
                    isGreaterThanOrEqualTo: searchText,
                    isLessThan: '${searchText}z')
                    .snapshots();
                  });
                },
              ),

              SizedBox(height: 20.h,),

              //list of friends & add friend/connect button
              FriendsList(),

              SizedBox(height: 10.h,), //20.h

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 20.h,
                ),
                child: Divider(color: AppTheme().darkGreyColor, thickness: 1,),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 20.h,
                ),
                child: Text(
                  'Recent Messages',
                  style: GoogleFonts.poppins(
                    color: AppTheme().blackColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: const TextStyle(
                      overflow: TextOverflow.ellipsis
                    )
                  ),
                ),
              ),

              //SizedBox(height: 10.h,), //20.h

              //recent chats stream
              RecentChats(),

              SizedBox(height: 10.h,),
            ]
          ),
        )      
      ),
    );
  }
}