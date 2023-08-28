import 'package:Ezio/user/settings/widget/helper_widgets/logout_dialogue_box.dart';
import 'package:Ezio/utils/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/feeds/controller/feeds_controller.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:Ezio/utils/firestore_timestamp_formatter.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:Ezio/utils/toast.dart';
import 'package:provider/provider.dart';








class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.postId, required this.posterName, required this.posterId});
  final String postId;
  final String posterName;
  final String posterId;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> with WidgetsBindingObserver{

  double keyboardHeight = 0;
  double keyboardTop = 0;

  double calculateBottomPadding(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double minPadding = 0;
    double maxPadding = screenHeight * 0.38; // Adjust the value as needed (0.37 is an example)

    return keyboardHeight > MediaQuery.of(context).padding.bottom + 10 ? maxPadding : minPadding;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final topInset = WidgetsBinding.instance.window.viewInsets.top;
    setState(() {
      keyboardHeight = bottomInset;
      keyboardTop = topInset; 
    });
  }

  @override
  Widget build(BuildContext context) {

    var feedsController = Provider.of<FeedsController>(context,);

    //only send messages when there is something to send
    void sendMessage() async{
      if(feedsController.commentTextController.text.isNotEmpty) {
        //send message
        feedsController.commentOnApost(postId: widget.postId, posterName: widget.posterName)
        .then((val) => feedsController.commentTextController.clear());
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            }, 
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme().blackColor,
              size: 30.r,
            )
          ),
          title: const Text(
            'Comments'
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
        //add more styling to this body property later
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,),
        
        
            //Comment on the post stream
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 0.h, //0.h
                  horizontal: 15.w  //10.w
                ),
                //wrap with listview.builder then stream builder later
                child: StreamBuilder(
                  stream: feedsController.postComments(postId: widget.postId),
                  builder: (context, snapshot) {
        
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show a loading indicator while waiting for data
                      return const Loader();
                    } 
                    if (snapshot.hasError) {
                      // Handle error if any
                      return const ErrorLoader();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 20.h,
                          ),
                          child: SizedBox(
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
                                      CupertinoIcons.text_bubble,
                                      color: AppTheme().mainColor,
                                      size: 70.r,
                                    ),
                                  ),
                                  SizedBox(height: 40.h),
                                  Text(
                                    "No comments yet on ${getFirstName(fullName: widget.posterName)}'s post 😔",
                                    style: GoogleFonts.poppins(
                                      color: AppTheme().greyColor,
                                      fontSize: 14.sp,
                                      //fontWeight: FontWeight.w500
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
        
                    return ListView.separated(
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (BuildContext context, int index) => SizedBox(height: 15.h,),
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index];
                        // Check if the current message's date is different from the previous message's date
                        bool showDateHeader = true;
                        if (index > 0) {
                          var previousData = snapshot.data!.docs[index - 1];
                          var currentDate = formatDate(timestamp: data['timestamp']);
                          var previousDate = formatDate(timestamp: previousData['timestamp']);
                          showDateHeader = currentDate != previousDate;
                        }

                        //to keep track if a comment under a post is liked by user or not
                        List<dynamic> likesList = data['likes'];
        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show the date header if needed
                            if (showDateHeader)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 20.h, 
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
                        
                            //the comment list gan gan
                            Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              background: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(CupertinoIcons.delete_simple, color: AppTheme().redColor,)
                                ]
                              ),
                              onDismissed: (direction) {
                                if(widget.posterId == feedsController.userID) {
                                  feedsController.makePosterDeleteCommentsFromPost(postId: widget.postId, commentId: data['commentId']);
                                }
                                else {
                                  customGetXSnackBar(title: 'Uh-Oh', subtitle: 'Only the owner of the post can delete comments here');
                                }
                              },
                              child: InkWell(
                                onLongPress: () {
                                  if(data['commenterId'] == feedsController.userID) {
                                    feedsController.makeCommenterDeleteCommentOnAPost(postId: widget.postId, commentId: data['commentId']);
                                  }
                                  else {
                                    customGetXSnackBar(title: 'Uh-oh', subtitle: 'You are not in position to do that');
                                  }
                                },
                                child: Container(
                                  //height: 100.h,
                                  //width: 200.w,
                                  /*padding: EdgeInsets.symmetric(
                                    vertical: 15.h, //20.h
                                    horizontal: 15.w  //15.w
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme().whiteColor,
                                    borderRadius: BorderRadius.circular(40.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 0.1.r,
                                        blurRadius: 8.0.r,
                                      )
                                    ],
                                  ),*/
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                                            
                                      //profile of the commenter
                                      CircleAvatar(
                                        radius: 38.r,
                                        backgroundColor: AppTheme().opacityBlue,
                                        child: CircleAvatar(
                                          radius: 36.r,
                                          backgroundColor: data['commenterPhoto'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                          //backgroundColor: AppTheme().darkGreyColor,
                                          child: data['commenterPhoto'] == null 
                                          ?null
                                          :ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                            clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                            child: CachedNetworkImage(
                                              imageUrl: data['commenterPhoto'],
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
                                                
                                      //commenter name, timestamp and the comment
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //commenter name and the time of comment
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  data['commenterName'],
                                                  style: GoogleFonts.poppins(
                                                    color: AppTheme().blackColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    textStyle: TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    )
                                                  ),
                                                ),
                                                //SizedBox(width: 10.w,),
                                                Text(
                                                  formatTime(timestamp: data['timestamp']),
                                                  style: GoogleFonts.poppins(
                                                    color: AppTheme().greyColor,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.normal,
                                                    textStyle: TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    )
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1.h,),
                                            //comment
                                            Text(
                                              data['comment'],
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().greyColor,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: TextStyle(
                                                  overflow: TextOverflow.visible //ellipsis
                                                )
                                              ),
                                            ),
                                            SizedBox(height: 1.h,),
                                                
                                            //create a stream for this (implementing soon)
                                            //who liked
                                            StreamBuilder(
                                              stream: feedsController.usersWhoLikedACommentUnderAPostStream(postId: data['postId'], commentId: data['commentId']),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  // Show a loading indicator while waiting for data
                                                  return Text(
                                                    //posts
                                                    '...',
                                                    style: GoogleFonts.poppins(
                                                      color: AppTheme().opacityBlue,
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
                                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty || likesList.isEmpty) {
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
                                                //get the document for the document snapshot
                                                int likes = snapshot.data!.docs.length;
                                                //convert the length to string
                                                String likesToString = likes.toString();
                                                return Text(
                                                  likes >= 0 && likes <=1 ?
                                                  '$likesToString like'
                                                  :likes >= 2 && likes <= 999 
                                                  ? "$likesToString likes"
                                                  :likes >= 1000 && likes <= 9999
                                                  ? "${likesToString[0]}k likes"
                                                  : likes >= 10000 && likes <= 99999 
                                                  ? "${likesToString.substring(0, 2)}k likes"
                                                  : likes >= 100000 && likes >= 999999
                                                  ? "${likesToString.substring(0, 3)}k likes"
                                                  : likes >= 1000000 && likes <= 9999999
                                                  ? "${likesToString[0]}m likes"
                                                  : likes >= 10000000 && likes <= 99999999
                                                  ? "${likesToString.substring(0, 2)}m likes"
                                                  : likes >= 100000000 && likes <= 999999999
                                                  ? "${likesToString.substring(0, 3)}m likes"
                                                  : "1 B+ likes",
                                                  style: GoogleFonts.poppins(
                                                    color: AppTheme().opacityBlue,
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    textStyle: TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    )
                                                  ),
                                                );
                                              }
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10.w,),
                                      InkWell(
                                        onTap: () {
                                          setState(() {                   
                                            if (feedsController.selectedItems.contains(index) || likesList.contains(userID)){
                                              feedsController.isCommentLiked = false;
                                              feedsController.selectedItems.remove(index);
                                              feedsController.unlikeACommentUnderAPost(postId: data['postId'], commentId: data['commentId'],);
                                            } else {
                                              feedsController.isCommentLiked = true;
                                              feedsController.selectedItems.add(index);
                                              feedsController.likeACommentUnderAPost(postId: data['postId'], commentId: data['commentId'],);
                                            } 
                                          });
                                
                                        }, 
                                        child: Icon(
                                          feedsController.selectedItems.contains(index) || likesList.contains(userID) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                          size: 24.r,
                                          color: feedsController.selectedItems.contains(index) || likesList.contains(userID) ? AppTheme().mainColor: AppTheme().darkGreyColor,
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h,)
                          ],
                        );
                      },
                    );
                  }
                ),
              )
            ),
        
        
        
            ////////////////////////
            //textfield to send comment
            Padding(
              padding: EdgeInsets.only(
                bottom: calculateBottomPadding(context)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 0.h, //0.h
                  horizontal: 15.w  //10.w
                ),
                child: TextFormField(
                  //autofocus: true,
                  controller: feedsController.commentTextController,
                  spellCheckConfiguration: SpellCheckConfiguration(),
                  scrollPadding: EdgeInsets.symmetric(
                    horizontal: 10.h,
                    vertical: 5.h
                  ), //20        
                  scrollPhysics: const BouncingScrollPhysics(),
                  scrollController: ScrollController(),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  enabled: true,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 10,
                  autocorrect: true,
                  enableSuggestions: true,
                  enableInteractiveSelection: true,
                  cursorColor: AppTheme().blackColor,
                  cursorRadius: Radius.circular(10.r),
                  style: GoogleFonts.poppins(color: AppTheme().blackColor),
                    decoration: InputDecoration(        
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide.none
                    ),       
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.poppins(color: AppTheme().greyColor, fontSize: 14.sp,),              
                    filled: true,
                    fillColor: AppTheme().lightGreyColor,
                    suffixIcon: InkWell(
                      onTap: () {
                        sendMessage();
                      },
                      child: Icon(
                        Icons.send_rounded,
                        size: 35.r, 
                        color: AppTheme().blackColor,
                      )
                    )
                  ),            
                  onChanged: (value) {},
                ),
              ),
            ),
        
            //give it small height
            SizedBox(height: 5.h,)
          ],
        )
      ),
    );
  }
}