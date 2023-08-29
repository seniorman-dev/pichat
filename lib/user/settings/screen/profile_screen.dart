import 'package:Ezio/user/settings/widget/helper_widgets/profile_item.dart';
import 'package:Ezio/utils/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/feeds/controller/feeds_controller.dart';
import 'package:Ezio/user/settings/controller/profile_controller.dart';
import 'package:Ezio/user/settings/widget/action_screens/edit_profile_screen.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/about_us.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/insights.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/logout_dialogue_box.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/notifications_for_profile.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/wallets.dart';
import 'package:Ezio/user/settings/widget/success_screens/succesfully_uploaded_feed.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/view_posts.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';
import '../widget/action_screens/upload_post_page.dart';















class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    //var authController = Provider.of<AuthController>(context);
    var profileController = Provider.of<ProfileController>(context);
    var feedsController = Provider.of<FeedsController>(context);


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
                    return const Loader();
                  }
                  if (snapshot.hasError) {
                    return const ErrorLoader();
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
                  String checkCountry = profileController.selectedCountry == null ? 'Select Country' : profileController.selectedCountry!;
                  String checkGender = profileController.gender ?? 'Gender'; //profileController.gender == null ? 'Select Gender' : profileController.gender!;
                  bool isProfileUpdated = snapshot.data!.data()!['isProfileUpdated'] ?? false;
                  String name = snapshot.data!.data()!['name'];
                  String email = snapshot.data!.data()!['email']; 
                  String photo = snapshot.data!.data()!['photo'];
                  String bioText = snapshot.data!.data()!['bio'] ?? 'Update your bio';
                  String myLink = snapshot.data!.data()!['link'] ?? 'affiliated link';
                  String myDOB = snapshot.data!.data()!['dob'] ?? checkDate;
                  String myCountry = snapshot.data!.data()!['country'] ?? checkCountry;
                  String myGender = snapshot.data!.data()!['gender'] ?? checkGender;



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
                                  backgroundColor: photo.isEmpty ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                  //backgroundColor: AppTheme().darkGreyColor,
                                  child: photo.isEmpty 
                                  ? null
                                  :ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                    clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                    child: CachedNetworkImage(
                                      imageUrl: photo,
                                      width: 50.w,
                                      height: 50.h,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Loader(),
                                      errorWidget: (context, url, error) => Icon(
                                        Icons.error,
                                        color: AppTheme().lightestOpacityBlue,
                                      ),
                                    ),
                                  ),
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
                                        StreamBuilder(
                                          stream: feedsController.getFeedsForUserProfile(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // Show a loading indicator while waiting for data
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().greyColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            } 
                                            if (snapshot.hasError) {
                                              // Handle error if any
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().redColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            }
                                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().mainColor, //.lightestOpacityBlue,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            }

                                            int itemCount = snapshot.data!.docs.length;
                                            //convert the length to string
                                            String items = itemCount.toString();

                                            return Text(
                                              itemCount >= 0 && itemCount <= 999 
                                              ? items
                                              : itemCount >= 1000 && itemCount <= 9999
                                              ? "${items[0]} K"
                                              : itemCount >= 10000 && itemCount <= 99999 
                                              ? "${items.substring(0, 2)} K"
                                              : itemCount >= 100000 && itemCount >= 999999
                                              ? "${items.substring(0, 3)} K"
                                              : itemCount >= 1000000 && itemCount <= 9999999
                                              ? "${items[0]}M"
                                              : itemCount >= 10000000 && itemCount <= 99999999
                                              ? "${items.substring(0, 2)} M"
                                              : itemCount >= 100000000 && itemCount <= 999999999
                                              ? "${items.substring(0, 3)} M"
                                              : "1 B+",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().greyColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: const TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                )
                                              ),
                                            );
                                          }
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
                                        StreamBuilder(
                                          stream: feedsController.repostStreamForUserProfile(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // Show a loading indicator while waiting for data
                                              return Text(
                                                //re-posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().greyColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            } 
                                            if (snapshot.hasError) {
                                              // Handle error if any
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().redColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            }
                                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                              return Text(
                                                //re-posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().mainColor, //.lightestOpacityBlue,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            }

                                            int itemCount = snapshot.data!.docs.length;
                                            //convert the length to string
                                            String items = itemCount.toString();
                                            
                                            return Text(
                                              //re-posts
                                              itemCount >= 0 && itemCount <= 999 
                                              ? items
                                              : itemCount >= 1000 && itemCount <= 9999
                                              ? "${items[0]} K"
                                              : itemCount >= 10000 && itemCount <= 99999 
                                              ? "${items.substring(0, 2)} K"
                                              : itemCount >= 100000 && itemCount >= 999999
                                              ? "${items.substring(0, 3)} K"
                                              : itemCount >= 1000000 && itemCount <= 9999999
                                              ? "${items[0]}M"
                                              : itemCount >= 10000000 && itemCount <= 99999999
                                              ? "${items.substring(0, 2)} M"
                                              : itemCount >= 100000000 && itemCount <= 999999999
                                              ? "${items.substring(0, 3)} M"
                                              : "1 B+",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().greyColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: const TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                )
                                              ),
                                            );
                                          }
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Saves',
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
                                        StreamBuilder(
                                          stream: feedsController.userFriends(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // Show a loading indicator while waiting for data
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().greyColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            } 
                                            if (snapshot.hasError) {
                                              // Handle error if any
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().redColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            }
                                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                              return Text(
                                                //posts
                                                '....',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme().mainColor, //.lightestOpacityBlue,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  textStyle: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  )
                                                ),
                                              );
                                            }

                                            int itemCount = snapshot.data!.docs.length;
                                            //convert the length to string
                                            String items = itemCount.toString();

                                            return Text(
                                              //connects or friends
                                              itemCount >= 0 && itemCount <= 999 
                                              ? items
                                              : itemCount >= 1000 && itemCount <= 9999
                                              ? "${items[0]} K"
                                              : itemCount >= 10000 && itemCount <= 99999 
                                              ? "${items.substring(0, 2)} K"
                                              : itemCount >= 100000 && itemCount >= 999999
                                              ? "${items.substring(0, 3)} K"
                                              : itemCount >= 1000000 && itemCount <= 9999999
                                              ? "${items[0]}M"
                                              : itemCount >= 10000000 && itemCount <= 99999999
                                              ? "${items.substring(0, 2)} M"
                                              : itemCount >= 100000000 && itemCount <= 999999999
                                              ? "${items.substring(0, 3)} M"
                                              : "1 B+",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().greyColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: const TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                )
                                              ),
                                            );
                                          }
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
                                        bio: bioText, 
                                        link: myLink,
                                        selectedCountry: myCountry,
                                        selectedGender: myGender,
                                        
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
                                    onPressed: () {
                                      Get.to(() => UploadPostPage(
                                        onPressedForSavingEveryThing: () {
                                          if(feedsController.postTextController.text.isNotEmpty && feedsController.contentFile != null) {
                                            feedsController.uploadContentToDatbase(file: feedsController.contentFile, context: context)
                                            .then((value) {
                                              setState(() {
                                                Get.to(() => const PostUpdatedSuccessScreen());
                                                feedsController.isAnyThingSelected = false;
                                                feedsController.postTextController.clear();
                                              });
                                            });
                                            //feedsController.postTextController.clear();
                                          }
                                          else{
                                            customGetXSnackBar(title: 'Uh-Oh', subtitle: 'Incomplete Credentials');
                                          }
                                        },
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
                                      'Upload Post',
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
                          Get.to(() => const NotificationScreenForProfile());
                        }, 
                        title: 'Notifications',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.viewfinder, 
                        onPressed: () {
                          Get.to(() => const ViewPostsScreen());
                        }, 
                        title: 'Activities',
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.creditcard, 
                        onPressed: () {
                          Get.to(() => const WalletScreen());
                        }, 
                        title: 'Wallet', //will imlement in the feature
                      ),
                      SizedBox(height: 20.h,),
                      ProfileItem(
                        icon: CupertinoIcons.graph_square, 
                        onPressed: () {
                          Get.to(() => const InsightScreen());
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
                          Get.to(() => const AboutUsScreen());
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