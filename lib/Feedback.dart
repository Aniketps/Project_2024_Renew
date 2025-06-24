import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class Feedbacks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Feedbacks();
}

class _Feedbacks extends State<Feedbacks> {
  @override
  void initState() {
    super.initState();
    _liveLocation();
    getCurrentUser();
  }

  String uid = "";
  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      uid = user!.uid;
    });
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    child: Text("Feedbacks",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: screenHeight * 0.6,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          color: Colors.black26)
                                    ]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Recent Feedbacks',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 5, right: 15),
                                      child: Divider(color: Colors.black),
                                    ),
                                    Expanded(
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("Feedbacks")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          // Error check
                                          if (snapshot.hasError) {
                                            return Text("Something went wrong");
                                          }

                                          // Loading state
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                LoaderSupport.loadingAnimation.widget);
                                          }

                                          // No data available
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Text(
                                                "No feedbacks available.");
                                          }

                                          var feedbacks = snapshot.data!.docs;
                                          int count = 0;

                                          if (uid == "") {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else {
                                            List<Widget> feedbackWidgets =
                                                feedbacks
                                                    .where((feedback) =>
                                                        uid ==
                                                        feedback['UserUID'])
                                                    .map<Widget>((feedback) {
                                              count++;
                                              var subject =
                                                  feedback['Subject'] ??
                                                      "No Subject";
                                              bool status =
                                                  feedback['Status'] ?? false;
                                              var timestamp =
                                                  feedback['DateTime'] ??
                                                      "---------";

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 15,
                                                    left: 15,
                                                    bottom: 8),
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 1,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 15,
                                                            left: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          10),
                                                              child: Container(
                                                                height: 22,
                                                                width: 22,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: status
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .green,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              22),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: status
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black26,
                                                                      blurRadius:
                                                                          1,
                                                                      spreadRadius:
                                                                          1,
                                                                    ),
                                                                  ],
                                                                  image: status
                                                                      ? DecorationImage(
                                                                          image:
                                                                              NetworkImage("https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/currect%20icon.png?alt=media&token=b3c6c4e9-5283-4d50-8e39-965695c07808"),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : null,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                width: 100,
                                                                child: Text(
                                                                  subject,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                )),
                                                          ],
                                                        ),
                                                        Text("$timestamp",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(); // Explicitly convert to List<Widget>

                                            if (count == 0) {
                                              return Text(
                                                  "No feedback for this user.");
                                            }

                                            return ListView(
                                              padding: EdgeInsets.zero,
                                              children: feedbackWidgets,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BlankPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                "New",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 2,
            )
          ]),
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

class BlankPage extends StatefulWidget {
  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  // Text editing controllers for input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Clear the text fields
  void _clearFields() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  @override
  void dispose() {
    // Dispose controllers when not in use to free resources
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Header section
          _buildHeader(),
          Padding(
            padding: EdgeInsets.only(top: 150),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    _buildFeedbackForm(screenWidth, screenHeight),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method for the header section with AppBar
  Widget _buildHeader() {
    return Container(
      height: 150,
      color: Globle.theme,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppBar(
            title: Center(
              child: Text("New Feedback",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
            ),
            backgroundColor: Globle.theme,
            automaticallyImplyLeading: false,
          ),
        ],
      ),
    );
  }

  // Method to build the feedback form
  Widget _buildFeedbackForm(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(),
          const SizedBox(height: 15),
          _buildDescriptionField(screenWidth, screenHeight),
        ],
      ),
    );
  }

  // Method for the title input field
  Widget _buildTitleField() {
    return TextField(
      controller: _titleController, // Attach controller
      decoration: InputDecoration(
        hintText: "Title",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Method for the description field (height adjusted based on screen)
  Widget _buildDescriptionField(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.5,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _descriptionController, // Attach controller
        maxLines: null, // Allows for multi-line input
        expands: true,
        decoration: InputDecoration(
          hintText: "Enter your feedback here...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Method to build action buttons (Clear and Post)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildClearButton(),
        _buildPostButton(),
      ],
    );
  }

  // Clear button
  Widget _buildClearButton() {
    return InkWell(
      onTap: _clearFields, // Attach clear method
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          "Clear All",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Post button with ElevatedButton style
  Widget _buildPostButton() {
    return ElevatedButton(
      onPressed: () async {
        String title = _titleController.text;
        String description = _descriptionController.text;
        User? user = await FirebaseAuth.instance.currentUser;
        String? userUID = user?.uid;
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(now);

        if (title.isNotEmpty && description.isNotEmpty) {
          await FirebaseFirestore.instance.collection("Feedbacks").add({
            "DateTime": formattedDate,
            "Description": description,
            "Status": false,
            "Subject": title,
            "UserUID": userUID,
          });
          Fluttertoast.showToast(msg: "Feedback Submited");
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: "Please fill the details");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        "Post",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}
