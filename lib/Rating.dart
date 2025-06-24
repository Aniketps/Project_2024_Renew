import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'globle.dart';

class RatingState extends StatefulWidget {
  final String UID;
  const RatingState({super.key, required this.UID});

  @override
  State<RatingState> createState() => _RatingStateState(UID: UID);
}

class _RatingStateState extends State<RatingState> {
  final String UID;
  _RatingStateState({required this.UID});

  @override
  void initState() {
    super.initState();
    getCounts();
  }

  var FirstStarCount = 0;
  var SecondStarCount = 0;
  var ThirdStarCount = 0;
  var FourthStarCount = 0;
  var FifthStarCount = 0;

  double FirstStar = 0.0;
  double SecondStar = 0.0;
  double ThirdStar = 0.0;
  double FourthStar = 0.0;
  double FifthStar = 0.0;

  bool loader = true;

  void getCounts() async {
    getStaffRating();
    try {
      var docSnapshot =
          await FirebaseFirestore.instance.collection("Ratings").doc(UID).get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

        FirstStarCount = data['1Star'] ?? 0;
        SecondStarCount = data['2Star'] ?? 0;
        ThirdStarCount = data['3Star'] ?? 0;
        FourthStarCount = data['4Star'] ?? 0;
        FifthStarCount = data['5Star'] ?? 0;

        var totalCount = FirstStarCount +
            SecondStarCount +
            ThirdStarCount +
            FourthStarCount +
            FifthStarCount;

        // Prevent division by zero
        if (totalCount > 0) {
          FirstStar = (FirstStarCount) / totalCount;
          SecondStar = (SecondStarCount) / totalCount;
          ThirdStar = (ThirdStarCount) / totalCount;
          FourthStar = (FourthStarCount) / totalCount;
          FifthStar = (FifthStarCount) / totalCount;
        } else {
          FirstStar = 0.0;
          SecondStar = 0.0;
          ThirdStar = 0.0;
          FourthStar = 0.0;
          FifthStar = 0.0;
        }
      }

      setState(() {
        loader = false;
      });
    } catch (e) {
      print("Error fetching ratings: $e");
      setState(() {
        loader = false;
      });
    }
  }

  String StaffRating = '';

  Future<void> getStaffRating() async {
    try {
      var userDoc =
          await FirebaseFirestore.instance.collection("user").doc(UID).get();

      if (!userDoc.exists) {
        print("User document not found");
        return;
      }

      var staffData = userDoc.data();
      if (staffData == null || !staffData.containsKey("professionOfStaff")) {
        print("professionOfStaff field is missing");
        return;
      }

      var staffDoc = await FirebaseFirestore.instance
          .collection(staffData["professionOfStaff"].toString())
          .doc(UID)
          .get();

      if (!staffDoc.exists) {
        print("Staff document not found");
        return;
      }

      var staffDetails = staffDoc.data();
      if (staffDetails == null || !staffDetails.containsKey("Rating")) {
        print("Rating field is missing");
        return;
      }

      setState(() {
        StaffRating = staffDetails["Rating"].toString();
      });
    } catch (e) {
      print("Error fetching staff rating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //    backgroundColor: Colors.blue,
      //    title: Text(
      //   "Rating Details",
      //    style: TextStyle(color: Colors.black),
      //  ),
      //  ),
      body: Align(
        alignment: Alignment.topCenter,
        child: loader
            ? Container()
            : Column(
                children: [
                  Container(
                    height: 150,
                    color: Globle.theme,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppBar(
                          title: Center(
                            child: Text(
                              "Rating details",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          backgroundColor: Globle.theme,
                          automaticallyImplyLeading: false,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 310,
                    width: 370,
                    margin: EdgeInsets.all(9),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 1,
                          )
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Rating',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0, left: 10),
                          child: Divider(color: Colors.lightBlueAccent),
                        ),
                        Center(
                          child: Text(
                            'Average Rating',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                                width: 15, // Set the desired width
                                height: 15, // Set the desired height
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                  width: 8), // Space between image and text
                              Text(
                                '${StaffRating}/5.0',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                                width: 15, // Set the desired width
                                height: 15, // Set the desired height
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '5', // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 5,
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start, // Center the row
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: MediaQuery.sizeOf(context).width *
                                          FifthStar,
                                      color: Colors.green,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                FifthStarCount
                                    .toString(), // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                                width: 15, // Set the desired width
                                height: 15, // Set the desired height
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '4', // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 5,
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start, // Center the row
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: MediaQuery.sizeOf(context).width *
                                          FourthStar,
                                      color: Colors.green,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                FourthStarCount
                                    .toString(), // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                                width: 15, // Set the desired width
                                height: 15, // Set the desired height
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '3', // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 5,
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start, // Center the row
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: MediaQuery.sizeOf(context).width *
                                          ThirdStar,
                                      color: Colors.green,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                ThirdStarCount
                                    .toString(), // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                                width: 15, // Set the desired width
                                height: 15, // Set the desired height
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '2', // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 5,
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start, // Center the row
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: MediaQuery.sizeOf(context).width *
                                          SecondStar,
                                      color: Colors.green,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                SecondStarCount
                                    .toString(), // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                                width: 15, // Set the desired width
                                height: 15, // Set the desired height
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '1', // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 5,
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start, // Center the row
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: MediaQuery.sizeOf(context).width *
                                          FirstStar,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                FirstStarCount
                                    .toString(), // Replace with your rating value
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
