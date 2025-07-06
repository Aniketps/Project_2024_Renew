import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'globle.dart';

class TC extends StatefulWidget {
  const TC({super.key});

  @override
  State<StatefulWidget> createState() => _TC();
}

class _TC extends State<TC> {
  late List<DocumentSnapshot> documents = [];
  List<bool> _expandedList = [];

  @override
  void initState() {
    super.initState();
    searchTermsAndConditions();
    void liveLocation() {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          setState(() async {
            String lat = position.latitude.toString();
            String long = position.longitude.toString();
            User? user = FirebaseAuth.instance.currentUser;

            await FirebaseFirestore.instance
                .collection('user')
                .doc(user?.uid)
                .update({
              'lat': lat,
              'long': long,
            });
          });
        },
      );
    }

    liveLocation();
  }

  Future<void> searchTermsAndConditions() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Terms and Conditions")
        .get();
    setState(() {
      documents = querySnapshot.docs;
      _expandedList = List<bool>.filled(documents.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Globle.theme,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Center(
                    child: Text("Terms & Conditions",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
                  ),
                  backgroundColor: Globle.theme,
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: screenHeight,
                          width: screenWidth,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 1,
                                    spreadRadius: 1)
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Discaimer",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    right: 15, left: 15),
                                child: Divider(),
                              ),
                              SizedBox(
                                height: screenHeight * 0.78,
                                width: screenWidth * 0.9,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: documents.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: screenWidth * 0.85,
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                spreadRadius: 1,
                                                blurRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(documents[index]['Term'],
                                                    style: const TextStyle(
                                                        fontSize: 16)),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _expandedList[index] =
                                                          !_expandedList[
                                                              index];
                                                    });
                                                  },
                                                  child: const Icon(
                                                      CupertinoIcons.plus),
                                                ),
                                              ],
                                            ),
                                            if (_expandedList[index])
                                              Column(
                                                children: [
                                                  const Divider(),
                                                  Text(
                                                      documents[index]
                                                          ['Condition'],
                                                      style: const TextStyle(
                                                          fontSize: 14)),
                                                ],
                                              )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
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
