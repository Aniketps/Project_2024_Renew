import 'package:carehub/services/convertToTranslate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<StatefulWidget> createState() => _ContactUs();
}

class _ContactUs extends State<ContactUs> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _fullNameController =
      TextEditingController(); // Controller for Full Name
  final TextEditingController _emailController =
      TextEditingController(); // Controller for Email

  @override
  void initState() {
    super.initState();
    _liveLocation();
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
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
      },
    );
  }

  bool isLoading = false;

  Future<void> _sendMessage() async {
    // Handle message sending logic here
    String fullName = _fullNameController.text;
    String email = _emailController.text;
    String description = _descriptionController.text;
    String details = _detailsController.text;
    String dateAndTime =
        DateFormat("dd/MM/yyyy, hh:mm a").format(DateTime.now());

    if (fullName.isNotEmpty &&
        email.isNotEmpty &&
        details.isNotEmpty &&
        description.isNotEmpty) {
      await FirebaseFirestore.instance.collection("HelpCenter").add({
        "Email": email,
        "Name": fullName,
        "Query": details,
        "Title": description,
        "Status": false,
        "DateTime": dateAndTime,
      });

      // Clear the fields after sending
      _fullNameController.clear();
      _emailController.clear();
      _descriptionController.clear();
      _detailsController.clear();
    } else {
      Fluttertoast.showToast(msg: "Please fill details".trKey);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  title: Center(
                    child: Text(
                      "Help Center".trKey,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color : Colors.white),
                    ),
                  ),
                  backgroundColor: Globle.theme,
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),

          isLoading
              ? Center(child: LoaderSupport.loadingAnimation.widget)
              : Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Align "Contact Us" to the left
                        Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Contact Us".trKey,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        // Container for topic or question
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0, top: 20.0),
                          child: Container(
                            width: 350,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                  "Topic Or Question".trKey,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Instruction text
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                "Please summarize what you would like help with".trKey,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

                        // Container for description input
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            width: 350,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type your subject here...".trKey,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                              ),
                            ),
                          ),
                        ),

                        // Align "Any Other Details" to the left
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Any Other Details".trKey,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        // Container for additional details input
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            width: 350,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _detailsController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type any other details here...".trKey,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                              ),
                            ),
                          ),
                        ),

                        // Container for Full Name input
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            width: 350,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Full Name".trKey,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                              ),
                            ),
                          ),
                        ),

                        // Container for Email input
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            width: 350,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email".trKey,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                              ),
                            ),
                          ),
                        ),

                        // Send Message button
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                _sendMessage();
                                isLoading = false;
                                Fluttertoast.showToast(msg: "Query Submited".trKey);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            child: Text(
                              "Send Message".trKey,
                              style: TextStyle(color: Colors.black),
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
