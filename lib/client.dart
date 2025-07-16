import 'dart:io';

import 'package:carehub/services/convertToTranslate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'ClientNotificationPage.dart';
import 'LoaderSupport.dart';
import 'LoginPage.dart';
import 'globle.dart';

class ActualUser extends StatefulWidget {
  const ActualUser({super.key});

  @override
  State<StatefulWidget> createState() => _ActualUser();
}

class _ActualUser extends State<ActualUser> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _lastName = TextEditingController();
  late final TextEditingController _firstName = TextEditingController();
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
      user.doc(currentUserID).collection("dishes");

      if (documentSnapshot.exists) {
        setState(() {
          StaffData = documentSnapshot.data();
          documentID = documentSnapshot.id;
        });
      } else {
      }
    } catch (e) {
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
          _lastName.text = userData['First_name']?? '';
          _firstName.text = userData['Last_name']?? '';
        }
      });
    }
  }

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
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
            color: Globle.theme,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 35),
                    child: Center(
                      child: Text("Profile".trKey,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
                    ),
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
                padding: const EdgeInsets.only(top: 120),
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
                                      boxShadow: const [
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
                                                              const SnackBar(
                                                                  content: Text(
                                                                      "Information updated successfully!")),
                                                            );
                                                            Navigator
                                                                .pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const ActualUser(),
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
                                                        boxShadow: const [
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
                                                              ? const NetworkImage(
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

                                            const SizedBox(height: 20),

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
                                                                "Email".trKey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20,),
                                            _buildTextFieldWithIcon(
                                                _lastName,
                                                'First Name',
                                                'First_name',
                                                Icons.done_outline),
                                            const SizedBox(height: 20),
                                            _buildTextFieldWithIcon(
                                                _firstName,
                                                'Last Name',
                                                'Last_name',
                                                Icons.done_outline),
                                            const SizedBox(height: 20),
                                            _buildTextFieldWithIcon(
                                                _addressController,
                                                'City',
                                                'City',
                                                Icons.done_outline),
                                            const SizedBox(height: 20),
                                            _buildTextFieldWithIcon(
                                                _phoneController,
                                                'Phone Number',
                                                'Phone_Number1',
                                                Icons.done_outline),
                                            const SizedBox(height: 40),

                                            // Logout button
                                            ElevatedButton(
                                              onPressed: _logout,
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.greenAccent),
                                              child: Text("Logout".trKey),
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
            keyboardType: label == "Phone Number"? const TextInputType.numberWithOptions() : TextInputType.text,
            decoration: InputDecoration(labelText: label.trKey),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Information updated successfully!".trKey)),
                );
              }
            },
            child: Icon(icon, color: Colors.grey)),
      ],
    );
  }
}
