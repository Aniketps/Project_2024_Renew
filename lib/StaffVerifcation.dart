import 'package:carehub/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StaffVerification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StaffVerification();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _StaffVerification extends State<StaffVerification> {
  String AadharUrl = '';
  String PassportPhotoUrl = '';
  String ProfessionalDocUrl = '';
  String SelfVideoUrl = '';
  bool isLoading = true;
  bool isStaffOpen = false;

  Future<void> getStaffverificationdata(String staff) async {
    final storageRef = FirebaseStorage.instance.ref().child('VerificationDoc');

    storageRef.listAll().then((result) async {
      for (var item in result.items) {
        if (item.fullPath.contains('AadharCard') && item.name.contains(staff)) {
          await item.getDownloadURL().then((url) {
            setState(() {
              AadharUrl = url;
            });
          });
        } else if (item.fullPath.contains('PassportPhoto') &&
            item.name.contains(staff)) {
          await item.getDownloadURL().then((url) {
            setState(() {
              PassportPhotoUrl = url;
            });
          });
        } else if (item.fullPath.contains('ProfessionalDoc') &&
            item.name.contains(staff)) {
          await item.getDownloadURL().then((url) {
            setState(() {
              ProfessionalDocUrl = url;
            });
          });
        } else if (item.fullPath.contains('SelfVideo') &&
            item.name.contains(staff)) {
          await item.getDownloadURL().then((url) {
            setState(() {
              SelfVideoUrl = url;
            });
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    });
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
                    "Empty",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ])),
            InkWell(
              onLongPress: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffVerification(),
                    ));
              },
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {},
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Deals'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text('Contact Us'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Terms and Conditions'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {},
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
                                      onChanged: (value) {},
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
                                onTap: () {},
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

                                if (staffData.containsKey('Verified') &&
                                    staffData['Verified'] == 'pending') {
                                  final staffView = Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 170,
                                        width: screenWidth * 0.9,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blue, width: 1)),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      staffData['Profile_Pic']),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  isStaffOpen = true;
                                                  getStaffverificationdata(
                                                      staff.id);
                                                },
                                                child: Text("Check"))
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                  staffViews.add(staffView);
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
                    child: Column(
                      children: [
                        Row(
                          children: [],
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
