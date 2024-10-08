import 'package:carehub/BookingScheduleAndPayment.dart';
import 'package:carehub/ClientNotificationPage.dart';
import 'package:carehub/EContact.dart';
import 'package:carehub/EPersonal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ContactUs.dart';
import 'Deals.dart';
import 'Feedback.dart';
import 'LoginPage.dart';
import 'StaffNotificationPage.dart';
import 'TC.dart';

class StaffProfileHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StaffProfileHome();
}

class _StaffProfileHome extends State<StaffProfileHome>{

  @override
  void initState() {
    super.initState();
    SearchStaff();
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

  var StaffData;
  var StaffData1;
  late String currentUserID;

  Future<void> SearchStaff() async {
    User? user1 = await FirebaseAuth.instance.currentUser;
    currentUserID = user1?.uid ?? '';
    DocumentSnapshot documentSnapshot1 = await FirebaseFirestore.instance.collection("user").doc(currentUserID).get();
    StaffData1 = documentSnapshot1.data() as Map<String, dynamic>?;

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("${StaffData1["professionOfStaff"]}").doc(currentUserID).get();
    if (documentSnapshot.exists) {
      setState(() {
        StaffData = documentSnapshot.data() as Map<String, dynamic>?;
        if(StaffData['professionOfStaff']==null){
          print(StaffData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    if (StaffData  == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()), // Loading indicator
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.blue,
        ),
        drawer: Drawer(
          width: screenWidth * 0.7,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(color: Colors.red),
                  child: Column(
                      children: [
                        (StaffData != null && StaffData['Profile_Pic'] != null)
                            ? Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 1,
                                color: Colors.black26,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(StaffData['Profile_Pic']),
                              fit: BoxFit.cover, // Adjust the fit if necessary
                            ),
                          ),
                        )
                            : Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 1,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        (StaffData == null)?Text(
                          "Empty",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ):Text(
                          "${StaffData['First_name']} ${StaffData['Last_name']}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ]
                  )
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StaffProfileHome(),));
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Deals'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Deals(),));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.headset_mic),
                title: Text('Contact Us'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUs(),));
                },
              ),
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text('Terms and Conditions'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TC(),));
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Feedback'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Feedbacks(),));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
        ),
        body: StaffView(StaffData: StaffData, UID: currentUserID,)
    );
  }
}

class StaffView extends StatefulWidget{
  final StaffData;
  final UID;
  StaffView({required this.StaffData, required this.UID});
  @override
  State<StatefulWidget> createState() => _StaffView(StaffData: StaffData, UID: UID);
}

class _StaffView extends State<StaffView>{
  final StaffData;
  final UID;
  _StaffView({required this.StaffData, required this.UID});
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 1
                  )]
              ),
              child: Column(
                children: [

                  // Profile Actual details
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: screenHeight * 0.22,
                      width: screenWidth * 0.95,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      color: Colors.green,
                                      image: DecorationImage(
                                        image: NetworkImage(StaffData['Profile_Pic']),
                                        fit: BoxFit.cover, // Adjust the fit if necessary
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("${StaffData['First_name']} ${StaffData['Last_name']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: InkWell(onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EPersonal(Skill: StaffData['professionOfStaff']),));
                                          },child: Text("Edit", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),)),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(StaffData["Status"]? "Available" : "Busy", style: TextStyle(color: Colors.blue, fontSize: 12)),
                                        Text(" | ", style: TextStyle( fontSize: 16),),
                                        Text(StaffData["City"], style: TextStyle(color: Colors.green, fontSize: 12)),
                                      ],
                                    ),
                                    Container(
                                      height: 45,
                                      margin: EdgeInsets.only(top: 10),
                                      width: screenHeight * 0.27,
                                      decoration: BoxDecoration(
                                        color: Color(0xff00008B),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star, color: Color(0xffFFD700),),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10, left: 5),
                                            child: Text("${StaffData["Rating"]}/5.0", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          ),
                                          Text("Check",style: TextStyle(fontSize: 12, color: Colors.white),),
                                          Icon(Icons.play_arrow, color: Colors.white,)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 45,
                                width: 110,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 1
                                    )],
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Center(child: Text(StaffData['professionOfStaff'][0].toUpperCase()+StaffData['professionOfStaff'].substring(1),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Color(0xff089000),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),)),
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        try {
                                          await FirebaseFirestore.instance.collection(StaffData['professionOfStaff']).doc(UID).update({
                                            "Status": true,
                                          });
                                          print("Status updated successfully");
                                        } catch (e) {
                                          print("Error updating status: $e");
                                        }
                                      },
                                      child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            ),
                                            color: Colors.red,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15,right: 5),
                                            child: Center(child: Text("Available", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),)),
                                          ))
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection(StaffData["professionOfStaff"])
                                              .doc(UID)
                                              .update({
                                            "Status": false,
                                          });
                                          print("Status updated successfully");
                                        } catch (e) {
                                          print("Error updating status: $e");
                                        }
                                      },
                                      child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            color: Colors.red,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 15, left: 5),
                                            child: Center(child: Text("Busy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),)),
                                          ))
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffNotificationPage(),));
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Icon(Icons.notifications),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Professional Details
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: screenHeight * 0.5,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 1
                          )]
                      ),
                      child: Column(
                        children: [
                          Text("Data"),
                          Row(),
                          Row(),
                        ],
                      ),
                    ),
                  ),

                  // Contact information
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: screenHeight * 0.18,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 1
                          )]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 5),
                            child: Row(
                              children: [
                                Text("Contact Information", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: InkWell(onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EContact(Skill: StaffData['professionOfStaff']),));
                                  },child: Text("Edit", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),)),
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () async {
                                    var phoneNumber = StaffData['Phone_Number1'];
                                    final Uri phoneUri = Uri(
                                      scheme: 'tel',
                                      path: phoneNumber,
                                    );
                                    if(await canLaunchUrl(phoneUri)){
                                      await launchUrl(phoneUri);
                                    }else{
                                      throw "Could not lounch phone dialer";
                                    }
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(
                                            color: Colors.blueAccent,
                                            blurRadius: 1,
                                            spreadRadius: 1
                                        )]
                                    ),
                                    child: Icon(Icons.call, color: Colors.blue,),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () async {
                                    var phonenumber01 = StaffData["Phone_Number2"];
                                    final Uri phoneUri01 = Uri(
                                      scheme: 'tel',
                                      path: phonenumber01,
                                    );
                                    if(phonenumber01!=null) {
                                      if(await canLaunchUrl(phoneUri01)){
                                        launchUrl(phoneUri01);
                                      }else{
                                        Fluttertoast.showToast(
                                          msg: "Empty",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      }
                                    }else{
                                      Fluttertoast.showToast(
                                        msg: "Empty",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(
                                            color: Colors.greenAccent,
                                            blurRadius: 1,
                                            spreadRadius: 1
                                        )]
                                    ),
                                    child: Icon(Icons.call, color: Colors.green,),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () async {
                                    String subject = "Hiring for work from CareHub";
                                    var Gmaildata = StaffData["Email"];
                                    final Uri emailUri = Uri(
                                      scheme: 'mailto',
                                      path: Gmaildata,
                                      queryParameters: {
                                        'subject': subject,
                                      },
                                    );
                                    if(await canLaunchUrl(emailUri)){
                                      launchUrl(emailUri);
                                    }else{
                                      Fluttertoast.showToast(
                                        msg: "Empty",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(
                                            color: Colors.redAccent,
                                            blurRadius: 1,
                                            spreadRadius: 1
                                        )]
                                    ),
                                    child: Icon(Icons.mail, color: Colors.red,),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(
                                          color: Colors.yellowAccent,
                                          blurRadius: 1,
                                          spreadRadius: 1
                                      )]
                                  ),
                                  child: Icon(Icons.message, color: Colors.yellow,),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // Service Rate
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: screenHeight * 0.18,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 1
                          )]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 5),
                            child: Text("Service Rate", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(right: 40, left: 40),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.5,
                                    child: Text("Hour based")),
                                Text("100"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40, left: 40),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.5,
                                    child: Text("Day based")),
                                Text("700"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40, left: 40),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.5,
                                    child: Text("Day service shift 8", style: TextStyle(fontSize: 12, color: Colors.blue),)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}