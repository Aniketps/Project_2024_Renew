import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TC extends StatefulWidget {
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
    void _liveLocation() {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
          setState(() async {
            String lat = position.latitude.toString();
            String long = position.longitude.toString();
            User? user = FirebaseAuth.instance.currentUser;

            await FirebaseFirestore.instance.collection('user').doc(user?.uid).update({
              'lat' : lat,
              'long' : long,
            });
          });
        },
      );
    };
    _liveLocation();
  }

  Future<void> searchTermsAndConditions() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Terms and Conditions").get();
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
      appBar: AppBar(
        title: Text("Terms & Conditions"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 1,
                    spreadRadius: 1
                )
              ],
              borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Discaimer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Divider(),
              ),
              Container(
                height: screenHeight * 0.78,
                width: screenWidth * 0.9,
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: screenWidth * 0.85,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 1
                            )
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(documents[index]['Term'], style: TextStyle(fontSize: 16)),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedList[index] = !_expandedList[index];
                                    });
                                  },
                                  child: Icon(CupertinoIcons.plus),
                                ),
                              ],
                            ),
                            if (_expandedList[index])
                              Column(
                                children: [
                                  Divider(),
                                  Text(documents[index]['Condition'], style: TextStyle(fontSize: 14)),
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
      ),
    );
  }
}
