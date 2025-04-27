import 'package:carehub/AllStaffOnlyVerified.dart';
import 'package:carehub/ContactedUs.dart';
import 'package:carehub/LoginPage.dart';
import 'package:carehub/StaffProfileHome.dart';
import 'package:carehub/StaffVerifcation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import 'LoaderSupport.dart';

class RegistaredUsers extends StatefulWidget {
  final loggedAdmin;
  RegistaredUsers({required this.loggedAdmin});
  @override
  State<StatefulWidget> createState() =>
      _RegistaredUsers(loggedAdmin: loggedAdmin);
}

class Staff {
  final FirebaseFirestore ref = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getStaffData(String uid) async {
    try {
      DocumentSnapshot doc = await ref.collection("user").doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching staff data: $e");
      return null;
    }
  }

  Future<String> getCity(String uid) async {
    var data = await getStaffData(uid);
    return data?["City"]?.toString() ?? "N/A";
  }

  Future<String> getEmail(String uid) async {
    var data = await getStaffData(uid);
    return data?["Email"]?.toString() ?? "N/A";
  }

  Future<String> getFirstName(String uid) async {
    var data = await getStaffData(uid);
    return data?["First_name"]?.toString() ?? "N/A";
  }

  Future<String> getLastName(String uid) async {
    var data = await getStaffData(uid);
    return data?["Last_name"]?.toString() ?? "N/A";
  }

  Future<String> getPhoneNumber(String uid) async {
    var data = await getStaffData(uid);
    return data?["Phone_Number1"]?.toString() ?? "N/A";
  }

  Future<String> getProfilePic(String uid) async {
    var data = await getStaffData(uid);
    return data?["Profile_Pic"]?.toString() ?? "N/A";
  }

  Future<String> getLat(String uid) async {
    var data = await getStaffData(uid);
    return data?["lat"]?.toString() ?? "N/A";
  }

  Future<String> getLong(String uid) async {
    var data = await getStaffData(uid);
    return data?["long"]?.toString() ?? "N/A";
  }
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _RegistaredUsers extends State<RegistaredUsers> {
  final loggedAdmin;
  _RegistaredUsers({required this.loggedAdmin});
  String AadharUrl = '';
  String PassportPhotoUrl = '';
  String ProfessionalDocUrl = '';
  String SelfVideoUrl = '';
  bool isLoading = true;
  bool isStaffOpen = false;
  String Searched = '';

  String SelectedUID = '';

  Staff StoredStaff = Staff();

  Widget getData(String fieldNeed) {
    Map<String, Future<String> Function(String)> fieldMethods = {
      "FirstName": StoredStaff.getFirstName,
      "LastName": StoredStaff.getLastName,
      "Email": StoredStaff.getEmail,
      "City": StoredStaff.getCity,
      "PhoneNumber": StoredStaff.getPhoneNumber,
      "ProfilePic": StoredStaff.getProfilePic,
      "Lat": StoredStaff.getLat,
      "Long": StoredStaff.getLong,
    };

    if (!fieldMethods.containsKey(fieldNeed)) {
      return Text("Invalid Field Name");
    }

    return FutureBuilder<String>(
      future: fieldMethods[fieldNeed]!(SelectedUID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoaderSupport.loadingAnimation.widget;
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Text(snapshot.data ?? "N/A");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: screenWidth * 0.7,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Color(0xfffffcc9)),
                child: Column(children: [
                  Container(
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
                        image: NetworkImage(
                            "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/carenest.png?alt=media&token=6d6df551-5264-42a6-a58c-d02e66040e43"),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Text(
                    "${loggedAdmin}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ])),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Registared Staff'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Allstaffonlyverified(
                        loggedAdmin: loggedAdmin,
                      ),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Registared User'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text('Contacted Us'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactedUse(
                        loggedAdmin: loggedAdmin,
                      ),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Pending Verifications'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffVerification(
                        loggedAdmin: loggedAdmin,
                      ),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedbacks'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 120,
            color: Colors.orange[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _scaffoldKey.currentState?.openDrawer();
                              });
                            },
                            child: Icon(
                              Icons.menu,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text("CareNest Management",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: Colors.orange[300],
                  automaticallyImplyLeading:
                      false, // Ensures a leading icon is present
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 95),
                child: Container(
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03),
                              width: screenWidth * 0.92,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 1,
                                      color: Colors.black26,
                                      blurRadius: 1)
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Icon(Icons.search,
                                        color: Colors.blue, size: 25),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          Searched = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Search...',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Registered Users",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("user")
                                .snapshots(),
                            builder: (context, snapshot) {
                              List<Row> staffViews = [];
                              if (snapshot.hasData) {
                                final staffs =
                                    snapshot.data?.docs.reversed.toList();
                                for (var staff in staffs!) {
                                  final staffData =
                                      staff.data() as Map<String, dynamic>;

                                  Row generateRow(final StaffView) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Container(
                                            height: 70,
                                            width: screenWidth * 0.9,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color: Colors.blue,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(40),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          staffData['Profile_Pic'] != null
                                                              ? staffData['Profile_Pic'] as String
                                                              : "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=",
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${staffData["First_name"]} ${staffData["Last_name"]}"
                                                                .length >
                                                            16
                                                        ? "${staffData["First_name"]} ${staffData["Last_name"]}"
                                                                .substring(
                                                                    0, 15) +
                                                            "..."
                                                        : "${staffData["First_name"]} ${staffData["Last_name"]}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        isStaffOpen = true;
                                                        setState(() {
                                                          SelectedUID =
                                                              staff.id;
                                                        });
                                                      },
                                                      child: Text("Check")),
                                                  SizedBox(
                                                    height: 5,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  bool matchesSearch(
                                      Map<String, dynamic> staffData) {
                                    String lowerSearch = Searched.toLowerCase();
                                    return Searched.isEmpty ||
                                        staffData['Last_name']
                                                ?.toLowerCase()
                                                .startsWith(lowerSearch) ==
                                            true ||
                                        staffData['First_name']
                                                ?.toLowerCase()
                                                .startsWith(lowerSearch) ==
                                            true ||
                                        staffData['City']
                                                ?.toLowerCase()
                                                .startsWith(lowerSearch) ==
                                            true ||
                                        staffData['Email']
                                                ?.toLowerCase()
                                                .startsWith(lowerSearch) ==
                                            true;
                                  }

                                  if (matchesSearch(staffData) &&
                                      !staffData.containsKey('Verified')) {
                                    staffViews.add(generateRow(staffData));
                                  }
                                }
                              }
                              return ListView(
                                padding: EdgeInsets.zero,
                                children: staffViews,
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          isStaffOpen
              ? Center(
                  child: Container(
                    height: screenHeight * 0.8,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        isStaffOpen = false;
                                      });
                                    },
                                    child: Icon(Icons.close))
                              ],
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Registared Data",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                FutureBuilder<String>(
                                  future:
                                      StoredStaff.getProfilePic(SelectedUID),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoaderSupport.loadingAnimation.widget;
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      return Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blue, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          image: DecorationImage(
                                            // ✅ Corrected this part
                                            image: NetworkImage(
                                                snapshot.data ?? ""),
                                            fit: BoxFit
                                                .cover, // Ensures proper fitting
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("Full Name",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    getData("FirstName"),
                                    getData("LastName")
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Email",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Email"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "City",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("City"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Phone Number",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("PhoneNumber"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Lat",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Lat"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Long",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Long"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
