import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/feeds/controller/feeds_controller.dart';
import 'package:pichat/user/feeds/widget/comment_screen.dart';
import 'package:pichat/user/settings/widget/video_player_widget.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';








class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  bool showDateHeader = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Feeds'
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
          child: buildBody(context),
        )
      ),
    );
  }

  Widget buildBody(BuildContext context) {

    var controller = Provider.of<FeedsController>(context);

    return StreamBuilder(
      stream: controller.getFeeds(),
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
                      CupertinoIcons.chart_pie,
                      color: AppTheme().mainColor,
                      size: 70.r,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "No feeds found",
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

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 25.w,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //SizedBox(height: 10.h,),
              ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(height: 30.h,),  //20.h
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
                      InkWell(
                        onLongPress: () {},
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
                                          width: 40.w,
                                          height: 40.h,
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
                                              child: Center(
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.more_horiz_rounded,
                                                  ),
                                                  color: AppTheme().blackColor,
                                                  iconSize: 20.r,
                                                  onPressed: () {
                                                    //open dialogue for more options
                                                  },
                                                ),
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
                                  textStyle: TextStyle(
                                    overflow: TextOverflow.visible
                                  )
                                ),
                               ),
                              SizedBox(height: 10.h,),
                              /*remove the sizedBox below later*/  //data['postContent']//
                              SizedBox(
                                height: 400.h,
                                width: MediaQuery.of(context).size.width, //double.infinity,  //double.infinity,
                                child: Card(
                                  color: AppTheme().lightGreyColor,
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0.r), //20.r
                                  ),
                                  elevation: 0,
                                  child: data['isImage'] ? 
                                  CachedNetworkImage(
                                    imageUrl: data['postContent'],
                                    //width: 50.w,
                                    //height: 50.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Loader(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: AppTheme().lightestOpacityBlue,
                                    ),
                                  ) : VideoPlayerWidget(videoUrl: data['postContent'],),
                                ),
                              ),
                              
                              SizedBox(height: 5.h,),

                              //to show if the current post is reposted
                              /*controller.isReposted                  
                              ?Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "reposted",   //the field 'reposters' is a list that is why it is done this way if elements are to be accessed
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: AppTheme().opacityBlue,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ),
                              ): SizedBox(),*/
                              SizedBox(height: 5,),

                              //start your icons here with a row (likes, comments and repost icons are here)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //like button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (controller.selectedIndicesForLikes.contains(index)){
                                            controller.unLikeAPost(postId: data['postId']);
                                            controller.selectedIndicesForLikes.remove(index);
                                            controller.isLiked = false;
                                          } else {
                                            controller.likeAPost(postId: data['postId']);
                                            controller.selectedIndicesForLikes.add(index);
                                            controller.isLiked = true;
                                          }
                                        });
                                      },
                                      child: Icon(
                                        controller.selectedIndicesForLikes.contains(index) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                        color: controller.selectedIndicesForLikes.contains(index) ? AppTheme().mainColor: AppTheme().darkGreyColor,
                                        size: 30.r,
                                      ),
                                    ),

                                    SizedBox(width: 20.w,),

                                    //comment button
                                    InkWell(
                                      onTap: () {
                                        //open bottom sheet that enables commenting features like textfield and the likes
                                        Get.to(() => CommentsScreen(postId: data['postId'], posterName: data['posterName'], posterId: data['posterId'],));
                                      },
                                      child: Icon(
                                        CupertinoIcons.chat_bubble,
                                        color: AppTheme().darkGreyColor,
                                        size: 30.r,
                                      ),
                                    ),

                                    SizedBox(width: 20.w,),
                                    
                                    //to check if the feed shown was "reposted".
                                    //data['reposters'] == null ? SizedBox() :
                                    //repost button
                                    InkWell(
                                      onTap: () {

                                        setState(() {
                                        if (controller.selectedIndicesForReposts.contains(index)){
                                          controller.deleteRepost(postId: data['postId']);
                                          controller.selectedIndicesForReposts.remove(index);
                                          controller.isReposted = false;
                                        } else {
                                          controller.rePostAPost(
                                            postId: data['postId'], 
                                            postContent: data['postContent'], 
                                            posterName: data['posterName'], 
                                            postTitle: data['postTitle'], 
                                            posterId:  data['posterId'], 
                                            posterPhoto: data['posterPhoto'], 
                                            isImage: data['isImage']
                                          );  
                                          controller.selectedIndicesForReposts.add(index);
                                          controller.isReposted = true;
                                          }
                                        });

                                        setState(() {
                                          controller.isReposted = true;
                                        });

                                        controller.rePostAPost(
                                          postId: data['postId'], 
                                          postContent: data['postContent'], 
                                          posterName: data['posterName'], 
                                          postTitle: data['postTitle'], 
                                          posterId:  data['posterId'], 
                                          posterPhoto: data['posterPhoto'], 
                                          isImage: data['isImage']
                                        );
                                      },
                                      child: Icon(
                                        controller.selectedIndicesForReposts.contains(index) ? CupertinoIcons.arrow_2_circlepath_circle_fill : CupertinoIcons.arrow_2_circlepath,
                                        color: controller.selectedIndicesForReposts.contains(index) ? AppTheme().mainColor: AppTheme().darkGreyColor,
                                        size: 30.r,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              //SizedBox(height: 5.h,),
    
                              //wrap with padding (likes, comment and re-post values are here)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ////#1                                                              
                                    StreamBuilder(
                                      stream: controller.postLikes(postId: data['postId']),
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
                                              likes >= 0 && likes <= 1 ? 'like': 'likes', 
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
                                      stream: controller.postComments(postId: data['postId']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          // Show a loading indicator while waiting for data
                                          return Text(
                                            //posts
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
                                            //posts
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
                                              comments >= 0 && comments <= 1 ?'comment' : 'comments',
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
                                      stream: controller.repostStream(postId: data['postId']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          // Show a loading indicator while waiting for data
                                          return Text(
                                            //posts
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
                                            //posts
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
                      SizedBox(height: 20.h)
                    ],
                  );
                }
              ),
            ]
          )
        );
      }
    );
  }
}