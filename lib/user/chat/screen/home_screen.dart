import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/widget/all_users_list.dart';
import 'package:pichat/user/chat/widget/friends_list.dart';
import 'package:pichat/user/chat/widget/recent_chats_list.dart';
import 'package:pichat/user/chat/widget/request_list.dart';
import 'package:pichat/user/chat/widget/search_textfield.dart';
import 'package:pichat/user/notifications/screen/notifications_sceen.dart';
import 'package:pichat/utils/extract_firstname.dart';
import 'package:provider/provider.dart';








class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //final TextEditingController textController = TextEditingController();
  bool isLoading = false;
  
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

  @override
  void initState() {
    super.initState();
    seekPermission();
  }

  




  @override
  Widget build(BuildContext context) {
    
    //Dependency injection by provider
    var controller = Provider.of<AuthController>(context);
    var chatServiceontroller = Provider.of<ChatServiceController>(context);

    //function called when a recent chat message is being searched for
    void onSearch() async{
      setState(() {
        isLoading = true;
        chatServiceontroller.isSearchingRecentChats = true;
      });
      await chatServiceontroller.firestore.collection('users').doc(chatServiceontroller.auth.currentUser!.uid).collection('recent_chats').where("name", isEqualTo: chatServiceontroller.allUsersTextEditingController.text).get().then((value) => setState(() => isLoading = false));
    }

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
                    SizedBox(height: 30.h,),   
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
                            return Text(
                              'Hello $firstName,',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: AppTheme().darkGreyColor,
                                  fontSize: 14.sp, //12.sp
                                  fontWeight: FontWeight.w500
                                )
                              ),
                            );
                          }                        
                          return Text(
                            'Data not found',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 14.sp,  //12.sp
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
        
                    //SizedBox(height: 5.h,),

                    //////////////GEOLOCATOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () async{},
                              child: Icon(
                                CupertinoIcons.placemark_fill,
                                color: AppTheme().blackColor,
                              ),
                            ),

                            SizedBox(width: 2.w),
                            
                            Text(
                              location,
                              style: GoogleFonts.poppins(
                                color: AppTheme().blackColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            )
                          ],
                        ),
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
                    )
                  ],
                ),
              ),

              SizedBox(height: 5.h,),

              //find connects button
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //find connects button
                    SizedBox(
                      height: 40.h,
                      //width: 120.w,
                      child: ElevatedButton( 
                        onPressed: () {
                          Get.to(() => const AllUsersList());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme().lightestOpacityBlue,
                          minimumSize: Size.copy(Size(100.w, 50.h)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          )
                        ), 
                        child: Text(
                          'find connects',
                          style: TextStyle(
                            color: AppTheme().mainColor,  //.blackColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),     
                    ),
                    //connect requests button
                    SizedBox(
                      height: 40.h,
                      //width: 190.w,
                      child: ElevatedButton( 
                        onPressed: () {
                          Get.to(() => const FriendsRequestList());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme().lightestOpacityBlue,
                          minimumSize: Size.copy(Size(100.w, 50.h)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          )
                        ), 
                        child: Text(
                          'connect requests',
                          style: TextStyle(
                            color: AppTheme().mainColor,  //.blackColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),     
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h,), //20.h

              //list of friends
              const FriendsList(),

              SizedBox(height: 10.h,), //20.h

              Divider(color: AppTheme().darkGreyColor, thickness: 1,),

              SizedBox(height: 10.h,), //20.h

              //search for recent chats
              SearchTextField(
                textController: chatServiceontroller.allUsersTextEditingController,
                onChanged: (value) {
                  setState(() {
                    isLoading = true;
                    chatServiceontroller.isSearchingRecentChats = true;
                    chatServiceontroller.allUsersTextEditingController.text = value;
                  });
                }, 
                hintText: 'Search recent messages...',
              ),

              SizedBox(height: 10.h,), //20.h

              //recent chats stream
              RecentChats(
                isSearching: chatServiceontroller.isSearchingRecentChats,
                textController: chatServiceontroller.allUsersTextEditingController,
              ),

              SizedBox(height: 10.h,),
            ]
          ),
        )      
      ),
    );
  }
}