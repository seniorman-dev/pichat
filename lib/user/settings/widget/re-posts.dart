import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';







class RePosts extends StatelessWidget {
  const RePosts({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(), //const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      separatorBuilder: (context, index) => SizedBox(height: 30.h,),  //20.h
      itemCount: 5,
      itemBuilder: (context, index) {
        return InkWell(
          onLongPress: () {},
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
                      //profilePic
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
                                  'Mike Angelo',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme().blackColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                //change
                                CircleAvatar(
                                  backgroundColor: AppTheme().lightGreyColor,
                                  radius: 20.r,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                    ),
                                    color: AppTheme().blackColor,
                                    iconSize: 20.r,
                                    onPressed: () {},
                                  )
                                )
                              ],
                            ),
                            //SizedBox(height: 5.h,),                       
                            Text(
                              '12:00 PM',
                              style: GoogleFonts.poppins(
                                color: AppTheme().darkGreyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: TextStyle(
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
                    'Pffffffffffffffffffffffffffffffgthhhhhhhhhhhhhhhhhhttt5554444h',
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
                    height: 300.h,
                    width: double.infinity,
                    child: Card(
                      color: AppTheme().lightGreyColor,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0.r), //20.r
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
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.heart_fill  //heart,
                        ),
                        iconSize: 30.r,
                        //isSelected: true,
                        color: AppTheme().mainColor,  //.darkGreyColor,
                        onPressed: () {}, 
                      ),
                      /*SizedBox(width: 5.w,),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.chat_bubble,
                        ),
                        iconSize: 30.r,
                        //isSelected: true,
                        color: AppTheme().darkGreyColor,
                        onPressed: () {}, 
                      ),*/
                      SizedBox(width: 5.w,),
                      IconButton(
                        icon: Icon(CupertinoIcons.smallcircle_circle),  //smallcircle_circle_fill
                        iconSize: 30.r,
                        //isSelected: true,
                        color: AppTheme().darkGreyColor,
                          onPressed: () {}, 
                        )
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ////#1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 10.w,),
                            Text(
                              '2000',
                              style: GoogleFonts.poppins(
                                color: AppTheme().greyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            ),
                            SizedBox(width: 5.w,),
                            Text(
                              'likes',
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
                            Text(
                              '2000',
                              style: GoogleFonts.poppins(
                                color: AppTheme().greyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            ),
                            SizedBox(width: 5.w,),
                            Text(
                              're-post',
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
                      ]
                    )
                  ],
                ),
              ),
          ),
          );
        }
      );
  }
}




