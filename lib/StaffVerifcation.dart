import 'package:carehub/AllStaffOnlyVerified.dart';
import 'package:carehub/ContactedUs.dart';
import 'package:carehub/LoginPage.dart';
import 'package:carehub/RegistreredUsers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class StaffVerification extends StatefulWidget {
  final loggedAdmin;
  StaffVerification({required this.loggedAdmin});
  @override
  State<StatefulWidget> createState() =>
      _StaffVerification(loggedAdmin: loggedAdmin);
}

class Staff {
  final FirebaseFirestore ref = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getStaffData(String uid, String skill) async {
    try {
      DocumentSnapshot doc = await ref.collection(skill).doc(uid).get();
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

  Future<String> getCity(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["City"]?.toString() ?? "N/A";
  }

  Future<String> getDateOfRegistered(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Date_of_registered"]?.toString() ?? "N/A";
  }

  Future<String> getDayRate(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Day_Rate"]?.toString() ?? "N/A";
  }

  Future<String> getDayShift(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Day_Shift"]?.toString() ?? "N/A";
  }

  Future<String> getEmail(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Email"]?.toString() ?? "N/A";
  }

  Future<String> getFirstName(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["First_name"]?.toString() ?? "N/A";
  }

  Future<String> getLastName(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Last_name"]?.toString() ?? "N/A";
  }

  Future<String> getPhoneNumber(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Phone_Number1"]?.toString() ?? "N/A";
  }

  Future<String> getActionDatenBy(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data!.containsKey("actionTakenBy")
        ? data["actionTakenBy"]?.toString() ?? "N/A"
        : "N/A";
  }

  Future<String> getProfilePic(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Profile_Pic"]?.toString() ?? "N/A";
  }

  Future<String> getRating(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Rating"]?.toString() ?? "N/A";
  }

  Future<String> getStatus(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Status"]?.toString() ?? "N/A";
  }

  Future<String> getTravelingCharges(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Traveling_Charges"]?.toString() ?? "N/A";
  }

  Future<String> getVerified(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["Verified"]?.toString() ?? "N/A";
  }

  Future<String> getLat(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["lat"]?.toString() ?? "N/A";
  }

  Future<String> getLong(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["long"]?.toString() ?? "N/A";
  }
  Future<String> getVerifiredPhoneNumber(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["VerifiedNumber"]?.toString() ?? "N/A";
  }
  Future<String> getFullName(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["VerifiedName"]?.toString() ?? "N/A";
  }
  Future<String> getUPI(String uid, String skill) async {
    var data = await getStaffData(uid, skill);
    return data?["UPI"]?.toString() ?? "N/A";
  }
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _StaffVerification extends State<StaffVerification> {
  final loggedAdmin;
  _StaffVerification({required this.loggedAdmin});
  String AadharUrl = '';
  String PassportPhotoUrl = '';
  String ProfessionalDocUrl = '';
  String SelfVideoUrl = '';
  bool isLoading = true;
  bool isStaffOpen = false;
  bool isFilterOpen = false;
  bool isFilterAdded = false;
  String Searched = '';

  String SelectedUID = '';
  String SelectedProf = '';

  Future<void> getStaffverificationdata(String staff) async {
    setState(() => isLoading = true);

    try {
      // Get the download URLs
      AadharUrl = await FirebaseStorage.instance
          .ref('/VerificationDoc/AadharCard/$staff') // No extension
          .getDownloadURL()
          .catchError((_) => '');

      PassportPhotoUrl = await FirebaseStorage.instance
          .ref('/VerificationDoc/PassportPhoto/$staff') // No extension
          .getDownloadURL()
          .catchError((_) => '');

      ProfessionalDocUrl = await FirebaseStorage.instance
          .ref('/VerificationDoc/ProfessionalDoc/$staff') // No extension
          .getDownloadURL()
          .catchError((_) => '');

      SelfVideoUrl = await FirebaseStorage.instance
          .ref('/VerificationDoc/SelfVideo/$staff') // No extension
          .getDownloadURL()
          .catchError((_) => '');
    } catch (e) {
      print("Error fetching verification data: $e");
    }

    print("Test 8");
    setState(() => isLoading = false);
  }

  Staff StoredStaff = Staff();

  Widget getData(String fieldNeed) {
    Map<String, Future<String> Function(String, String)> fieldMethods = {
      "FirstName": StoredStaff.getFirstName,
      "LastName": StoredStaff.getLastName,
      "Email": StoredStaff.getEmail,
      "City": StoredStaff.getCity,
      "DateOfRegistered": StoredStaff.getDateOfRegistered,
      "DayRate": StoredStaff.getDayRate,
      "DayShift": StoredStaff.getDayShift,
      "PhoneNumber": StoredStaff.getPhoneNumber,
      "ProfilePic": StoredStaff.getProfilePic,
      "Rating": StoredStaff.getRating,
      "Status": StoredStaff.getStatus,
      "TravelingCharges": StoredStaff.getTravelingCharges,
      "Verified": StoredStaff.getVerified,
      "Lat": StoredStaff.getLat,
      "Long": StoredStaff.getLong,
      "actionTakenBy": StoredStaff.getActionDatenBy,
      "FullName": StoredStaff.getFullName,
      "UPI": StoredStaff.getUPI,
      "VerifiedNumber": StoredStaff.getVerifiredPhoneNumber,
    };

    if (!fieldMethods.containsKey(fieldNeed)) {
      return Text("Invalid Field Name");
    }

    return FutureBuilder<String>(
      future: fieldMethods[fieldNeed]!(SelectedUID, SelectedProf),
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

  TextEditingController feedbackToStaff = TextEditingController();

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
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistaredUsers(
                        loggedAdmin: loggedAdmin,
                      ),
                    ));
              },
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
              onTap: () {},
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
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03),
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
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isFilterOpen = !isFilterOpen;
                                  });
                                },
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
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Pending Staff Verifications",
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

                              Row generateRow(final staffData, var staff) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        height: 70,
                                        width: screenWidth * 0.9,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: Colors.blue, width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        staffData[
                                                                'Profile_Pic'] ??
                                                            ''),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${staffData["First_name"]} ${staffData["Last_name"]}"
                                                            .length >
                                                        12
                                                    ? "${staffData["First_name"]} ${staffData["Last_name"]}"
                                                            .substring(0, 10) +
                                                        "..."
                                                    : "${staffData["First_name"]} ${staffData["Last_name"]}",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                staffData["professionOfStaff"]
                                                            .length >
                                                        7
                                                    ? "${staffData["professionOfStaff"].substring(0, 7)}..."
                                                    : "${staffData["professionOfStaff"][0].toUpperCase()}${staffData["professionOfStaff"].substring(1)}",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  isStaffOpen = true;
                                                  setState(() {
                                                    SelectedProf = staffData[
                                                        "professionOfStaff"];
                                                    SelectedUID = staff.id;
                                                  });
                                                  getStaffverificationdata(
                                                      staff.id);
                                                },
                                                child: Text("Check"),
                                              ),
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
                                    staffData['First_name']
                                            ?.toLowerCase()
                                            .startsWith(lowerSearch) ==
                                        true ||
                                    staffData['Last_name']
                                            ?.toLowerCase()
                                            .startsWith(lowerSearch) ==
                                        true ||
                                    staffData['Email']
                                            ?.toLowerCase()
                                            .startsWith(lowerSearch) ==
                                        true;
                              }

                              bool matchesFilter(
                                  Map<String, dynamic> staffData) {
                                return staffData.containsKey('Verified') &&
                                    ((isFilterAdded &&
                                            staffData['Verified'] ==
                                                'rejected') ||
                                        (!isFilterAdded &&
                                            staffData['Verified'] ==
                                                'pending'));
                              }

                              for (var staff in staffs!) {
                                final staffData =
                                    staff.data() as Map<String, dynamic>;

                                if (matchesSearch(staffData) &&
                                    matchesFilter(staffData)) {
                                  staffViews.add(generateRow(staffData, staff));
                                }
                              }
                            }
                            return ListView(
                              padding: EdgeInsets.zero,
                              children: staffViews,
                            );
                          },
                        ),
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
                                Text("Registared Data",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                FutureBuilder<String>(
                                  future: StoredStaff.getProfilePic(
                                      SelectedUID, SelectedProf),
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
                                    getData("FullName")
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
                                  "Date Of Registered : ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("DateOfRegistered"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Day Rate",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("DayRate"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Day Shift",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("DayShift"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Phone Number",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("VerifiedNumber"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "UPI",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("UPI"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Rating",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Rating"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Status",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Status"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Traveling Charges",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("TravelingCharges"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Verified",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("Verified"),
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
                                Text(
                                  "Action Taken By",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                getData("actionTakenBy"),
                              ],
                            ),
                          ),
                          Text("Personal ID Document"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: NetworkImage(AadharUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors
                                            .transparent, // Ensure no black overlay
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors
                                              .transparent, // Remove black background
                                          insetPadding: EdgeInsets.all(
                                              0), // Remove extra padding
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(
                                                context), // Tap anywhere to close
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.black.withOpacity(
                                                  0.9), // Optional: Adds slight dim effect
                                              child: Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: PhotoView(
                                                    imageProvider:
                                                        NetworkImage(AadharUrl),
                                                    minScale:
                                                        PhotoViewComputedScale
                                                            .contained,
                                                    maxScale:
                                                        PhotoViewComputedScale
                                                                .covered *
                                                            2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text("Photo"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: NetworkImage(PassportPhotoUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors
                                            .transparent, // Ensure no black overlay
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors
                                              .transparent, // Remove black background
                                          insetPadding: EdgeInsets.all(
                                              0), // Remove extra padding
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(
                                                context), // Tap anywhere to close
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.black.withOpacity(
                                                  0.9), // Optional: Adds slight dim effect
                                              child: Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: PhotoView(
                                                    imageProvider: NetworkImage(
                                                        PassportPhotoUrl),
                                                    minScale:
                                                        PhotoViewComputedScale
                                                            .contained,
                                                    maxScale:
                                                        PhotoViewComputedScale
                                                                .covered *
                                                            2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text("Self Video"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLoading
                                ? Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                        child: LoaderSupport.loadingAnimation.widget),
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: VideoPlayerWidget(
                                            videoUrl: SelfVideoUrl),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierColor: Colors.transparent,
                                              builder: (context) => Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding: EdgeInsets.all(0),
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      Navigator.pop(context),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    color: Colors.black
                                                        .withOpacity(0.9),
                                                    child: Center(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: VideoPlayerWidget(
                                                            videoUrl:
                                                                SelfVideoUrl),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.fullscreen,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          Text("Professional Document"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: NetworkImage(ProfessionalDocUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors
                                            .transparent, // Ensure no black overlay
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors
                                              .transparent, // Remove black background
                                          insetPadding: EdgeInsets.all(
                                              0), // Remove extra padding
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(
                                                context), // Tap anywhere to close
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.black.withOpacity(
                                                  0.9), // Optional: Adds slight dim effect
                                              child: Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: PhotoView(
                                                    imageProvider: NetworkImage(
                                                        ProfessionalDocUrl),
                                                    minScale:
                                                        PhotoViewComputedScale
                                                            .contained,
                                                    maxScale:
                                                        PhotoViewComputedScale
                                                                .covered *
                                                            2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: feedbackToStaff,
                              style: GoogleFonts.poppins(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: "Feedback to Staff",
                                hintStyle: TextStyle(color: Colors.black54),
                                filled: true,
                                fillColor: Colors.blueAccent[350],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("user")
                                        .doc(SelectedUID)
                                        .update({
                                      "Verified": "rejected",
                                      "actionTakenBy": loggedAdmin,
                                      "Feedback": feedbackToStaff.text
                                    });
                                    await FirebaseFirestore.instance
                                        .collection(SelectedProf)
                                        .doc(SelectedUID)
                                        .update({
                                      "Verified": "rejected",
                                      "actionTakenBy": loggedAdmin,
                                      "Feedback": feedbackToStaff.text
                                    });
                                    setState(() {
                                      isStaffOpen = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Staff Document Rejected")));
                                  },
                                  child: Text("Reject")),
                              ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("user")
                                        .doc(SelectedUID)
                                        .update({
                                      "Verified": "verified",
                                      "actionTakenBy": loggedAdmin,
                                      "Feedback": feedbackToStaff.text
                                    });
                                    await FirebaseFirestore.instance
                                        .collection(SelectedProf)
                                        .doc(SelectedUID)
                                        .update({
                                      "Verified": "verified",
                                      "actionTakenBy": loggedAdmin,
                                      "Feedback": feedbackToStaff.text
                                    });
                                    setState(() {
                                      isStaffOpen = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Staff Documents Accepted")));
                                  },
                                  child: Text("Accept"))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          isFilterOpen
              ? Positioned(
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.only(top: 147),
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            topLeft: Radius.circular(15)),
                        border: Border.all(color: Colors.blue, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verification Status",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isFilterAdded = !isFilterAdded;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isFilterAdded
                                          ? Colors.green
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 1,
                                            color: Colors.blue,
                                            spreadRadius: 1)
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Rejected"),
                                  ),
                                ),
                              ),
                            ],
                          )
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

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        : Container(
            height: 200,
            color: Colors.black,
            child: Center(
              child: LoaderSupport.loadingAnimation.widget,
            ),
          );
  }
}
