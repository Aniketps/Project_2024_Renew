import 'dart:io';

import 'package:carehub/LoginPage.dart';
import 'package:carehub/StaffPage.dart';
import 'package:carehub/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StaffDetailInputPage extends StatefulWidget{
  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  StaffDetailInputPage({required this.FirstName, required this.LastName, required this.Email, required this.Password });
  @override
  State<StatefulWidget> createState() => _StaffDetailInputPage(Password: Password, FirstName: FirstName, Email: Email, LastName: LastName);
}

class _StaffDetailInputPage extends State<StaffDetailInputPage>{


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

            await FirebaseFirestore.instance.collection('user').doc(user?.uid).update({
              'lat' : lat,
              'long' : long,
            });
          });
        },
      );
    };
    _liveLocation();
  }

  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  _StaffDetailInputPage({required this.FirstName, required this.LastName, required this.Email, required this.Password });

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    final isWeb = screenWidth > 700;

    return Scaffold(
        backgroundColor: Colors.white,
        body: isWeb? WebView() : AndroidView(Password: Password, FirstName: FirstName, Email: Email, LastName: LastName)
    );
  }
}

class AndroidStaffPage extends StatefulWidget{

  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  AndroidStaffPage({required this.FirstName, required this.LastName, required this.Email, required this.Password });

  @override
  State<StatefulWidget> createState() => _AndroidStaffPage(Password: Password, FirstName: FirstName, Email: Email, LastName: LastName);
}

class _AndroidStaffPage extends State<AndroidStaffPage>{

  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  _AndroidStaffPage({required this.FirstName, required this.LastName, required this.Email, required this.Password });

  List<String> items = ["Chef", "Personal Care Assistants", "Driver", "Security Guards",
    "Home Guards", "Elder Companions", "Babysitters", "Cleaner",
    "Housekeepers", "Elderly", "Paramedics", "Occupational Therapists",
    "Physiotherapists", "Home Health Aides", "Certified Nursing Assistants",
    "Licensed Practical Nurses", "Registered Nurses"];
  String? selectedValue;
  String ErrorData = "";

  TextEditingController PhoneNo = TextEditingController();
  TextEditingController City = TextEditingController();
  TextEditingController ProfilePic = TextEditingController();

  File? imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          margin: EdgeInsets.only(bottom: 40, top: 50),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(80),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1),
            ],
            image: DecorationImage(
              image: AssetImage("assets/images/logo.png"),
              fit: BoxFit.cover, // Adjust the fit if necessary
            ),
          ),
        ),
        Center(
          child: Container(
            height: 520,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                ]
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text("Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        width: 265,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                        ),
                        child: DropdownButton<String>(
                          value: selectedValue,
                          hint: Text("Select an option"),
                          items: items.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: 200,
                                ),
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1, // Limit to 1 line
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Container(
                          height: 50,
                          width: 175,
                          child: TextField(
                            controller: PhoneNo,
                            decoration: InputDecoration(
                                labelText: "Phone no.", // Placeholder text
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 90,
                        child: ElevatedButton(
                          onPressed: () {

                          },
                          child: Text("Send", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 270 * 0.05),
                        child: Container(
                          height: 50,
                          width: (270 * 0.45),
                          child: ElevatedButton(
                            onPressed: () async {

                            },
                            child: Text("Resend", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          )
                        ),
                      ),
                      Container(
                        height: 50,
                        width: (270 * 0.5),
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: "OTP", // Placeholder text
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),

                              ),
                              contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: City,
                      decoration: InputDecoration(
                          labelText: "City", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                  child: Container(
                    height: 50,
                    child: ElevatedButton(onPressed: () async {
                      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if(pickedImage!=null){
                        setState(() {
                          imagePath = File(pickedImage.path);
                        });
                      }
                    },
                        child: Text("Select Image")
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                      onPressed: () async {
                        String phone = PhoneNo.text;
                        String city = City.text;
                        String skill = selectedValue.toString();
                        if(phone.isNotEmpty && city.isNotEmpty && skill.isNotEmpty){
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: Email, password: Password);
                            User? user = userCredential.user;
                            String? fileName = imagePath?.path.split('/').last;
                            UploadTask uploadTask = FirebaseStorage.instance.ref().child("${user?.uid}/${fileName}").putFile(imagePath!);
                            TaskSnapshot snapshot = await uploadTask;
                            Reference ref = snapshot.ref;
                            String profileURL = await ref.getDownloadURL();
                            await FirebaseFirestore.instance.collection(skill.toLowerCase()).doc(user?.uid).set({
                              'Email':Email,
                              'City':city,
                              'First_name':FirstName,
                              'professionOfStaff': skill[0].toLowerCase()+skill.substring(1),
                              'Password':Password,
                              'Phone_Number1':phone,
                              'Profile_Pic':profileURL,
                              'Last_name':LastName,
                              'Rating': 0,
                              'Status':false,
                              'Date_of_registered': DateFormat("dd/MM/yyyy").format(DateTime.now()),
                              'Verified_status' : false,
                            });
                            print("Test case 8 Passed");
                            await FirebaseFirestore.instance.collection('user').doc(user?.uid).set({
                              "Email":Email,
                              "First_name":FirstName,
                              'professionOfStaff': skill[0].toLowerCase()+skill.substring(1),
                              "Last_name":LastName,
                              "Password":Password,
                              "Phone_Number1":phone,
                              "City":city,
                              "Profile_Pic":profileURL,
                            });
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(),));
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              ErrorData = e.message!;
                            });
                          } catch (e) {
                            setState(() {
                              ErrorData = "$e";
                            });
                          }
                        }else{
                          setState(() {
                            ErrorData ="Fill all the blanks";
                          });
                        }
                      },
                      child: Text("Submit")),
                ),
                Text(ErrorData),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WebStaffPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WebStaffPage();
}

class _WebStaffPage extends State<WebStaffPage>{
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenHeight = mediaquery.size.height;
    final screenWidth = mediaquery.size.width;

    return Container(
      height: screenHeight * 0.50,
      width: screenWidth * 0.65,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          children: [
            Container(
              height: (screenHeight * 0.55) * 0.75,
              width: (screenWidth * 0.65) * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                  ),
                  // Login
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                  ),
                  // Use your user account to login
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: (screenHeight * 0.55) * 0.75,
              width: (screenWidth * 0.65) * 0.38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email input
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 50,
                      width: (screenWidth * 0.65) * 0.38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                      ),
                    ),
                  ),

                  // Email Forgot
                  Container(
                    height: 20,
                    width: ((screenWidth * 0.65) * 0.38) * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                    ),
                  ),

                  // Email input
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 50,
                      width: (screenWidth * 0.65) * 0.38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                      ),
                    ),
                  ),

                  // Email forgot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        width: ((screenWidth * 0.65) * 0.38) * 0.4,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                        ),
                      ),
                      Container(
                        height: 20,
                        width: ((screenWidth * 0.65) * 0.38) * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                        ),
                      ),
                    ],
                  ),

                  // Submit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Container(
                          height: 40,
                          width: (screenWidth * 0.65) * 0.1,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AndroidView extends StatefulWidget{
  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  AndroidView({required this.FirstName, required this.LastName, required this.Email, required this.Password });
  @override
  State<StatefulWidget> createState() => _AndroidView(Password: Password, FirstName: FirstName, Email: Email, LastName: LastName);
}

class _AndroidView extends State<AndroidView>{

  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  _AndroidView({required this.FirstName, required this.LastName, required this.Email, required this.Password });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Color(0xff2020b7),
          height: 320,
          width: double.maxFinite,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              AndroidStaffPage(Password: Password, FirstName: FirstName, Email: Email, LastName: LastName)
            ],
          ),
        )
      ],
    );
  }
}

class WebView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WebView();
}

class _WebView extends State<WebView>{
  Color StaffColorTrue = Colors.blueAccent;
  Color StaffColorFalse = Colors.white;
  bool StaffPressed = false;
  Color StaffColor = Colors.white;
  Color UserColorTrue = Colors.blueAccent;
  Color UserColorFalse = Colors.white;
  bool UserPressed = true;
  Color UserColor = Colors.blueAccent;
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Stack(
      children: [
        ClipPath(
          clipper: BlueShapeClipper(),
          child: Container(
            height: screenHeight,
            width: screenWidth,// Adjust the height accordingly
            color: Color(0xff2020b7),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, right: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                          ]
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(onPressed: () {
                            setState(() {
                              StaffPressed = !StaffPressed;
                              if(StaffPressed){
                                StaffColor = StaffColorTrue;
                                UserColor = UserColorFalse;
                                UserPressed = false;
                              }else{
                                StaffColor = StaffColorFalse;
                              }
                            });
                          },style: ElevatedButton.styleFrom(
                              backgroundColor: StaffColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(50),
                                      topRight: Radius.circular(0)
                                  )
                              ),
                              minimumSize: Size(100, 50)
                          ),
                              child: Text("Staff", style: TextStyle(color: Color(0xff013220), fontWeight: FontWeight.bold),)),
                          ElevatedButton(onPressed: () {
                            setState(() {
                              UserPressed = !UserPressed;
                              if(UserPressed){
                                StaffColor = StaffColorFalse;
                                UserColor = UserColorTrue;
                                StaffPressed = false;
                              }else{
                                UserColor = UserColorFalse;
                              }
                            });
                          },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: UserColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(50),
                                          bottomLeft: Radius.circular(0),
                                          topRight: Radius.circular(50)
                                      )
                                  ),
                                  minimumSize: Size(100, 50)
                              ),
                              child: Text("User",style: TextStyle(color: Color(0xff8B0000), fontWeight: FontWeight.bold),))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StaffPressed? WebStaffPage() : WebUserPage()
            ],
          ),
        )
      ],
    );
  }
}

class BlueShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 1); // Left-middle
    path.lineTo(size.width * 1, size.height * 0.65); // Diagonal towards right
    path.lineTo(size.width, size.height * 01); // Top-right curve
    path.lineTo(size.width , 0); // Top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
