import 'dart:async';

import 'package:carehub/RegisterPage.dart';
import 'package:carehub/StaffPage.dart';
import 'package:carehub/StaffProfileHome.dart';
import 'package:carehub/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

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
  bool LoaderCheck = false;
  String LoadingText = 'Getting to you';

  late LocationPermission permission;
  List<String> loadingMessages = [
    'Getting things ready...',
    'Hang tight, almost there...',
    'Just a moment...',
    'Loading your personalized experience...',
    'Setting things up for you...',
    'Making sure everything is perfect...',
  ];

  Timer? timer;
  int index = 0;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
        LoadingText = loadingMessages[index];
        index = (index + 1) % loadingMessages.length;
      });
    });
    Getpermission();
    _getCurrentLocation();
    void _liveLocation() {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          setState(() async {
            lat = position.latitude.toString();
            long = position.longitude.toString();
            User? user = await FirebaseAuth.instance.currentUser;

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

    LoaderCheck = !LoaderCheck;
    bool staffStatus = UserData().isStaff;
    checkLogin(staffStatus);
  }

  Future<void> checkLogin(isStaff) async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user?.uid != null) {
      if (isStaff) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StaffProfileHome(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ));
      }
    }
  }

  void _liveLocation() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        setState(() async {
          lat = position.latitude.toString();
          long = position.longitude.toString();
          User? user = await FirebaseAuth.instance.currentUser;

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

  Future<void> Getpermission() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permission required';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Location permissions are permanently denied, we cannot request.";
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        throw "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          throw "Location permissions are denied.";
        });
        return;
      }
    }

    void _liveLocation() {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          setState(() {
            lat = position.latitude.toString();
            long = position.longitude.toString();
            locationMessage = "Latitude: $lat, Longitude: $long";
          });
        },
      );
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        throw "Location permissions are permanently denied, we cannot request.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = '${position.latitude}';
      long = '${position.longitude}';
      locationMessage = "Latitude: $lat, Longitude: $long";
      LoaderCheck = !LoaderCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    final isWeb = screenWidth > 700;

    return Scaffold(
        backgroundColor: Colors.white,
        body: LoaderCheck
            ? Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      LoadingText,
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ))
            : isWeb
                ? WebView()
                : AndroidView(
                    lat: lat,
                    long: long,
                  ));
  }
}

class AndroidStaffPage extends StatefulWidget {
  String lat;
  String long;
  AndroidStaffPage({required this.lat, required this.long});
  @override
  State<StatefulWidget> createState() =>
      _AndroidStaffPage(lat: lat, long: long);
}

class _AndroidStaffPage extends State<AndroidStaffPage> {
  String lat;
  String long;
  _AndroidStaffPage({required this.lat, required this.long});

  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: [
      Column(
        children: [
          Container(
            height: 80,
            width: 80,
            margin: EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(80),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, spreadRadius: 2, blurRadius: 1),
              ],
              image: DecorationImage(
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.cover, // Adjust the fit if necessary
              ),
            ),
          ),
          Center(
            child: Container(
              height: 400,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "Staft Login",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 30),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Email, // Controller for the email input
                        keyboardType: TextInputType
                            .emailAddress, // Optimizes keyboard for email input
                        decoration: InputDecoration(
                          labelText: "Email", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(50), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                              16), // Adds padding inside the TextField
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller:
                            Password, // Controller for the password input
                        obscureText: true, // Hides the input text
                        decoration: InputDecoration(
                          labelText: "Password", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(50), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                              20, 16, 16, 16), // Padding inside the TextField
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 5, left: 50),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ElevatedButton(
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
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                              User? user = usercredential.user;
                              DocumentSnapshot documentSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(user?.uid)
                                      .get();
                              if (documentSnapshot.exists) {
                                var StaffData = documentSnapshot.data()
                                    as Map<String, dynamic>?;
                                if (StaffData != null &&
                                    StaffData['professionOfStaff'] != null) {
                                  await FirebaseFirestore.instance
                                      .collection("user")
                                      .doc(user?.uid)
                                      .update({
                                    'lat': lat,
                                    'long': long,
                                  });
                                  await FirebaseFirestore.instance
                                      .collection(
                                          StaffData['professionOfStaff'])
                                      .doc(user?.uid)
                                      .update({
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
                              Fluttertoast.showToast(
                                msg: "$e",
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
                        child: Text("Submit")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ));
                        },
                        child: Text(
                          "Dont have an account",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        )),
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
                child: CircularProgressIndicator(),
              ),
            )
          : Container(),
    ]);
  }
}

class AndroidUserPage extends StatefulWidget {
  String lat;
  String long;

  AndroidUserPage({required this.lat, required this.long});
  @override
  State<StatefulWidget> createState() => _AndroidUserPage(lat: lat, long: long);
}

class _AndroidUserPage extends State<AndroidUserPage> {
  String lat;
  String long;

  _AndroidUserPage({required this.lat, required this.long});
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();

  bool isPasswordcurrect = true;
  bool isEmailcurrect = true;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: [
      Column(
        children: [
          Container(
            height: 80,
            width: 80,
            margin: EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(80),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, spreadRadius: 2, blurRadius: 1),
              ],
              image: DecorationImage(
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.cover, // Adjust the fit if necessary
              ),
            ),
          ),
          Center(
            child: Container(
              height: 400,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "User Login",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 30),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Email, // Controller for the email input
                        keyboardType: TextInputType
                            .emailAddress, // Optimizes keyboard for email input
                        decoration: InputDecoration(
                          labelText: "Email", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(50), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                              16), // Adds padding inside the TextField
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(50), // Rounded border
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
                                50), // Rounded border when focused
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width:
                                    2), // Border color and width when the TextField is focused
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Password,
                        obscureText: true, // Hides the password input
                        decoration: InputDecoration(
                          labelText: "Password", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
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
                            borderRadius: BorderRadius.circular(50),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 5, left: 50),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          String email = Email.text;
                          String password = Password.text;
                          if (email.isNotEmpty && password.isNotEmpty) {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                              User? user = userCredential.user;
                              if (user!.emailVerified) {
                                await FirebaseFirestore.instance
                                    .collection("user")
                                    .doc(user?.uid)
                                    .update({
                                  'lat': lat,
                                  'long': long,
                                });
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyHomePage(),
                                    ));
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
                                    msg:
                                        "Please Check your mailbox to verify email");
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              var CheckEmailOrPass =
                                  'The supplied auth credential is incorrect, malformed or has expired.';
                              var EmailIsWrong =
                                  'The email address is badly formatted.';
                              if ('${e.message}' == CheckEmailOrPass) {
                                setState(() {
                                  isEmailcurrect = false;
                                  isPasswordcurrect = false;
                                });
                                Fluttertoast.showToast(
                                    msg: "Invalid Email or Password");
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
                        child: Text("Submit")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ));
                        },
                        child: Text(
                          "Dont have an account",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        )),
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
                child: CircularProgressIndicator(),
              ),
            )
          : Container(),
    ]);
  }
}

class WebStaffPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WebStaffPage();
}

class _WebStaffPage extends State<WebStaffPage> {
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
          ]),
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
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ]),
                    ),
                  ),

                  // Email Forgot
                  Container(
                    height: 20,
                    width: ((screenWidth * 0.65) * 0.38) * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 2,
                              blurRadius: 1)
                        ]),
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
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ]),
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
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 2,
                                  blurRadius: 1)
                            ]),
                      ),
                      Container(
                        height: 20,
                        width: ((screenWidth * 0.65) * 0.38) * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 2,
                                  blurRadius: 1)
                            ]),
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
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 2,
                                    blurRadius: 1)
                              ]),
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

class WebUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WebUserPage();
}

class _WebUserPage extends State<WebUserPage> {
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;
    return Center(
      child: Container(
        height: screenHeight * 0.50,
        width: screenWidth * 0.65,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)
            ]),
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
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 2,
                                  blurRadius: 1)
                            ]),
                      ),
                    ),

                    // Email Forgot
                    Container(
                      height: 20,
                      width: ((screenWidth * 0.65) * 0.38) * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ]),
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
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 2,
                                  blurRadius: 1)
                            ]),
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
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 2,
                                    blurRadius: 1)
                              ]),
                        ),
                        Container(
                          height: 20,
                          width: ((screenWidth * 0.65) * 0.38) * 0.3,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 2,
                                    blurRadius: 1)
                              ]),
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
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 2,
                                      blurRadius: 1)
                                ]),
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
      ),
    );
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

  _AndroidView({required this.lat, required this.long});

  Color StaffColorTrue = Color(0xffbef0ff);
  Color StaffColorFalse = Colors.white;
  bool StaffPressed = false;
  Color StaffColor = Colors.white;
  Color UserColorTrue = Color(0xfffffcc9);
  Color UserColorFalse = Colors.white;
  bool UserPressed = true;
  Color UserColor = Color(0xfffffcc9);
  @override
  Widget build(BuildContext context) {
    UserData().isStaff = StaffPressed ? true : false;

    return Stack(
      children: [
        Container(
          color: UserPressed ? Color(0xfffffcc9) : Color(0xffbef0ff),
          height: 320,
          width: double.maxFinite,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ]),
                      child: Row(
                        children: [
                          // Staff
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  StaffPressed = true;
                                  if (StaffPressed) {
                                    StaffColor = StaffColorTrue;
                                    UserColor = UserColorFalse;
                                    UserPressed = false;
                                  } else {
                                    StaffColor = StaffColorFalse;
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: StaffColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          bottomRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(50),
                                          topRight: Radius.circular(0)))),
                              child: Text(
                                "Staff",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),

                          // User
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  UserPressed = true;
                                  if (UserPressed) {
                                    StaffColor = StaffColorFalse;
                                    UserColor = UserColorTrue;
                                    StaffPressed = false;
                                  } else {
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
                                          topRight: Radius.circular(50)))),
                              child: Text(
                                "User",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StaffPressed
                  ? AndroidStaffPage(
                      lat: lat,
                      long: long,
                    )
                  : AndroidUserPage(
                      lat: lat,
                      long: long,
                    )
            ],
          ),
        )
      ],
    );
  }
}

class WebView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WebView();
}

class _WebView extends State<WebView> {
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
            width: screenWidth, // Adjust the height accordingly
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
                            BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ]),
                      child: Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  StaffPressed = true;
                                  if (StaffPressed) {
                                    StaffColor = StaffColorTrue;
                                    UserColor = UserColorFalse;
                                    UserPressed = false;
                                  } else {
                                    StaffColor = StaffColorFalse;
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: StaffColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          bottomRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(50),
                                          topRight: Radius.circular(0))),
                                  minimumSize: Size(100, 50)),
                              child: Text(
                                "Staff",
                                style: TextStyle(
                                    color: Color(0xff013220),
                                    fontWeight: FontWeight.bold),
                              )),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  UserPressed = true;
                                  if (UserPressed) {
                                    StaffColor = StaffColorFalse;
                                    UserColor = UserColorTrue;
                                    StaffPressed = false;
                                  } else {
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
                                          topRight: Radius.circular(50))),
                                  minimumSize: Size(100, 50)),
                              child: Text(
                                "User",
                                style: TextStyle(
                                    color: Color(0xff8B0000),
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StaffPressed ? WebStaffPage() : WebUserPage()
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
    path.lineTo(size.width, 0); // Top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
