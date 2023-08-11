import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/feeds/controller/feeds_controller.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';







class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

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
              SizedBox(height: 10.h,),
              ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(height: 30.h,),  //20.h
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index];  //normal list
                  return InkWell(
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
                              //profilePic  //data['posterPhoto']
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
                                            icon: const Icon(
                                              Icons.more_horiz_rounded,
                                            ),
                                            color: AppTheme().blackColor,
                                            iconSize: 20.r,
                                            onPressed: () {
                                              //open alert dialog for more options
                                            },
                                          )
                                        )
                                      ],
                                    ),
                                    //SizedBox(height: 5.h,),                       
                                    Text(
                                      "${formatTime(timestamp: data['timestamp'])} ${formatDate(timestamp: data['timestamp'])}",
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().darkGreyColor,
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
                            height: 300.h,
                            width: double.infinity,
                            child: Card(
                              color: AppTheme().lightGreyColor,
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0.r), //20.r
                              ),
                              elevation: 0,
                              //child: Image.asset('asset/img/vibe.jpg')
                              /*CachedNetworkImage(
                                imageUrl: 'https://images.unsplash.com/photo-1600759844095-82b5e23d4e00?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1021&q=80',
                                fit: BoxFit.fill,
                              ),*/
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              InkWell(
                                onTap: () => controller.likeAPost(postId: data['postId']),
                                onTapCancel: () => controller.unLikeAPost(postId: data['postId']),
                                child: Icon(
                                  //////check for error
                                  data['userLiked'] ? CupertinoIcons.heart_fill : CupertinoIcons.heart, //heart,,
                                  size: 30.r,
                                  color: AppTheme().mainColor,  //.darkGreyColor,
                                ),
                              ),

                              SizedBox(width: 5.w,),
                              IconButton(
                                icon: Icon(
                                  CupertinoIcons.chat_bubble,
                                ),
                                iconSize: 30.r,
                                //isSelected: true,
                                color: AppTheme().darkGreyColor,
                                onPressed: () {
                                  //open a bottom sheet to comment and view peoples comment on the particular post
                                }, 
                              ),
                              SizedBox(width: 5.w,),

                              InkWell(
                                onTap: () {
                                  controller.rePostAPost(
                                    postId: data['postId'], 
                                    posterId: data['posterId'], 
                                    postName: data['posterName'], 
                                    posterPhoto: data['posterPhoto'], 
                                    postTitle: data['postTitle'], 
                                    postContent: data['postContent']
                                  );
                                },
                                onTapCancel: () => controller.deleteRepost(postId: data['postId']),
                                child: Icon(
                                  //check for error
                                  data['isReposted'] ? CupertinoIcons.arrow_counterclockwise_circle_fill : CupertinoIcons.arrow_counterclockwise_circle,
                                  size: 30.r,
                                  color: AppTheme().mainColor,  //.darkGreyColor,
                                ),
                              ),
    
                            ],
                          ),
                          SizedBox(height: 5.h,),
    
                          //wrap with padding
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ////#1
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //SizedBox(width: 10.w,),
                                    StreamBuilder(
                                      stream: controller.postLikes(postId: data['postId']),
                                      builder: (context, snapshot) {
                                        //get the document for the document snapshot
                                        int likes = snapshot.data!.docs.length;
                                        //convert the length to string
                                        String likesToString = likes.toString();
                                        return Text(
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
                                        );
                                      }
                                    ),
                                    SizedBox(width: 5.w,),
                                    Text(
                                      'likes',
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
                                ),
                                //#2
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 10.w,),
                                    StreamBuilder(
                                      stream: controller.postComments(postId: data['postId']),
                                      builder: (context, snapshot) {
                                        //get the document for the document snapshot
                                        int comments = snapshot.data!.docs.length;
                                        //convert the length to string
                                        String commentsToString = comments.toString();
                                        return Text(
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
                                        );
                                      }
                                    ),
                                    SizedBox(width: 5.w,),
                                    Text(
                                      'comments',
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
                                ),
                                //#3
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 10.w,),
                                    StreamBuilder(
                                      stream: controller.repostStream(postId: data['postId']),
                                      builder: (context, snapshot) {
                                        //get the document for the document snapshot
                                        int reposts = snapshot.data!.docs.length;
                                        String repostsToString = reposts.toString();
                                        return Text(
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
                                        );
                                      }
                                    ),
                                    SizedBox(width: 5.w,),
                                    Text(
                                      're-post',
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
                                ),
                              ]
                            ),
                          )
                        ],
                      ),
                    ),
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