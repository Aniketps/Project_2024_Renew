import 'package:carehub/AllStaffOnlyVerified.dart';
import 'package:carehub/ContactedUs.dart';
import 'package:carehub/StaffVerifcation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class RegistaredUsers extends StatefulWidget {
  final loggedAdmin;
  const RegistaredUsers({super.key, required this.loggedAdmin});
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
      return const Text("Invalid Field Name");
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
                decoration: BoxDecoration(color: Globle.theme),
                child: Column(children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          color: Colors.black26,
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                            "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/carenest.png?alt=media&token=6d6df551-5264-42a6-a58c-d02e66040e43"),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Text(
                    "$loggedAdmin",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ])),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Registared Staff'),
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
              leading: const Icon(Icons.person),
              title: const Text('Registared User'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Contacted Us'),
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
              leading: const Icon(Icons.verified_user),
              title: const Text('Pending Verifications'),
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
              leading: const Icon(Icons.feedback),
              title: const Text('Feedbacks'),
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
                            child: const Icon(
                              Icons.menu,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text("CareNest Management",
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
                              boxShadow: const [
                                BoxShadow(
                                    spreadRadius: 1,
                                    color: Colors.black26,
                                    blurRadius: 1)
                              ],
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
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
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search...',
                                      contentPadding:
                                          EdgeInsets.symmetric(
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
                    const Padding(
                      padding: EdgeInsets.all(8.0),
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
                                                      ? "${"${staffData["First_name"]} ${staffData["Last_name"]}"
                                                              .substring(
                                                                  0, 15)}..."
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
                                                    child: const Text("Check")),
                                                const SizedBox(
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
                                    child: const Icon(Icons.close))
                              ],
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
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
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text("Full Name",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    getData("FirstName"),
                                    getData("LastName")
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "Email",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Email"),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "City",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("City"),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "Phone Number",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("PhoneNumber"),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "Lat",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Lat"),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
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
