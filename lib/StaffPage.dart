import 'package:carehub/LoginPage.dart';
import 'package:carehub/StaffProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'ContactUs.dart';
import 'Deals.dart';
import 'Feedback.dart';
import 'MainMap.dart';
import 'TC.dart';
import 'main.dart';

class StaffPage extends StatefulWidget {
  String Skill;
  StaffPage({required this.Skill});
  @override
  State<StatefulWidget> createState() => _StaffPage(Skill: Skill);
}

class _StaffPage extends State<StaffPage> {
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

    ;
    _liveLocation();
    SearchStaff();
  }

  String Skill;

  _StaffPage({required this.Skill});
  var StaffData;
  var documentID;
  late String currentUserID;
  String SearchGlobal = '';

  Future<void> SearchStaff() async {
    User? user1 = await FirebaseAuth.instance.currentUser;
    currentUserID = user1?.uid ?? '';
    CollectionReference user = FirebaseFirestore.instance.collection('user');
    try {
      DocumentSnapshot documentSnapshot = await user.doc(currentUserID).get();
      CollectionReference documentSnapshotDish =
          await user.doc(currentUserID).collection("dishes");

      if (documentSnapshot.exists) {
        setState(() {
          StaffData = documentSnapshot.data();
          documentID = documentSnapshot.id;
        });
      } else {
        print("No staff found with ID: $currentUserID");
      }
    } catch (e) {
      print("Error fetching user by Staff ID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      drawer: Drawer(
        width: screenWidth * 0.7,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.red),
                child: Column(children: [
                  (StaffData != null && StaffData['Profile_Pic'] != null)
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StaffProfilePage(
                                      StaffID: currentUserID,
                                      Skill: StaffData['professionOfStaff'] ??
                                          'user'),
                                ));
                          },
                          child: Container(
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
                                fit:
                                    BoxFit.cover, // Adjust the fit if necessary
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActualUser(),
                                ));
                          },
                          child: Container(
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
                        ),
                  (StaffData == null)
                      ? Text(
                          "Empty",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : Text(
                          "${StaffData['First_name']} ${StaffData['Last_name']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ])),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Deals'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Deals(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUs(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Terms and Conditions'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TC(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Feedbacks(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Colors.red,
            child: AppBar(
              title: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMap(),
                        ));
                  },
                  child: Text(
                      (StaffData != null && StaffData['City'] != null)
                          ? StaffData['City']
                          : "Location...",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red,
              automaticallyImplyLeading: true,
            ),
          ),

          // Profile photo
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (StaffData != null && StaffData['Profile_Pic'] != null)
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StaffProfilePage(
                                    StaffID: currentUserID,
                                    Skill: StaffData['professionOfStaff'] ??
                                        'user'),
                              ));
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(StaffData['Profile_Pic']),
                              fit: BoxFit.cover, // Adjust the fit if necessary
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActualUser(),
                              ));
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),

          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 125),
                child: Container(
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                              width: screenWidth * 0.7,
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
                                          SearchGlobal = value;
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
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 50,
                                width: screenWidth * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1,
                                        color: Colors.black26,
                                        blurRadius: 1),
                                  ],
                                ),
                                child: Icon(Icons.filter_list_sharp,
                                    size: 30, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(Skill)
                              .snapshots(),
                          builder: (context, snapshot) {
                            List<Row> chefViews = [];
                            if (snapshot.hasData) {
                              final chefs =
                                  snapshot.data?.docs.reversed.toList();
                              for (var chef in chefs!) {
                                final chefView = Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StaffProfilePage(
                                                        StaffID: chef.id,
                                                        Skill: Skill),
                                              ));
                                        },
                                        child: Container(
                                          height: screenHeight * 0.2,
                                          width: screenWidth * 0.95,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 1,
                                                    spreadRadius: 1)
                                              ]),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20),
                                            child: Container(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Container(
                                                      height: 75,
                                                      width: 75,
                                                      decoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        color: Colors.orange,
                                                        image:
                                                            DecorationImage(
                                                          image: NetworkImage(
                                                              chef[
                                                                  'Profile_Pic']),
                                                          fit: BoxFit
                                                              .cover, // Adjust the fit if necessary
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 5,
                                                            bottom: 40),
                                                    child: Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "${chef['First_name']} ${chef['Last_name']}",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  chef["Status"]
                                                                      ? "Available"
                                                                      : "Busy",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green)),
                                                              Text(" | "),
                                                              Text(
                                                                  "${chef['Rating']}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: screenWidth * 0.3,
                                                    height:
                                                        screenHeight * 0.2,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10),
                                                          child: Text(
                                                            chef['City'],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          width: 120,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              color: Colors.white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .black26,
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        1)
                                                              ]),
                                                          child: Center(
                                                              child: Text(
                                                            Skill,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 15),
                                                          )),
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
                              padding: EdgeInsets.zero,
                              children: chefViews,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Search result
              SearchGlobal.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 180,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: screenHeight * 0.5,
                              width: screenWidth * 0.85,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 2)
                                  ]),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('user')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text("No Users Found"),
                                    );
                                  }

                                  if (SearchGlobal.isEmpty) {
                                    return Center(child: Text("Empty"));
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index]
                                          .data() as Map<String, dynamic>;
                                      var UID = snapshot.data!.docs[index].id;
                                      if (data['professionOfStaff'] != null &&
                                          data['First_name'] != null &&
                                          data['First_name']
                                              .toString()
                                              .toLowerCase()
                                              .startsWith(
                                                  SearchGlobal.toLowerCase())) {
                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StaffProfilePage(
                                                            StaffID: UID,
                                                            Skill: data[
                                                                'professionOfStaff']),
                                                  ));
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        spreadRadius: 1,
                                                        blurRadius: 1)
                                                  ]),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  data[
                                                                      'Profile_Pic']),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                        width: 150,
                                                        child: Text(
                                                          "${data['First_name']} ${data['Last_name']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      data['City'][0]
                                                              .toUpperCase() +
                                                          data['City']
                                                              .substring(1),
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else if (data['professionOfStaff'] !=
                                              null &&
                                          data['First_name'] != null &&
                                          data['City']
                                              .toString()
                                              .toLowerCase()
                                              .startsWith(
                                                  SearchGlobal.toLowerCase())) {
                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StaffProfilePage(
                                                            StaffID: UID,
                                                            Skill: data[
                                                                'professionOfStaff']),
                                                  ));
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        spreadRadius: 1,
                                                        blurRadius: 1)
                                                  ]),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  data[
                                                                      'Profile_Pic']),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                        width: 150,
                                                        child: Text(
                                                          "${data['First_name']} ${data['Last_name']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      data['City'][0]
                                                              .toUpperCase() +
                                                          data['City']
                                                              .substring(1),
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }
}
