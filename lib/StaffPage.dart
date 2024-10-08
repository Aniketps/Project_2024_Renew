import 'package:carehub/LoginPage.dart';
import 'package:carehub/StaffProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class StaffPage extends StatefulWidget{
  String Skill;
  StaffPage({required this.Skill});
  @override
  State<StatefulWidget> createState() => _StaffPage(Skill: Skill);
}

class _StaffPage extends State<StaffPage>{

  @override
  void initState() {
    super.initState();
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

  String Skill;

  _StaffPage({required this.Skill});
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;


    return Scaffold(
      appBar: AppBar(
        title: Text("Staff"),
        backgroundColor: Colors.red,
        actions: [
          Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(
                blurRadius: 1,
                color: Colors.black26,
                spreadRadius: 1
              )]
            ),
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
              }, child: Text("End"),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(Skill).snapshots(),
            builder: (context, snapshot) {
              List<Row> chefViews = [];
              if(snapshot.hasData){
                final chefs = snapshot.data?.docs.reversed.toList();
                for(var chef in chefs!){
                  final chefView = Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfilePage(StaffID: chef.id, Skill: Skill),));
                          },
                          child: Container(
                            height: screenHeight * 0.2,
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 1,
                                    spreadRadius: 1
                                )]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        height: 75,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: Colors.orange,
                                          image: DecorationImage(
                                            image: NetworkImage(chef['Profile_Pic']),
                                            fit: BoxFit.cover, // Adjust the fit if necessary
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, right: 5, bottom: 40),
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${chef['First_name']} ${chef['Last_name']}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(chef["Status"]? "Available": "Busy", style: TextStyle(color: Colors.green)),
                                                Text(" | "),
                                                Text("${chef['Rating']}", style: TextStyle(color: Colors.green))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: screenWidth * 0.3,
                                      height: screenHeight * 0.2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Text(chef['City'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                          ),
                                          Container(
                                            height: 40,
                                            width: 120,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: Colors.white,
                                                boxShadow: [BoxShadow(
                                                    color: Colors.black26,
                                                    spreadRadius: 1,
                                                    blurRadius: 1
                                                )]
                                            ),
                                            child: Center(child: Text(Skill, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green, fontSize: 15),)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                  chefViews.add(chefView);
                }
              }
              return ListView(
                children: chefViews,
              );
            },
          )
        ],
      )
    );
  }
}