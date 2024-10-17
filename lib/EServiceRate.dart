import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'StaffProfilePage.dart';

class EServiceRate extends StatefulWidget {
  var Skill;
  EServiceRate({required this.Skill});

  @override
  State<EServiceRate> createState() => _EServiceRateState(Skill: Skill);
}

class _EServiceRateState extends State<EServiceRate> {
  TextEditingController HourRate = TextEditingController();
  TextEditingController DayRate = TextEditingController();
  TextEditingController DayShift = TextEditingController();
  TextEditingController TravelingCharges = TextEditingController();

  var Skill;
  _EServiceRateState({required this.Skill});

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenHeight = mediaquery.size.height;
    final screenWidth = mediaquery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: Center(
                    child: Text("Professional",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  backgroundColor: Colors.red,
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: screenHeight * 0.9,
                              width: screenWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 10, bottom: 5),
                                      child: Text(
                                        "Make Changes",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: HourRate,
                                          decoration: InputDecoration(
                                            labelText: "Hour Rate in ₹",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: DayRate,
                                          decoration: InputDecoration(
                                            labelText: "Day service rate in ₹",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: DayShift,
                                          decoration: InputDecoration(
                                            labelText: "Hours in a day shift",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: TravelingCharges,
                                          decoration: InputDecoration(
                                            labelText: "Traveling Charges in ₹",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 25, top: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Check if fields are not empty and are valid numbers
                                              if (HourRate.text.isNotEmpty &&
                                                  DayRate.text.isNotEmpty &&
                                                  DayShift.text.isNotEmpty &&
                                                  TravelingCharges
                                                      .text.isNotEmpty) {
                                                try {
                                                  User? user = FirebaseAuth
                                                      .instance.currentUser;
                                                  if (user != null) {
                                                    String currentUID =
                                                        user.uid;
                                                    int hourRate = int.parse(
                                                        HourRate.text);
                                                    int dayRate =
                                                        int.parse(DayRate.text);
                                                    int dayShift = int.parse(
                                                        DayShift.text);
                                                    int travelingCharges =
                                                        int.parse(
                                                            TravelingCharges
                                                                .text);

                                                    // Update Firebase Firestore
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(Skill)
                                                        .doc(currentUID)
                                                        .update({
                                                      "Hour_Rate": hourRate,
                                                      "Day_Rate": dayRate,
                                                      "Day_Shift": dayShift,
                                                      "Traveling_Charges":
                                                          travelingCharges,
                                                    });

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('user')
                                                        .doc(currentUID)
                                                        .update({
                                                      "Hour_Rate": hourRate,
                                                      "Day_Rate": dayRate,
                                                      "Day_Shift": dayShift,
                                                      "Traveling_Charges":
                                                          travelingCharges,
                                                    });

                                                    // Navigate to Staff Profile Page
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StaffProfilePage(
                                                          StaffID: currentUID,
                                                          Skill: Skill,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg: "No user logged in",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                    );
                                                  }
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg: "$e",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                  );
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "Please fill all fields with valid numbers",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
