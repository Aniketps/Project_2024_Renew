import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ClientNotificationPage.dart';
import 'ContactUs.dart';
import 'Deals.dart';
import 'Feedback.dart';
import 'LoaderSupport.dart';
import 'LoginPage.dart';
import 'MainMap.dart';
import 'StaffProfilePage.dart';
import 'TC.dart';
import 'main.dart';

class ActualUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ActualUser();
}

class _ActualUser extends State<ActualUser> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String Profile_pic_url = "";

  var userData;
  bool isLoading = true;

  var StaffData;
  var documentID;
  late String currentUserID;

  Future<void> SearchStaff() async {
    User? user1 = FirebaseAuth.instance.currentUser;
    currentUserID = user1?.uid ?? '';
    CollectionReference user = FirebaseFirestore.instance.collection('user');
    try {
      DocumentSnapshot documentSnapshot = await user.doc(currentUserID).get();
      CollectionReference documentSnapshotDish =
          user.doc(currentUserID).collection("dishes");

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
  void initState() {
    super.initState();
    _fetchUserData();
    SearchStaff();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      setState(() {
        userData = documentSnapshot.data();
        isLoading = false;

        // Pre-fill the fields with user data
        if (userData != null) {
          _emailController.text = userData['Email'] ?? '';
          _addressController.text = userData['City'] ?? '';
          _phoneController.text = userData['Phone_Number1'] ?? '';
          Profile_pic_url = userData['Profile_Pic'] ?? '';
        }
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Color(0xfffffcc9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Center(
                      child: Text("Profile",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  backgroundColor: Color(0xfffffcc9),
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            isLoading || userData == null
                                ? Center(child: LoaderSupport.loadingAnimation.widget)
                                : Center(
                                    child: Container(
                                      height: screenHeight * 0.85,
                                      width: screenWidth * 0.95,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black26,
                                              spreadRadius: 1,
                                              blurRadius: 1),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              // Profile photo
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        final pickedImage =
                                                            await ImagePicker()
                                                                .pickImage(
                                                                    source: ImageSource
                                                                        .gallery);
                                                        if (pickedImage !=
                                                            null) {
                                                          setState(() async {
                                                            File imagePath =
                                                                File(pickedImage
                                                                    .path);
                                                            String? fileName =
                                                                imagePath.path
                                                                    .split('/')
                                                                    .last;
                                                            User? user =
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser;
                                                            UploadTask
                                                                uploadTask =
                                                                FirebaseStorage
                                                                    .instance
                                                                    .ref()
                                                                    .child(
                                                                        "${user?.uid}/${fileName}")
                                                                    .putFile(
                                                                        imagePath);
                                                            TaskSnapshot
                                                                snapshot =
                                                                await uploadTask;
                                                            Reference ref =
                                                                snapshot.ref;
                                                            String profileURL =
                                                                await ref
                                                                    .getDownloadURL();

                                                            if (user != null &&
                                                                profileURL
                                                                    .isNotEmpty) {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'user')
                                                                  .doc(user.uid)
                                                                  .update({
                                                                "Profile_Pic":
                                                                    profileURL,
                                                              });
                                                              // Show a confirmation message
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        "Information updated successfully!")),
                                                              );
                                                              Navigator
                                                                  .pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ActualUser(),
                                                                      ));
                                                            }
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(80),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                spreadRadius: 1,
                                                                blurRadius: 1),
                                                          ],
                                                          image:
                                                              DecorationImage(
                                                            image: Profile_pic_url ==
                                                                    ""
                                                                ? NetworkImage(
                                                                    "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=")
                                                                : NetworkImage(
                                                                    Profile_pic_url),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),

                                              // Full name
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${userData['First_name']} ${userData['Last_name']}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),

                                              // Notifications
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ClientNotificationPage(),
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                        Icons.notifications),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 20),

                                              // Input fields for email, address, phone, and services
                                              Row(
                                                children: [
                                                  // SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextField(
                                                      enabled: false,
                                                      controller:
                                                          _emailController,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Email"),
                                                    ),
                                                  ),
                                                  Icon(Icons.edit,
                                                      color: Colors.grey),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              _buildTextFieldWithIcon(
                                                  _addressController,
                                                  'City',
                                                  'City',
                                                  Icons.edit),
                                              SizedBox(height: 20),
                                              _buildTextFieldWithIcon(
                                                  _phoneController,
                                                  'Phone Number',
                                                  'Phone_Number1',
                                                  Icons.edit),
                                              SizedBox(height: 40),

                                              // Logout button
                                              ElevatedButton(
                                                onPressed: _logout,
                                                child: Text("Logout"),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.greenAccent),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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

  Widget _buildTextFieldWithIcon(TextEditingController controller, String label,
      String databasename, IconData icon) {
    return Row(
      children: [
        // SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: label == "Phone Number"? TextInputType.numberWithOptions() : TextInputType.text,
            decoration: InputDecoration(labelText: label),
          ),
        ),
        InkWell(
            onTap: () async {
              String label = controller.text;
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null && label.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(user.uid)
                    .update({
                  databasename: label,
                });
                // Show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Information updated successfully!")),
                );
              }
            },
            child: Icon(icon, color: Colors.grey)),
      ],
    );
  }
}
