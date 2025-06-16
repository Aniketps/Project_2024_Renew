import 'dart:async';

import 'package:carehub/LoaderSupport.dart';
import 'package:carehub/RegisterPage.dart';
import 'package:carehub/StaffProfileHome.dart';
import 'package:carehub/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _setUserPageStatus(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool("Staff", value);
}

class UserData {
  static final UserData _instance = UserData._internal();
  bool isStaff = false;

  factory UserData() {
    return _instance;
  }

  UserData._internal();
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String lat = '';
  String long = '';
  String locationMessage = "Check current location";
  String loadingText = 'Connecting to Network...';

  late LocationPermission permission;
  Timer? timer;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getPermission();
    await _getCurrentLocation();
    _startLiveLocation();

    final staffStatusFuture = _getUserPageStatus();
    checkLogin(staffStatusFuture);
  }

  Future<void> _getPermission() async {
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission is required.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied.';
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // Wait and retry if location is still disabled
    if (!serviceEnabled) {
      // Retry after a short delay
      await Future.delayed(Duration(seconds: 1));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showLocationDialog(); // Only show if still disabled after retry
        return;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (!mounted) return;
    setState(() {
      lat = '${position.latitude}';
      long = '${position.longitude}';
      locationMessage = "Latitude: $lat, Longitude: $long";
    });
  }

  void _startLiveLocation() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
        if (!mounted) return;

        String newLat = position.latitude.toString();
        String newLong = position.longitude.toString();

        setState(() {
          lat = newLat;
          long = newLong;
          locationMessage = "Latitude: $lat, Longitude: $long";
        });

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .update({'lat': newLat, 'long': newLong});
        }
      },
    );
  }

  Future<bool> _getUserPageStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .get();

    return doc.data()?['isStaff'] == true;
  }

  Future<void> checkLogin(Future<bool> isStaffFuture) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid == null) return;

    final isStaff = await isStaffFuture;

    if (!mounted) return;

    if (isStaff) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StaffProfileHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    }
  }

  void _showLocationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Location Disabled"),
        content: const Text("Please turn on your location services."),
        actions: [
          TextButton(
            onPressed: () async {
              if (!mounted) return;

              Navigator.of(context, rootNavigator: true).pop();

              await Future.delayed(const Duration(milliseconds: 500));

              // Call location check after dialog is dismissed and system updates
              await _getCurrentLocation();
            },
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Dummy pages
  Widget StaffProfileHome() => Scaffold(body: Center(child: Text('Staff Profile')));
  Widget MyHomePage() => Scaffold(body: Center(child: Text('User Home Page')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: AndroidView(
                    lat: lat,
                    long: long,
                  ));
  }
}

class AndroidStaffPage extends StatefulWidget {
  String lat;
  String long;
  final bool isStaff;
  AndroidStaffPage({required this.lat, required this.long, required this.isStaff});
  @override
  State<StatefulWidget> createState() => _AndroidStaffPage(lat: lat, long: long, isStaff: isStaff);
}

class _AndroidStaffPage extends State<AndroidStaffPage> {
  String lat;
  String long;

  final bool isStaff;

  bool isValidEmail = true;
  bool isValidPassword = true;
  _AndroidStaffPage({required this.lat, required this.long, required this.isStaff});

  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      Column(
        children: [
          Center(
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -5), // Moves shadow **upward**
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: EdgeInsets.only(bottom: 10, top: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, spreadRadius: 2, blurRadius: 1),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.none, // No scaling
                              alignment: Alignment.center,
                              scale: 2, // Zoom in (smaller = more zoom)
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "CARENEST \nSTAFF SIGN IN",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,      // Semi-bold for professionalism
                              color: Colors.black87,             // Dark color for readability
                              fontFamily: 'Roboto',              // Use a clean, modern font (make sure it's added in your project)
                              letterSpacing: 0.5,
                              // Slight subtle letter spacing
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email input field
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 60,
                      child: TextField(
                        controller: Email,
                        onChanged: (value) {
                          // Check entire email string using RegExp
                          setState(() {
                            isValidEmail = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            ).hasMatch(value);
                          });
                        },
                        keyboardType: TextInputType
                            .emailAddress, // Optimizes keyboard for email input
                        decoration: InputDecoration(
                          labelText: "Email", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                              16), // Adds padding inside the TextField
                        ),
                      ),
                    ),
                  ),
                  !isValidEmail
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Password input field
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 60,
                      child: TextField(
                        controller:
                            Password, // Controller for the password input
                        obscureText: true, // Hides the input text
                        decoration: InputDecoration(
                          labelText: "Password", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                              20, 16, 16, 16), // Padding inside the TextField
                        ),
                      ),
                    ),
                  ),

                  // Forgot password link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () async {
                              String email = Email.text;
                              if (email.isNotEmpty) {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email);
                                Fluttertoast.showToast(
                                    msg:
                                        "Reset link is send to your email address");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please Enter email address");
                              }
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),

                  // Submit button
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 45,
                      width: double.infinity, // Make the container full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Border radius 10
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          String email = Email.text;
                          String password = Password.text;
                          if (email.isNotEmpty && password.isNotEmpty) {
                            try {
                              UserCredential usercredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(email: email, password: password);
                              User? user = usercredential.user;
                              DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('user').doc(user?.uid).get();
                              if (documentSnapshot.exists) {
                                var StaffData = documentSnapshot.data() as Map<String, dynamic>?;
                                if (StaffData != null && StaffData['professionOfStaff'] != null) {
                                  String? fcmToken = await FirebaseMessaging.instance.getToken();
                                  await FirebaseFirestore.instance.collection("user").doc(user?.uid).update({
                                    'lat': lat,
                                    'long': long,
                                    'token': fcmToken,
                                  });
                                  await FirebaseFirestore.instance.collection(StaffData['professionOfStaff']).doc(user?.uid).update({
                                    'lat': lat,
                                    'long': long,
                                  });
                                  if (user!.emailVerified) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StaffProfileHome(),
                                        ));
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                      toastLength: Toast.LENGTH_SHORT,
                                      msg:
                                      "Please check your mailbox to verify email",
                                    );
                                    await FirebaseAuth.instance.signOut();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Use staff account information",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                }
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              print(e);
                              Fluttertoast.showToast(
                                msg: "Invalid Data",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(
                              msg: "Fill in the blanks",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        },
                        child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),

                  // Create account link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(isStaff: isStaff,),
                                  ));
                            },
                            child: Text(
                              "Don't have an account?",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),

                  // Speed image
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            final Uri uri = Uri.parse("https://carenest.ancientcoders.in");
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              throw 'Could not launch $uri';
                            }
                          },
                          child: Image.asset(
                            "assets/images/speed.jpg",
                            fit: BoxFit.contain, // ensures it scales down while keeping proportions
                            height: 180, // optional: set a max height
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Polacy link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Privacy_Policy.html");
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                throw 'Could not launch ${"https://carenest.ancientcoders.in/Privacy_Policy.html"}';
                              }
                            },
                            child: Text(
                              "Privacy Policy, ",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                        InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Terms_Conditions.html");
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                throw 'Could not launch ${"https://carenest.ancientcoders.in/Terms_Conditions.html"}';
                              }
                            },
                            child: Text(
                              "Terms & Conditions, ",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                        InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Refund_Policy.html");
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                throw 'Could not launch ${"https://carenest.ancientcoders.in/Refund_Policy.html"}';
                              }
                            },
                            child: Text(
                              "Refund Policy",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.35),
                child: LoaderSupport.loadingAnimation.widget,
              ),
            )
          : Container(),
    ]);
  }
}

class AndroidUserPage extends StatefulWidget {
  String lat;
  String long;

  final bool isStaff;
  AndroidUserPage({required this.lat, required this.long, required this.isStaff});
  @override
  State<StatefulWidget> createState() => _AndroidUserPage(lat: lat, long: long, isStaff: isStaff);
}

class _AndroidUserPage extends State<AndroidUserPage> {
  String lat;
  String long;
  final bool isStaff;
  _AndroidUserPage({required this.lat, required this.long, required this.isStaff});
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();

  bool isPasswordcurrect = true;
  bool isEmailcurrect = true;
  bool isLoading = false;

  bool isValidEmail = true;
  bool isValidPassword = true;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      Column(
        children: [
          Center(
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -5), // Moves shadow **upward**
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: EdgeInsets.only(bottom: 10, top: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, spreadRadius: 2, blurRadius: 1),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.none, // No scaling
                              alignment: Alignment.center,
                              scale: 2, // Zoom in (smaller = more zoom)
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "CARENEST \nCUSTOMER SIGN IN",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,      // Semi-bold for professionalism
                              color: Colors.black87,             // Dark color for readability
                              fontFamily: 'Roboto',              // Use a clean, modern font (make sure it's added in your project)
                              letterSpacing: 0.5,
                              // Slight subtle letter spacing
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email Input box
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 60,
                      child: TextField(
                        controller: Email,
                        onChanged: (value) {
                          // Check entire email string using RegExp
                          setState(() {
                            isValidEmail = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            ).hasMatch(value);
                          });
                        },
                        keyboardType: TextInputType
                            .emailAddress, // Optimizes keyboard for email input
                        decoration: InputDecoration(
                          labelText: "Email", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                              16), // Adds padding inside the TextField
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                            borderSide: BorderSide(
                              color: isEmailcurrect
                                  ? Colors.grey
                                  : Colors
                                      .red, // Conditional border color based on email validity
                              width: isEmailcurrect
                                  ? 1
                                  : 1.5, // Conditional border width
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Rounded border when focused
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width:
                                    2), // Border color and width when the TextField is focused
                          ),
                        ),
                      ),
                    ),
                  ),
                  !isValidEmail
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Password input box
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 60,
                      child: TextField(
                        controller: Password,
                        obscureText: true, // Hides the password input
                        decoration: InputDecoration(
                          labelText: "Password", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isPasswordcurrect
                                  ? Colors.grey
                                  : Colors.red, // Conditional border color
                              width: isPasswordcurrect
                                  ? 1
                                  : 1.5, // Adjusted border width based on condition
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2), // Border when focused
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                              16), // Adds padding inside the TextField
                        ),
                      ),
                    ),
                  ),

                  // Forgot password buttom/link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () async {
                              String email = Email.text;
                              if (email.isNotEmpty) {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email);
                                Fluttertoast.showToast(
                                    msg:
                                        "Reset link is send to your email address");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please Enter email address");
                              }
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),

                  // Submit buttom
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 45,
                      width: double.infinity, // Make the container full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Border radius 10
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          String email = Email.text;
                          String password = Password.text;
                          if (email.isNotEmpty && password.isNotEmpty) {
                            try {
                              UserCredential userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(email: email, password: password);
                              User? user = userCredential.user;
                              if (user!.emailVerified) {
                                String? fcmToken = await FirebaseMessaging.instance.getToken();
                                await FirebaseFirestore.instance.collection("user").doc(user?.uid).update({
                                  'lat': lat,
                                  'long': long,
                                  'token': fcmToken,
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyHomePage()),
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                await FirebaseAuth.instance.signOut();
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Please Check your mailbox to verify email",
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              var CheckEmailOrPass =
                                  'The supplied auth credential is incorrect, malformed or has expired.';
                              var EmailIsWrong = 'The email address is badly formatted.';
                              if ('${e.message}' == CheckEmailOrPass) {
                                setState(() {
                                  isEmailcurrect = false;
                                  isPasswordcurrect = false;
                                });
                                Fluttertoast.showToast(msg: "Invalid Email or Password");
                              } else if ('${e.message}' == EmailIsWrong) {
                                setState(() {
                                  isLoading = false;
                                });
                                setState(() {
                                  isEmailcurrect = false;
                                  isPasswordcurrect = true;
                                });
                                Fluttertoast.showToast(msg: "Invalid Email");
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              Fluttertoast.showToast(msg: "Invalid data");
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(msg: "Invalid data");
                          }
                        },
                        child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),

                  // Create account link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(isStaff: isStaff,),
                                  ));
                            },
                            child: Text(
                              "Don't have an account?",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),

                  // Speed image
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            final Uri uri = Uri.parse("https://carenest.ancientcoders.in");
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              throw 'Could not launch $uri';
                            }
                          },
                          child: Image.asset(
                            "assets/images/speed.jpg",
                            fit: BoxFit.contain, // ensures it scales down while keeping proportions
                            height: 180, // optional: set a max height
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Polacy link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Privacy_Policy.html");
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                throw 'Could not launch ${"https://carenest.ancientcoders.in/Privacy_Policy.html"}';
                              }
                            },
                            child: Text(
                              "Privacy Policy, ",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                        InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Terms_Conditions.html");
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                throw 'Could not launch ${"https://carenest.ancientcoders.in/Terms_Conditions.html"}';
                              }
                            },
                            child: Text(
                              "Terms & Conditions, ",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                        InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Refund_Policy.html");
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                throw 'Could not launch ${"https://carenest.ancientcoders.in/Refund_Policy.html"}';
                              }
                            },
                            child: Text(
                              "Refund Policy",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.35),
                child: LoaderSupport.loadingAnimation.widget,
              ),
            )
          : Container(),
    ]);
  }
}

class AndroidView extends StatefulWidget {
  String lat;
  String long;

  AndroidView({required this.lat, required this.long});
  @override
  State<StatefulWidget> createState() => _AndroidView(lat: lat, long: long);
}

class _AndroidView extends State<AndroidView> {
  String lat;
  String long;

  bool isStaff = false;

  @override
  void initState() {
    super.initState();
    isIntroRead();
  }

  _AndroidView({required this.lat, required this.long});

  bool sawAd = false;

  int imageCount = 1;

  static Future<void> setIntroRead(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isIntroRead", value);
  }

  Future<void> isIntroRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sawAd = prefs.getBool("isIntroRead") ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    Color StaffColorTrue = Color(0xFF4C9EEB);
    Color StaffColorFalse = Color(0xFFB0BEC5);
    Color StaffColor = isStaff? StaffColorTrue : StaffColorFalse;
    Color UserColorTrue = Color(0xFF4C9EEB);
    Color UserColorFalse = Color(0xFFB0BEC5);
    Color UserColor = isStaff? UserColorFalse : UserColorTrue;

    _setUserPageStatus(isStaff ? true : false);
    UserData().isStaff = isStaff ? true : false;

    return sawAd? Stack(
      children: [
        Container(
          color: !isStaff ? Color(0xfffffcc9) : Color(0xffbef0ff),
          height: 320,
          width: double.maxFinite,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      setState(() {
                        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                          // Swiped left
                          isStaff = true;  // Swipe left → Staff (left side)
                        } else if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                          // Swiped right
                          isStaff = false; // Swipe right → User (right side)
                        }
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 1,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Animated background
                          AnimatedAlign(
                            duration: Duration(milliseconds: 300),
                            alignment: isStaff ? Alignment.centerLeft : Alignment.centerRight,
                            curve: Curves.easeInOut,
                            child: Container(
                              width: (MediaQuery.of(context).size.width * 0.8) / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isStaff = true;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    child: Text(
                                      "Staff",
                                      style: TextStyle(
                                        color: isStaff ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isStaff = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    child: Text(
                                      "User",
                                      style: TextStyle(
                                        color: !isStaff ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
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
              ),
              isStaff
                  ? AndroidStaffPage(
                      lat: lat,
                      long: long,
                isStaff: isStaff,
                    )
                  : AndroidUserPage(
                      lat: lat,
                      long: long,
                isStaff: isStaff,
                    )
            ],
          ),
        )
      ],
    ):
    Container(
      height: screenHeight,
      width: screenWidth,
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          imageCount == 1
            ?
        Container(
        height: screenHeight * 0.8,
        width: screenWidth * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome to CareNest",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.asset(
              "assets/images/logo2.png",
              height: 180,
              width: 180,
            ),
            SizedBox(height: 20),
            Text(
              "Smart Hiring for Daily Needs",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.blueGrey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              "CareNest connects you with trusted, verified staff for short-term jobs like nursing, driving, cooking, and more.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
              children: [
                imageCount == 1?
                    Container()
                    : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setState(() {
                        imageCount--;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Prev", style: TextStyle(color: Colors.white),),
                ),
                imageCount == 7
                    ? ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Finish", style: TextStyle(color: Colors.white),),
                )
                    : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      imageCount++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Next", style: TextStyle(color: Colors.black),),
                  ),
                ),
              ],
            )
          ],
        ),
      )
        : imageCount == 2
              ? Container(
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Live Staff Around You",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/liveLocation.jpg",
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Find Help Nearby in Real-Time",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Instantly view available staff near you on the map—filtered by profession and rating.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    imageCount == 1?
                    Container()
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            imageCount--;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Prev", style: TextStyle(color: Colors.black),),
                    ),
                    imageCount == 7
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finish", style: TextStyle(color: Colors.black),),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageCount++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Next", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
              : imageCount == 3
                ? Container(
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Quick Hiring Process",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/hire.jpg",
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Easy Booking, Your Way",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Choose who you need, when, and for how long. Fill a short form and get connected fast.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    imageCount == 1?
                    Container()
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            imageCount--;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Prev", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    imageCount == 7
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finish", style: TextStyle(color: Colors.black),),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageCount++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Next", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
              : imageCount == 4
                  ? Container(
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Verified & Trusted Professionals",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/kyc.jpg",
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Only KYC-Verified Staff",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Every staff member completes a strict KYC process for safety and trust.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    imageCount == 1?
                    Container()
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            imageCount--;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Prev", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    imageCount == 7
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finish", style: TextStyle(color: Colors.black),),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageCount++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Next", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
              : imageCount == 5
                    ? Container(
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "For Staff: Get Started with KYC",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/staffVerification.jpg",
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Join as Staff – It's Simple!",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Register your profession, complete your KYC, and get listed on the platform.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    imageCount == 1?
                    Container()
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            imageCount--;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Prev", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    imageCount == 7
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finish", style: TextStyle(color: Colors.black),),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageCount++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Next", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
              : imageCount == 6
                      ? Container(
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Go Online When You're Free",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/onoff.png",
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Flexible Working, Your Control",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "You control your availability—go online when you're ready to work, offline when you're not.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    imageCount == 1?
                    Container()
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            imageCount--;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Prev", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    imageCount == 7
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {

                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finish", style: TextStyle(color: Colors.white),),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageCount++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Next", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
              : Container(
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Get Job Requests in Real Time",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/notification.jpg",
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Earn Instantly, Get Hired Fast",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Get notified when users need your service. Accept jobs, start earning.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: imageCount == 1? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    imageCount == 1?
                    Container()
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            imageCount--;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Prev", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    imageCount == 7
                        ? ElevatedButton(
                      onPressed: () {
                          setIntroRead(true);
                          setState(() {
                            sawAd = true;
                          });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finish", style: TextStyle(color: Colors.black),),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageCount++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Next", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
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
    path.lineTo(size.width, 0); // Top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
