// ignore_for_file: unnecessary_import, prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.BgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColor.BgColor,
        leading: InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              WebAPPNavigation.navigateTo(context: context);
            },
            child: CommonWidget().backicon()),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width * 0.38,
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "4.6",
                                style: TextStyle(
                                    fontSize: 42, fontWeight: FontWeight.w600),
                              ),
                              RatingBar.builder(
                                initialRating: 3,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                unratedColor: Colors.grey.withValues(alpha: 0.2),
                                itemCount: 5,
                                glow: false,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 3),
                                itemSize: 25,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star_purple500_sharp,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              Text(
                                "367 Reviews",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: AppColor.fontColorgrey,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Commanreview(percent: 0.9, title: "5 Start"),
                            Commanreview(percent: 0.7, title: "4 Start"),
                            Commanreview(percent: 0.5, title: "3 Start"),
                            Commanreview(percent: 0.3, title: "2 Start"),
                            Commanreview(percent: 0.1, title: "1 Start"),
                          ],
                        ),
                      ],
                    ),
                    WriteReviewBtn(),
                    reviewtext(),
                    reviewtext()
                  ],
                ),
              ),
            ),
            Container(
              height: 55,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.transparent),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          suffixIcon: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.BlackColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Image(
                                  image: AssetImage(
                                      AppImage.appIcon + "Comment.png")),
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: "Add a Comment",
                          hintStyle: TextStyle(
                              color: AppColor.fontColorgrey,
                              fontFamily: AppFont.lato)),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Commanreview({title, double? percent}) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width * 0.50,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              style: TextStyle(),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: LinearPercentIndicator(
              barRadius: Radius.circular(5),
              lineHeight: 12.0,
              percent: percent!,
              progressColor: AppColor.processbarcolor,
            ),
          ),
          Text(
            "${(percent * 100).round()}%",
            style: TextStyle(
                color: AppColor.fontColorgrey, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  WriteReviewBtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        margin: EdgeInsets.only(right: 24, left: 24, top: 14, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.btnColorblack),
        child: Text(
          "Write a Review",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  reviewtext() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage(AppImage.appIcon + "userimage.png"),
                        fit: BoxFit.cover)),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Angelina Anderson"),
                      RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        unratedColor: Colors.grey.withValues(alpha: 0.2),
                        itemCount: 5,
                        glow: false,
                        itemPadding: EdgeInsets.only(right: 3),
                        itemSize: 15,
                        itemBuilder: (context, _) => Icon(
                          Icons.star_purple500_sharp,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  "16 Minute ago",
                  style: TextStyle(
                      color: AppColor.fontColorgrey, fontFamily: AppFont.lato),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 47.0, bottom: 10),
            child: Text(
              "Nice Studio, The App Where You Can Buy Your Furniture With Just A Top Without Any Hassle_ Products Are Realy Awesome.....",
              style: TextStyle(
                  color: AppColor.fontColorgrey, fontFamily: AppFont.lato),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 47.0, bottom: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Read More",
                style: TextStyle(
                    color: AppColor.processbarcolor, fontFamily: AppFont.lato),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
