import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:pichat/user/settings/widget/connects.dart';
import 'package:pichat/user/settings/widget/edit_profile_screen.dart';
import 'package:pichat/user/settings/widget/insights.dart';
import 'package:pichat/user/settings/widget/logout_dialogue_box.dart';
import 'package:pichat/user/settings/widget/notifications_for_profile.dart';
import 'package:pichat/user/settings/widget/posts.dart';
import 'package:pichat/user/settings/widget/profile_item.dart';
import 'package:pichat/user/settings/widget/re-posts.dart';
import 'package:pichat/user/settings/widget/view_posts.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';









class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
  
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        //appBar: CustomAppBar(title: 'Created Events'),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), //BouncingScrollPhysics(),
          child: buildBody(context),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var authController = Provider.of<AuthController>(context);
    var profileController = Provider.of<ProfileController>(context);

    //Stream of the document snapshot for the current logged-in user
    Stream<DocumentSnapshot<Map<String, dynamic>>> snapshotStream =
    authController.firestore
    .collection('users')
    .doc(authController.userID)
    .snapshots();

    return Stack(
      children: [
        //custom background
        SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              Container(
                height: 370.h, //350.h
                decoration: BoxDecoration(
                  color: AppTheme().opacityBlue, //.lightestOpacityBlue, 
                  // put the exact color later
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  )
                ),
              )
            ],
          )
        ),

          //body
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 90.h,),
             
              //streambuilder for logged in user
              StreamBuilder(
                stream: profileController.userSnapshot(),  //snapshotStream,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Loader();
                  }
                  if (snapshot.hasError) {
                    return ErrorLoader();
                  }

                  if (!snapshot.hasData) {
                    return Text(
                      'Data not found',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppTheme().blackColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500
                        )
                      ),
                    );
                  }
                  

                  //////////////**pick and save some of these to database*/////////////////
                  String checkDate = profileController.selectedDate!.isEmpty ? 'Select Date' : profileController.selectedDate!;
                  bool isProfileUpdated = snapshot.data!.data()!['isProfileUpdated'] ?? false;
                  String name = snapshot.data!.data()!['name'];
                  String email = snapshot.data!.data()!['email']; 
                  String photo = snapshot.data!.data()!['photo'];
                  String bioText = snapshot.data!.data()!['bio'] ?? 'This is a dummy bio-text. Kindly update your profile';
                  String myLink = snapshot.data!.data()!['link'] ?? 'link to other socials';
                  String myDOB = snapshot.data!.data()!['dob'] ?? checkDate;//profileController.selectedDate; //profileController.selectedDate!.isEmpty ? 'Select Date' : profileController.selectedDate!;


                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 20.h,
                    ),
                    child: Container(             
                      //height: 209.h,
                      //width: 200.w,
                      padding: EdgeInsets.symmetric(
                        vertical: 25.h, //20.h
                        horizontal: 18.w  //15.h
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme().whiteColor,
                        borderRadius: BorderRadius.circular(30.r), //20.r
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0.1.r,
                            blurRadius: 8.0.r,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //photo
                              CircleAvatar(
                                radius: 40.r,
                                backgroundColor: AppTheme().opacityBlue,
                                child: CircleAvatar(
                                  radius: 38.r,
                                  backgroundColor: AppTheme().darkGreyColor,
                                ),
                              ),
                              SizedBox(width: 10.w,),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //1
                                    Column(
                                      children: [
                                        Text(
                                          //posts
                                          '93330',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Posts',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    ),
                                    //2
                                    Column(
                                      children: [
                                        Text(
                                          //reports
                                          '93330',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Re-posts',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    ),
                                    //2
                                    Column(
                                      children: [
                                        //connects
                                        Text(
                                          '93330',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Connects',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              )
                            ],
                          ),
                          SizedBox(height: 20.h,),
                          //my name
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: AppTheme().blackColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 10.h,),
                          //about me
                          Text(
                            bioText,
                            style: GoogleFonts.poppins(
                              color: AppTheme().greyColor, //.darkGreyColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.visible
                                )
                            ),
                          ),
                          SizedBox(height: 15.h,),
                          //link to other socials or sumtin
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.link,
                                color: AppTheme().mainColor, //opacityBlue,
                                size: 20.r,
                              ),
                              SizedBox(width: 5.w),
                              //use url launcher to launch this bitch
                              InkWell(
                                onTap: () {
                                  profileController.launchLink(link: myLink);
                                },
                                child: Text(
                                  myLink,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme().mainColor, //opacityBlue,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    textStyle: const TextStyle(
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h,),
                          //Edit Profile Button and Share Profile Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //Edit Profile
                              Expanded(
                                child: SizedBox(
                                  height: 50.h,
                                  width: 100.h, //double.infinity,
                                  child: ElevatedButton( 
                                    onPressed: () {
                                      Get.to(() =>  EditProfileScreen(
                                        name: name, 
                                        email: email, 
                                        photo: photo, 
                                        dateOfBirth: myDOB, 
                                        isProfileUpdated: isProfileUpdated,
                                      ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppTheme().lightGreyColor,
                                      minimumSize: Size.copy(Size(100.w, 50.h)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                      )
                                    ), 
                                    child: Text(
                                      isProfileUpdated ? 'Edit Profile' : "Update Profile",
                                      style: GoogleFonts.poppins(  //urbanist
                                        color: AppTheme().blackColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),     
                                ),
                              ),
                              SizedBox(width: 10.w,),
                              //Share Profile
                              Expanded(
                                child: SizedBox(
                                  height: 50.h,
                                  width: 100.w, //double.infinity,
                                  child: ElevatedButton( 
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppTheme().lightGreyColor,
                                      minimumSize: Size.copy(Size(100.w, 50.h)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                      )
                                    ), 
                                    child: Text(
                                      'Post',
                                      style: GoogleFonts.poppins(  //urbanist
                                        color: AppTheme().blackColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),     
                                ),
                              )
                            ],
                          )
                                                                                                                  
                        ]
                      )
                    ),
                  );
                }
              ),

              SizedBox(height: 10.h,),
              /////////////////////////
              

              //info buttons details
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 25.w,
                  vertical: 20.h,
                ),
                child: Container(             
                  //height: 209.h,
                  //width: 200.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 25.h, //20.h
                    horizontal: 18.w  //15.h
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme().whiteColor,
                    borderRadius: BorderRadius.circular(30.r), //20.r
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.1.r,
                        blurRadius: 8.0.r,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileItem(
                        icon: CupertinoIcons.bell, 
                        onPressed: () {
                          Get.to(() => NotificationScreenForProfile());
                        }, 
                        title: 'Notifications',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.viewfinder, 
                        onPressed: () {
                          Get.to(() => ViewPostsScreen());
                        }, 
                        title: 'View Posts',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.graph_square, 
                        onPressed: () {
                          showInsightsDialogue(context);
                        }, 
                        title: 'Insights',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.exclamationmark_circle, 
                        onPressed: () {
                          profileController.launchEmail();
                        }, 
                        title: 'Support',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.person_crop_circle, 
                        onPressed: () {
                          //Get.to(() => AboutUsPage());
                        }, 
                        title: 'About us',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: Icons.logout_rounded, 
                        onPressed: () {
                          showLogoutDialogue(context);
                        }, 
                        title: 'Logout',
                      )
                    ]
                  )
                )
              ),
              SizedBox(height: 20.h,)

            ]
          )


      ]
    );    
  }
}