import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/feeds/controller/feeds_controller.dart';
import 'package:Ezio/user/chat/widget/video/video_player_widget.dart';
import 'package:Ezio/utils/firestore_timestamp_formatter.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';
import '../../../../utils/error_loader.dart';









class MyPosts extends StatefulWidget {
  const MyPosts({super.key});

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  @override
  Widget build(BuildContext context) {
    bool showDateHeader = true;

    var feedsController = Provider.of<FeedsController>(context);

    return StreamBuilder(
      stream: feedsController.getFeedsForUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return const Loader();
        } 
        if (snapshot.hasError) {
          // Handle error if any
          return const ErrorLoader();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { //!snapshot.hasData || snapshot.data!.docs.isEmpty
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.w,
              vertical: 20.h,
            ),
            child: Center(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 210.h,),
                  CircleAvatar(
                    radius: 100.r,
                    backgroundColor: AppTheme().lightestOpacityBlue,
                    child: Icon(
                      CupertinoIcons.arrow_up_circle,
                      color: AppTheme().mainColor,
                      size: 70.r,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "No post found",
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
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          separatorBuilder: (context, index) => SizedBox(height: 10.h,),  //20.h
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {

            var data = snapshot.data!.docs[index];  //normal list
            // Check if the current post's date is different from the previous message's date
            if (index > 0) {
              var previousData = snapshot.data!.docs[index - 1];
              var currentDate = formatDate(timestamp: data['timestamp']);
              var previousDate = formatDate(timestamp: previousData['timestamp']);
              showDateHeader = currentDate != previousDate;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //SizedBox(height: 10.h,),
                //Show the date header if needed
                if (showDateHeader)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 30.h, 
                        horizontal: 120.w
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 30.h,
                        //width: 150.w,
                        padding: EdgeInsets.symmetric(
                          //vertical: 0.h, //20.h
                          horizontal: 5.w  //15.h
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme().lightGreyColor,
                          borderRadius: BorderRadius.circular(10.r),
                          /*boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              //color: AppTheme().lightGreyColor,
                              spreadRadius: 0.1.r,
                              blurRadius: 8.0.r,
                            )
                          ],*/
                        ),
                        child: Text(
                          formatDate(timestamp: data['timestamp']),
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                //SizedBox(height: 10.h,),
                //
                InkWell(
                  onLongPress: () {
                    //show post statistics (feature coming soon)
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 20.h
                    ),
                    child: Container(             
                      padding: EdgeInsets.symmetric(
                        vertical: 25.h, //20.h
                        horizontal: 10.w  //15.h
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
                          ///1st component
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //profilePic of the poster
                              CircleAvatar(
                                radius: 32.r,
                                backgroundColor: AppTheme().opacityBlue,
                                child: CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: data['posterPhoto'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                  //backgroundColor: AppTheme().darkGreyColor,
                                  child: data['posterPhoto'] == null ? null
                                  :ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                    clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                    child: CachedNetworkImage(
                                      imageUrl: data['posterPhoto'],
                                      width: 30.w,
                                      height: 30.h,
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          data['posterName'],
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: AppTheme().lightGreyColor,
                                          radius: 20.r,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.cancel_rounded //.more_horiz_rounded,
                                            ),
                                            color: AppTheme().blackColor,
                                            iconSize: 20.r,
                                            onPressed: () {
                                              //leave this here for now
                                              feedsController.letPosterDeletePost(context: context, postId: data['postId']);
                                            },
                                          )
                                        )
                                      ],
                                    ),
                                    //SizedBox(height: 5.h,),                       
                                    Text(
                                      formatTime(timestamp: data['timestamp']),
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().greyColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        textStyle: const TextStyle(
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ],
                          ),
                          ///2nd component
                          SizedBox(height: 10.h,),
                          Text(
                            data['postTitle'],
                            style: GoogleFonts.poppins(
                              color: AppTheme().blackColor,
                              fontSize: 13.sp,
                              //fontWeight: FontWeight.w500,
                              /*textStyle: TextStyle(
                                overflow: TextOverflow.ellipsis
                              )*/
                            ),
                          ),
                          SizedBox(height: 10.h,),
                          /*remove the sizedBox below later*/
                          SizedBox(
                            height: 400.h,//MediaQuery.of(context).size.height,
                            width:  MediaQuery.of(context).size.width, //double.infinity,
                            child: Card(
                              color: AppTheme().lightGreyColor,
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0.r), //20.r
                              ),
                              elevation: 0,
                              child: data['isImage'] ? CachedNetworkImage(
                                imageUrl: data['postContent'],
                                //width: 50.w,
                                //height: 50.h,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Loader(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: AppTheme().lightestOpacityBlue,
                                ),
                              ) : VideoPlayerItem(videoUrl: data['postContent'],),
                            ),
                          ),
                          SizedBox(height: 15.h,),

                        
                        
                        //2
                        ///////////////////////////////////////////////////////////////////////////
                        
                        //wrap with padding /////////check this thing well for null errors
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                ////#1
                                StreamBuilder(
                                  stream: feedsController.postLikesForUserProfile(postId: data['postId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      // Show a loading indicator while waiting for data
                                      return Text(
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().greyColor,
                                          fontSize: 13.sp,
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
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().redColor,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return Text(
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().mainColor, //.lightestOpacityBlue,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      );
                                    }
                                    //get the document for the document snapshot
                                    int likes = snapshot.data!.docs.length;
                                    //convert the length to string
                                    String likesToString = likes.toString();
                                    
                                    return Row(
                                      children: [
                                        Text(
                                          likes >= 0 && likes <= 999 
                                          ? likesToString
                                          :likes >= 1000 && likes <= 9999
                                          ? "${likesToString[0]}K"
                                          : likes >= 10000 && likes <= 99999 
                                          ? "${likesToString.substring(0, 2)}K"
                                          : likes >= 100000 && likes >= 999999
                                          ? "${likesToString.substring(0, 3)}K"
                                          : likes >= 1000000 && likes <= 9999999
                                          ? "${likesToString[0]}M"
                                          : likes >= 10000000 && likes <= 99999999
                                          ? "${likesToString.substring(0, 2)}M"
                                          : likes >= 100000000 && likes <= 999999999
                                          ? "${likesToString.substring(0, 3)}M"
                                          : "1 B+",
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        SizedBox(width: 5.w,),
                                        Text(
                                          likes >= 0 && likes <= 1 ? 'like' : 'likes',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 12.sp,
                                            //fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),

                                SizedBox(width: 10.w,),
                                    
                                //#2
                                StreamBuilder(
                                  stream: feedsController.postCommentsForUserProfile(postId: data['postId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      // Show a loading indicator while waiting for data
                                      return Text(
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().greyColor,
                                          fontSize: 13.sp,
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
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().redColor,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return Text(
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().mainColor, //.lightestOpacityBlue,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      );
                                    }
                                    //get the document for the document snapshot
                                    int comments = snapshot.data!.docs.length;
                                    //convert the length to string
                                    String commentsToString = comments.toString();                                        
                                    return Row(
                                      children: [
                                        Text(
                                          comments >= 0 && comments <= 999 
                                          ? commentsToString
                                          : comments >= 1000 && comments <= 9999
                                          ? "${commentsToString[0]}K"
                                          : comments >= 10000 && comments <= 99999 
                                          ? "${commentsToString.substring(0, 2)}K"
                                          : comments >= 100000 && comments >= 999999
                                          ? "${commentsToString.substring(0, 3)}K"
                                          : comments >= 1000000 && comments <= 9999999
                                          ? "${commentsToString[0]}M"
                                          : comments >= 10000000 && comments <= 99999999
                                          ? "${commentsToString.substring(0, 2)}M"
                                          : comments >= 100000000 && comments <= 999999999
                                          ? "${commentsToString.substring(0, 3)}M"
                                          : "1 B+",
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        SizedBox(width: 5.w,),
                                        Text(
                                          comments >= 0 && comments <= 1 ? 'comment' : 'comments',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 12.sp,
                                            //fontWeight: FontWeight.w500,
                                            textStyle: TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),

                                SizedBox(width: 10.w,),
                                    
                                //#3
                                StreamBuilder(
                                  stream: feedsController.repostStreamForUserProfile(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      // Show a loading indicator while waiting for data
                                      return Text(
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().greyColor,
                                          fontSize: 13.sp,
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
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().redColor,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return Text(
                                        '...',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().mainColor, //.lightestOpacityBlue,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      );
                                    }
                                    //get the document for the document snapshot
                                    int reposts = snapshot.data!.docs.length;
                                    String repostsToString = reposts.toString();
                                    return Row(
                                      children: [
                                        Text(
                                          reposts >= 0 && reposts <= 999 
                                          ? repostsToString
                                          : reposts >= 1000 && reposts <= 9999
                                          ? "${repostsToString[0]}K"
                                          : reposts >= 10000 && reposts <= 99999 
                                          ? "${repostsToString.substring(0, 2)}K"
                                          : reposts >= 100000 && reposts >= 999999
                                          ? "${repostsToString.substring(0, 3)}K"
                                          : reposts >= 1000000 && reposts <= 9999999
                                          ? "${repostsToString[0]}M"
                                          : reposts >= 10000000 && reposts <= 99999999
                                          ? "${repostsToString.substring(0, 2)}M"
                                          : reposts >= 100000000 && reposts <= 999999999
                                          ? "${repostsToString.substring(0, 3)}M"
                                          : "1 B+",
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        SizedBox(width: 5.w,),
                                        Text(
                                          reposts >= 0 && reposts <= 1 ? 're-post' : 're-posts',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().blackColor,
                                            fontSize: 12.sp,
                                            //fontWeight: FontWeight.w500,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),                     
                                //end
                              ]
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
                //SizedBox(height: 20.h,)
              ],
            );
          }
        );
      }
    );
  }
}




