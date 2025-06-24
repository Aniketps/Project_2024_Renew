import 'package:carehub/AllStaffOnlyVerified.dart';
import 'package:carehub/RegistreredUsers.dart';
import 'package:carehub/StaffVerifcation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globle.dart';

class ContactedUse extends StatefulWidget {
  final loggedAdmin;
  ContactedUse({required this.loggedAdmin});
  @override
  State<StatefulWidget> createState() =>
      _ContactedUse(loggedAdmin: loggedAdmin);
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _ContactedUse extends State<ContactedUse> {
  final loggedAdmin;
  void launchEmail(String email, String subject) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': "CareNest Quary status : $subject"},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("Could not launch email client.");
    }
  }

  bool isFilterAdded = false;
  bool isFilterOpen = false;
  String Searched = '';

  _ContactedUse({required this.loggedAdmin});
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
              onTap: () {},
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
          Padding(
            padding: const EdgeInsets.only(top: 95.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        width: screenWidth * 0.70,
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
                                  contentPadding: const EdgeInsets.symmetric(
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
                  padding: const EdgeInsets.only(top: 52.0),
                  child: Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("HelpCenter")
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<Row> staffViews = [];
                        if (snapshot.hasData) {
                          final staffs = snapshot.data?.docs.reversed.toList();
                          for (var staff in staffs!) {
                            final staffData =
                                staff.data() as Map<String, dynamic>;

                            Row rebuildData(bool Change) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Container(
                                      width: screenWidth * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: Colors.blue, width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Date: ${staffData["DateTime"]}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Colors.grey[700]),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines:
                                                        2, // Limit to two lines if necessary
                                                  ),
                                                  SizedBox(height: 4),
                                                  Container(
                                                    width: (screenWidth * 0.9) *
                                                        0.9,
                                                    child: Text(
                                                      "Title: ${staffData['Title']}",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      softWrap:
                                                          true, // Ensure the text wraps to the next line if needed
                                                      overflow:
                                                          TextOverflow.visible,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Container(
                                                    width: (screenWidth * 0.9) *
                                                        0.9,
                                                    child: Text(
                                                      "From: ${staffData["Name"]}",
                                                      softWrap: true,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines:
                                                          2, // Limit to two lines if necessary
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Email: ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            launchEmail(
                                                                staffData[
                                                                    "Email"],
                                                                staffData[
                                                                    "Title"]),
                                                        child: Expanded(
                                                          child: Text(
                                                            staffData["Email"],
                                                            softWrap: true,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color:
                                                                  Colors.blue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                            overflow: TextOverflow
                                                                .ellipsis, // Prevent overflow with ellipsis
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "Query:",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: (screenWidth * 0.9) *
                                                        0.9,
                                                    child: Text(
                                                      staffData["Query"],
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                      softWrap:
                                                          true, // Ensure the text wraps to the next line if needed
                                                      overflow: TextOverflow
                                                          .visible, // Allow text to wrap instead of truncating
                                                    ),
                                                  ),
                                                  staffData.containsKey(
                                                          "actionTakenBy")
                                                      ? Text(
                                                          "Action Taken by: ${staffData["actionTakenBy"]}",
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : Container(),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "HelpCenter")
                                                            .doc(staff.id)
                                                            .update({
                                                          "Status": Change,
                                                          "actionTakenBy":
                                                              loggedAdmin,
                                                        });
                                                      },
                                                      child:
                                                          Text("Action Taken"))
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            bool matchesSearch(Map<String, dynamic> staffData) {
                              String lowerSearch = Searched.toLowerCase();
                              return Searched.isEmpty ||
                                  staffData['Name']
                                          ?.toLowerCase()
                                          .startsWith(lowerSearch) ==
                                      true ||
                                  staffData['actionTakenBy']
                                          ?.toLowerCase()
                                          .startsWith(lowerSearch) ==
                                      true ||
                                  staffData['Email']
                                          ?.toLowerCase()
                                          .startsWith(lowerSearch) ==
                                      true;
                            }

                            if (matchesSearch(staffData)) {
                              if (isFilterAdded && staffData["Status"]) {
                                staffViews.add(rebuildData(false));
                              } else if (!isFilterAdded &&
                                  !staffData["Status"]) {
                                staffViews.add(rebuildData(true));
                              }
                            }
                          }
                        }
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: staffViews,
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
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
                            "Query Type",
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
                                    child: Text("Resolved"),
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
