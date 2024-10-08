import 'package:carehub/ClientNotificationPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class BookingScheduleAndPayment extends StatefulWidget{
  var StaffData;
  var StaffID;
  var Skill;
  BookingScheduleAndPayment({required this.StaffData,required this.StaffID,required this.Skill});

  @override
  State<StatefulWidget> createState() => _BookingScheduleAndPayment(StaffData:StaffData, StaffID: StaffID, Skill: Skill);
}

class _BookingScheduleAndPayment extends State<BookingScheduleAndPayment>{
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

  var StaffData;
  var StaffID;
  var Skill;
  _BookingScheduleAndPayment({required this.StaffData,required this.StaffID,required this.Skill});

  TextEditingController hours = TextEditingController();
  var total;

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Booking and Payment"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [

            //Information
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 10, left: 10),
              child: Container(
                width: screenWidth * 0.95,
                height: screenHeight * 0.3,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(image: DecorationImage(
                                  image: NetworkImage(StaffData['Profile_Pic']),
                                  fit: BoxFit.cover, // Adjust the fit if necessary
                                ),
                                  borderRadius: BorderRadius.circular(80),
                                  color: Colors.orange,
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: 120,
                                    child: Text("${StaffData['First_name']} ${StaffData['Last_name']}", overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),)),
                                Text(StaffData["Status"]? "Available": "Busy", style: TextStyle(fontSize: 10, color: Colors.green,)),
                                Text("Current time is ${TimeOfDay.now().hour}:${TimeOfDay.now().minute}", style: TextStyle(fontSize: 10, color: Colors.blue,)),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [BoxShadow(
                                color: Colors.black26,
                                blurRadius: 1,
                                spreadRadius: 1
                              )]
                            ),
                            child: Column(
                              children: [
                                Text(StaffData["professionOfStaff"], style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),),
                                Text(StaffData["City"], style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              height: 30,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius:BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                color: Colors.white,
                                boxShadow: [BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                )]
                              ),
                              child: Center(child: Text("Hour", style: TextStyle(fontWeight: FontWeight.bold),)),
                            ),
                          ),
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              height: 30,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  )]
                              ),
                              child: Center(child: Text("Day", style: TextStyle(fontWeight: FontWeight.bold),)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 10, top: 5),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.4,
                                    child: Text("Hours", style: TextStyle(fontSize: 10,),)
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: screenWidth *0.05),
                                  child: Container(
                                    height: 20,
                                    width: screenWidth *0.15,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 1,
                                        spreadRadius: 1
                                      )]
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 1, left: 1),
                                          child: Icon(CupertinoIcons.minus, size: 15,),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 2, left: 2),
                                          child: Text("1", style:
                                            TextStyle(fontSize: 12),),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 1, left: 1),
                                          child: Icon(CupertinoIcons.plus,size: 15,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(child: Text("100", style: TextStyle(fontSize: 10,),)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.6,
                                    child: Text("Traveling Charges", style: TextStyle(fontSize: 10,),)),
                                Text("30", style: TextStyle(fontSize: 10,),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.6,
                                    child: Text("Platform charges 15%", style: TextStyle(fontSize: 10,),)),
                                Text("15", style: TextStyle(fontSize: 10,),)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Container(
                                    width: screenWidth * 0.2,
                                    child: Text("Total", style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                                Container(
                                    width: screenWidth * 0.4,
                                    child: Text("Know More", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),)),
                                Text("145", style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


            // Schedule
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
              child: Container(
                width: screenWidth * 0.95,
                height: screenHeight * 0.2,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 1,
                        blurRadius: 1
                    )]
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: screenWidth * 0.4,
                              height: 60,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              width: screenWidth * 0.2,
                              height: 60,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Know more", style: TextStyle(fontSize: 11, color: Colors.green),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Container(
                                width: (screenWidth * 0.3) - 2,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                    )]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text("GUERANTEE ON TIME", style: TextStyle(fontSize: 10),),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.9,
                        height: 60,
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.23,
                              height: 30,
                              child: Text("Select Date", style: TextStyle(fontSize: 12, color: Colors.blue),),
                            ),
                            Container(
                              width: screenWidth * 0.23,
                              height: 30,
                              child: Text("Select Time", style: TextStyle(fontSize: 12, color: Colors.blue),),
                            ),
                            Container(
                              width: screenWidth * 0.24,
                              height: 30,
                              child: Text("21/09/2024", style: TextStyle(fontSize: 12),),
                            ),
                            Container(
                              width: (screenWidth * 0.2) - 2,
                              height: 30,
                              child: Text("06:00 AM", style: TextStyle(fontSize: 12),),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.9,
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.46,
                              height: 30,
                              child: Text("Due to", style: TextStyle(fontSize: 12,),),
                            ),
                            Container(
                              width: screenWidth * 0.24,
                              height: 30,
                              child: Text("21/09/2024", style: TextStyle(fontSize: 12),),
                            ),
                            Container(
                              width: (screenWidth * 0.2) - 2,
                              height: 30,
                              child: Text("07:00 AM", style: TextStyle(fontSize: 12),),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            // Payment
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Container(
                width: screenWidth * 0.95,
                height: screenHeight * 0.4,
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
                    Padding(
                      padding: EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          Text("Payment Options", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Divider(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text("Most Preferred", style: TextStyle(fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 1
                          )]
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTo4x8kSTmPUq4PFzl4HNT0gObFuEhivHOFYg&s|"))
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                      width: screenWidth * 0.7,
                                        child: Text("PhonePe UPI")),
                                  ),
                                  Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Colors.blue
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                onTap: ()  {
                                  var UID = FirebaseAuth.instance.currentUser?.uid;
                                  FirebaseFirestore.instance.collection('NotificationForStaff').add({
                                    'userUID': UID,
                                    'staffUID': StaffID,
                                    'professionOfStaff': Skill,
                                    'status': 'Received a Request',
                                    'timeofdeal': "${DateTime.now().day} ${DateFormat.MMM().format(DateTime.now())} ${DateTime.now().year} ${DateFormat.jm().format(DateTime.now())}",
                                    'totalcost': StaffData["Hour_rate"],
                                    'hours': hours.text,
                                  }).then((staffDocRef) {
                                    String staffDocUID = staffDocRef.id;

                                    FirebaseFirestore.instance.collection('NotificationForUser').add({
                                      'userUID': UID,
                                      'staffUID': StaffID,
                                      'status': 'Request sent',
                                      'professionOfStaff': Skill,
                                      'timeofdeal': "${DateTime.now().day} ${DateFormat.MMM().format(DateTime.now())} ${DateTime.now().year} ${DateFormat.jm().format(DateTime.now())}",
                                      'totalcost': StaffData["Hour_rate"],
                                      'hours': hours.text,
                                      'DocUID': staffDocUID,
                                    }).then((userDocRef) {
                                      String userDocUID = userDocRef.id;

                                      FirebaseFirestore.instance.collection('NotificationForStaff').doc(staffDocUID).update({
                                        'DocUID': userDocUID,
                                      });
                                    }).catchError((error) {
                                      print("Error adding document to NotificationForUser: $error");
                                    });

                                  }).catchError((error) {
                                    print("Error adding document to NotificationForStaff: $error");
                                  });

                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClientNotificationPage(),));
                                },
                                child: Container(
                                  height: 40,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 1,
                                      blurRadius: 1
                                    )]
                                  ),
                                  child: Center(child: Text("Pay 145", style: TextStyle(color: Colors.white),)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, top: 10),
                      child: Row(
                        children: [
                          Text("UPI", style: TextStyle(fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 1
                            )]
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage("https://cdn.iconscout.com/icon/free/png-256/free-google-pay-logo-icon-download-in-svg-png-gif-file-formats--gpay-payment-money-pack-logos-icons-1721670.png"))
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                        width: screenWidth * 0.7,
                                        child: Text("GPay UIP")),
                                  ),
                                  Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.green
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage("https://cdn.icon-icons.com/icons2/730/PNG/512/paytm_icon-icons.com_62778.png"))
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                        width: screenWidth * 0.7,
                                        child: Text("Paytm UPI")),
                                  ),
                                  Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.green
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage("https://img.icons8.com/color/200/bhim.png"))
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                        width: screenWidth * 0.7,
                                        child: Text("Pay by any UPI App")),
                                  ),
                                  Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.green
                                    ),
                                  )
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
      ),
    );
  }

}