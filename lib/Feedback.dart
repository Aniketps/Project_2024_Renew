import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Feedbacks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Feedbacks();
}

class _Feedbacks extends State<Feedbacks> {
  @override
  void initState() {
    super.initState();
    _liveLocation();
  }

  void _liveLocation() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
        String lat = position.latitude.toString();
        String long = position.longitude.toString();
        User? user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('user').doc(user?.uid).update({
          'lat': lat,
          'long': long,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedbacks"),
        backgroundColor: Colors.blue,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              height: 280,
              width: 470,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Feedbacks',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  FeedbackItem(
                    imageUrl: 'https://www.iconsdb.com/icons/preview/green/circle-xxl.png',
                    title: 'Argument',
                    time: '12 sep 2024 05:15 PM',
                  ),
                  SizedBox(height: 10),
                  FeedbackItem(
                    imageUrl: 'https://thumbs.dreamstime.com/b/check-mark-icon-checked-right-click-icon-vector-check-mark-icon-checked-right-click-icon-vector-164317123.jpg',
                    title: 'Suggestion',
                    time: '05 sep 2024 09:15 PM',
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlankPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                "New",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            SizedBox(height: 260),
            Container(
              width: double.infinity,
              child: AppBar(
                backgroundColor: Colors.lightGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String time;

  const FeedbackItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image.network(
            imageUrl,
            width: 20,
            height: 20,
          ),
          SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 20),
          Text(
            time,
            style: TextStyle(color: Colors.black, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Feedbacks'),
        backgroundColor: Colors.blue,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              height: 570,
              width: 400,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: Colors.redAccent),
                  Container(
                    height: 440,
                    width: 350,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          print('Clear Button Pressed');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Clear All ",
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print('Post Button Pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "Post",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),





                    ],
                  ),


                ],


              ),


            ),


          SizedBox(height: 45,),
            Container(
              width: double.infinity,
              child: AppBar(
                backgroundColor: Colors.lightGreen,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
