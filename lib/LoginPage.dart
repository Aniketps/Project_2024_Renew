import 'dart:async';

import 'package:carehub/LoaderSupport.dart';
import 'package:carehub/RegisterPage.dart';
import 'package:carehub/StaffProfileHome.dart';
import 'package:carehub/main.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'StaffDetailInputPage.dart';
import 'globle.dart';

Future<bool> _setUserPageStatus(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool("Staff", value);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
    await checkLogin(_getUserPageStatus());
    await _getPermission();
    await _getCurrentLocation();
    _startLiveLocation();
  }

  bool isLoading = true;

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
      await Future.delayed(const Duration(seconds: 1));
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
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.lowest,
      ),
    );

    if (!mounted) return;
    setState(() {
      lat = '${position.latitude}';
      long = '${position.longitude}';
      locationMessage = "Latitude: $lat, Longitude: $long";
    });
  }

  void _startLiveLocation() {
    const locationSettings = LocationSettings(
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("Staff")?? false;

  }

  Future<void> checkLogin(Future<bool> isStaffFuture) async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    bool isStaff = await isStaffFuture;

    if (!mounted) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (isStaff) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffProfileHome()),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showLocationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Location Disabled".trKey),
        content: Text("Please turn on your location services.".trKey),
        actions: [
          TextButton(
            onPressed: () async {
              if (!mounted) return;

              Navigator.of(context, rootNavigator: true).pop();

              await Future.delayed(const Duration(milliseconds: 500));

              // Call location check after dialog is dismissed and system updates
              await _getCurrentLocation();
            },
            child: Text("Try Again".trKey),
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
  AndroidStaffPage({super.key, required this.lat, required this.long, required this.isStaff});
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
  bool isEmailSignIn = false;

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
              decoration: const BoxDecoration(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10,),
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: const EdgeInsets.only(bottom: 10, top: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12, spreadRadius: 2, blurRadius: 1),
                            ],
                            image: const DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.none, // No scaling
                              alignment: Alignment.center,
                              scale: 2, // Zoom in (smaller = more zoom)
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          width: 200,
                          child: Text(
                            "CARENEST\n${"STAFF SIGN IN".trKey}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Roboto',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Google buttom
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: InkWell(
                      onTap: () async {
                        try {
                          setState(() {
                            isLoading = true;
                          });

                          // Step 1: Start the Google sign-in process
                          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                          if (googleUser == null) {
                            // User canceled the login
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          // Step 2: Get auth credentials from the signed-in user
                          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                          final credential = GoogleAuthProvider.credential(
                            accessToken: googleAuth.accessToken,
                            idToken: googleAuth.idToken,
                          );

                          String? fullName = googleUser.displayName;
                          String? firstName;
                          String? lastName;

                          if (fullName != null && fullName.contains(" ")) {
                            List<String> names = fullName.split(" ");
                            setState(() {
                              firstName = names.first;
                              lastName = names.sublist(1).join(" ");
                            });
                          }else{
                            await _setUserPageStatus(true);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AndroidStaffPageGoogle(
                                      FirstName: "Unknown",
                                      LastName: "",
                                      credential : credential
                                  ),
                                ));
                          }

                          // Step 4: Save user info to Firestore
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection("user")
                              .where("Email", isEqualTo: googleUser.email)
                              .get();

                          String fn = firstName ?? '';
                          String ln = lastName ?? '';

                          if (querySnapshot.docs.isNotEmpty) {
                            final doc = querySnapshot.docs.first;
                            final userDocRef = FirebaseFirestore.instance.collection("user").doc(doc.id);

                            if (doc.data().containsKey("professionOfStaff")) {
                              await FirebaseAuth.instance.signInWithCredential(credential);
                              String? token = await FirebaseMessaging.instance.getToken();
                              await userDocRef.update({
                                'lat': lat,
                                'long': long,
                                'token'  : token,
                              });
                              await _setUserPageStatus(true);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StaffProfileHome(),
                                ),
                              );
                            } else {
                              // Login to user side
                              await FirebaseAuth.instance.signInWithCredential(credential);
                              await _setUserPageStatus(false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHomePage(),
                                ),
                              );
                            }
                          } else {
                            // Create new user document
                            if (fn.isNotEmpty && ln.isNotEmpty) {
                              await _setUserPageStatus(true);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AndroidStaffPageGoogle(
                                    FirstName: fn,
                                    LastName: ln,
                                    credential: credential,
                                  ),
                                ),
                              );
                            }
                          }

                        } catch (e) {
                          Fluttertoast.showToast(msg: "Error during Google Sign-In".trKey);
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3), // optional: softer look
                                offset: const Offset(2, 2), // X: right, Y: bottom
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/google.png"),
                                    fit: BoxFit.cover, // No scaling
                                    alignment: Alignment.center,
                                    scale: 2, // Zoom in (smaller = more zoom)
                                  ),
                                ),
                              ),
                              const Text("Google", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),)
                            ],
                          )
                      ),
                    ),
                  ),

                  // Sign in by Email
                  isEmailSignIn
                      ? Column(
                    children: [
                      const SizedBox(height: 5,),
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            Text("OR".trKey, style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.black,),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5,),

                      // Email input field
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: SizedBox(
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
                              labelText: "Email".trKey, // Label for the TextField
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10), // Rounded border
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(20, 16, 16,
                                  16), // Adds padding inside the TextField
                            ),
                          ),
                        ),
                      ),
                      !isValidEmail
                          ? Padding(
                        padding: EdgeInsets.only(right: 30, left: 30, top: 5),
                        child: Row(
                          children: [
                            Text(
                              "Invalid Email".trKey,
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
                        child: SizedBox(
                          height: 60,
                          child: TextField(
                            controller:
                            Password, // Controller for the password input
                            obscureText: true, // Hides the input text
                            decoration: InputDecoration(
                              labelText: "Password".trKey, // Label for the TextField
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10), // Rounded border
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(
                                  20, 16, 16, 16), // Padding inside the TextField
                            ),
                          ),
                        ),
                      ),

                      // Forgot password link
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30, right: 30),
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
                                        "Reset link is send to your email address".trKey);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please Enter email address".trKey);
                                  }
                                },
                                child: Text(
                                  "Forgot password?".trKey,
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
                        child: SizedBox(
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
                                                  const StaffProfileHome(),
                                            ));
                                        setState(() {
                                          isLoading = false;
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                          toastLength: Toast.LENGTH_SHORT,
                                          msg:
                                          "Please check your mailbox to verify email".trKey,
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
                                        msg: "Use staff account information".trKey,
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
                                    msg: "Invalid Data".trKey,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                }
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                Fluttertoast.showToast(
                                  msg: "Fill in the blanks".trKey,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            },
                            child: Text("Submit".trKey, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isEmailSignIn = true;
                        });
                      },
                      child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3), // optional: softer look
                                offset: const Offset(2, 2), // X: right, Y: bottom
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Manually Enter".trKey, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 19),)
                            ],
                          )
                      ),
                    ),
                  ),

                  // Create account link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30, right : 30),
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
                              "Don't have an account?".trKey,
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

                  Center(
                    child: Text(
                      "By Sign in your agree with our".trKey,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
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
                              "Privacy Policy,".trKey,
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
                              "Terms & Conditions,".trKey,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                  Center(
                    child: InkWell(
                        onTap: () async {
                          final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Refund_Policy.html");
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            throw 'Could not launch ${"https://carenest.ancientcoders.in/Refund_Policy.html"}';
                          }
                        },
                        child: Text(
                          "Refund Policy".trKey,
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
  AndroidUserPage({super.key, required this.lat, required this.long, required this.isStaff});
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
  bool isEmailSignIn = false;
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
              decoration: const BoxDecoration(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10,),
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: const EdgeInsets.only(bottom: 10, top: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12, spreadRadius: 2, blurRadius: 1),
                            ],
                            image: const DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.none, // No scaling
                              alignment: Alignment.center,
                              scale: 2, // Zoom in (smaller = more zoom)
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Container(
                            width: 200,
                            child: Text(
                              "CARENEST \n${"CUSTOMER SIGN IN".trKey}",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,      // Semi-bold for professionalism
                                color: Colors.black87,             // Dark color for readability
                                fontFamily: 'Roboto',              // Use a clean, modern font (make sure it's added in your project)
                                letterSpacing: 0.5,
                                // Slight subtle letter spacing
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Google buttom
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: InkWell(
                      onTap: () async {
                        try {
                          setState(() {
                            isLoading = true;
                          });

                          // Step 1: Start the Google sign-in process
                          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                          if (googleUser == null) {
                            // User canceled the login
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          // Step 2: Get auth credentials from the signed-in user
                          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                          final credential = GoogleAuthProvider.credential(
                            accessToken: googleAuth.accessToken,
                            idToken: googleAuth.idToken,
                          );

                          // Step 3: Sign in to Firebase
                          final UserCredential userCredential =
                          await FirebaseAuth.instance.signInWithCredential(credential);

                          final User? user = userCredential.user;
                          String? fullName = googleUser.displayName;

                          String? firstName;
                          String? lastName;

                          if (fullName != null && fullName.contains(" ")) {
                            List<String> names = fullName.split(" ");
                            firstName = names.first;
                            lastName = names.sublist(1).join(" "); // handles middle names too
                          }else{
                            firstName = "Unknown";
                            lastName = "";
                          }
                          if (user != null) {
                            // Step 4: Save user info to Firestore
                            final userDocRef = FirebaseFirestore.instance.collection("user").doc(user.uid);
                            final docSnapshot = await userDocRef.get();
                            String? token = await FirebaseMessaging.instance.getToken();

                            if (!docSnapshot.exists) {
                              await userDocRef.set({
                                'Email': user.email,
                                'First_name': firstName,
                                'Password' : '',
                                'Last_name': lastName,
                                'lat' : lat,
                                'long' : long,
                                'token' : token
                              });
                            } else {
                              // Existing user → update only what you want (NOT name)
                              await userDocRef.update({
                                'lat' : lat,
                                'long' : long,
                                'token' : token
                              });
                            }

                            await _setUserPageStatus(false);
                            // Step 5: Navigate to home page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MyHomePage()),
                            );
                          }

                        } catch (e) {
                          Fluttertoast.showToast(msg: "Error during Google Sign-In".trKey);
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3), // optional: softer look
                                offset: const Offset(2, 2), // X: right, Y: bottom
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/google.png"),
                                    fit: BoxFit.cover, // No scaling
                                    alignment: Alignment.center,
                                    scale: 2, // Zoom in (smaller = more zoom)
                                  ),
                                ),
                              ),
                              const Text("Google", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),)
                            ],
                          )
                      ),
                    ),
                  ),

                  // Sign in by Email
                  isEmailSignIn
                      ? Column(
                    children: [
                      const SizedBox(height: 5,),
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            Text("OR".trKey, style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.black,),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5,),

                      // Email Input box
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: SizedBox(
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
                              labelText: "Email".trKey, // Label for the TextField
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10), // Rounded border
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(20, 16, 16,
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
                                borderSide: const BorderSide(
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
                              "Invalid Email".trKey,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      )
                          : Container(),

                      // Password input box
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 20),
                        child: SizedBox(
                          height: 60,
                          child: TextField(
                            controller: Password,
                            obscureText: true, // Hides the password input
                            decoration: InputDecoration(
                              labelText: "Password".trKey, // Label for the TextField
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
                                borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2), // Border when focused
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(20, 16, 16,
                                  16), // Adds padding inside the TextField
                            ),
                          ),
                        ),
                      ),

                      // Forgot password buttom/link
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30, right : 30),
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
                                        "Reset link is send to your email address".trKey);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please Enter email address".trKey);
                                  }
                                },
                                child: Text(
                                  "Forgot password?".trKey,
                                  style: const TextStyle(
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
                        child: SizedBox(
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
                                    await FirebaseFirestore.instance.collection("user").doc(user.uid).update({
                                      'lat': lat,
                                      'long': long,
                                      'token': fcmToken,
                                    });
                                    await _setUserPageStatus(false);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MyHomePage()),
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
                                      msg: "Please Check your mailbox to verify email".trKey,
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
                                    Fluttertoast.showToast(msg: "Invalid Email or Password".trKey);
                                  } else if ('${e.message}' == EmailIsWrong) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    setState(() {
                                      isEmailcurrect = false;
                                      isPasswordcurrect = true;
                                    });
                                    Fluttertoast.showToast(msg: "Invalid Email".trKey);
                                  }
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Fluttertoast.showToast(msg: "Invalid data".trKey);
                                }
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                Fluttertoast.showToast(msg: "Invalid data".trKey);
                              }
                            },
                            child: Text("Submit".trKey, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isEmailSignIn = true;
                        });
                      },
                      child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3), // optional: softer look
                                offset: const Offset(2, 2), // X: right, Y: bottom
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Manually Enter".trKey, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 19),)
                            ],
                          )
                      ),
                    ),
                  ),

                  // Create account link
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30, right : 30),
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
                              "Don't have an account?".trKey,
                              style: const TextStyle(
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

                  Center(
                    child: Text(
                      "By Sign in your agree with our".trKey,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
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
                              "Privacy Policy,".trKey,
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
                              "Terms & Conditions,".trKey,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                  Center(
                    child: InkWell(
                        onTap: () async {
                          final Uri uri = Uri.parse("https://carenest.ancientcoders.in/Refund_Policy.html");
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            throw 'Could not launch ${"https://carenest.ancientcoders.in/Refund_Policy.html"}';
                          }
                        },
                        child: Text(
                          "Refund Policy".trKey,
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

  AndroidView({super.key, required this.lat, required this.long});
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
  bool _loading = true;

  int imageCount = 1;

  static Future<void> setIntroRead(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isIntroRead", value);
  }

  Future<void> isIntroRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sawAd = prefs.getBool("isIntroRead") ?? false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .sizeOf(context)
        .width;
    double screenHeight = MediaQuery
        .sizeOf(context)
        .height;

    if (_loading) {
      return const SizedBox.shrink(); // Prevents early flicker
    }

    return Visibility(
      visible: sawAd,
      replacement: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
            color: Colors.white
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imageCount == 1
                ?
            Container(
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
                    "Welcome to CareNest".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/logo2.png",
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Smart Hiring for Daily Needs".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "CareNest connects you with trusted, verified staff for short-term jobs like nursing, driving, cooking, and more.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12,),
                  Padding(
                    padding: const EdgeInsets.only(left : 20.0, right : 20, top: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Please Choose Language")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownButtonFormField<Locale>(
                      dropdownColor: Colors.blue,
                      value: context.locale,
                      style: const TextStyle(color: Colors.black),
                      icon: const Icon(Icons.language, color: Colors.black),
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale('hi'),
                          child: Text('हिंदी'),
                        ),
                        DropdownMenuItem(
                          value: Locale('mr'),
                          child: Text('मराठी'),
                        ),
                        DropdownMenuItem(
                          value: Locale('fr'),
                          child: Text('Français'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ru'),
                          child: Text('Русский'),
                        ),
                        DropdownMenuItem(
                          value: Locale('bn'),
                          child: Text('বাংলা'),
                        ),
                        DropdownMenuItem(
                          value: Locale('pt'),
                          child: Text('Português'),
                        ),
                        DropdownMenuItem(
                          value: Locale('es'),
                          child: Text('Español'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ur'),
                          child: Text('اردو'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ja'),
                          child: Text('日本語'),
                        ),
                        DropdownMenuItem(
                          value: Locale('te'),
                          child: Text('తెలుగు'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ar'),
                          child: Text('العربية'),
                        ),
                        DropdownMenuItem(
                          value: Locale('de'),
                          child: Text('Deutsch'),
                        ),
                        DropdownMenuItem(
                          value: Locale('vi'),
                          child: Text('Tiếng Việt'),
                        ),
                        DropdownMenuItem(
                          value: Locale('id'),
                          child: Text('Bahasa Indonesia'),
                        ),
                        DropdownMenuItem(
                          value: Locale('zh'),
                          child: Text('中文'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ta'),
                          child: Text('தமிழ்'),
                        ),
                        DropdownMenuItem(
                          value: Locale('tr'),
                          child: Text('Türkçe'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ko'),
                          child: Text('한국어'),
                        ),
                        DropdownMenuItem(
                          value: Locale('it'),
                          child: Text('Italiano'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ml'),
                          child: Text('മലയാളം'),
                        ),
                        DropdownMenuItem(
                          value: Locale('th'),
                          child: Text('ไทย'),
                        ),
                        DropdownMenuItem(
                          value: Locale('pl'),
                          child: Text('Polski'),
                        ),
                      ],
                      onChanged: (Locale? locale) {
                        if (locale != null) {
                          context.setLocale(locale);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
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
                          child: Text("Next".trKey, style: const TextStyle(
                              color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : imageCount == 2
                ? Container(
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
                    "Live Staff Around You".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/liveLocation.jpg",
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Find Help Nearby in Real-Time".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Instantly view available staff near you on the map—filtered by profession and rating.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1 ?
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
                        child:  Text("Prev".trKey, style: TextStyle(
                            color: Colors.black),),
                      ),
                      ElevatedButton(
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Next".trKey,
                            style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : imageCount == 3
                ? Container(
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
                    "Quick Hiring Process".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/hire.jpg",
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Easy Booking, Your Way".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Choose who you need, when, and for how long. Fill a short form and get connected fast.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1 ?
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Prev".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                      ElevatedButton(
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Next".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : imageCount == 4
                ? Container(
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
                    "Verified & Trusted Professionals".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/kyc.jpg",
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Only KYC-Verified Staff".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Every staff member completes a strict KYC process for safety and trust.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1 ?
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
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Prev".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                      ElevatedButton(
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Next".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : imageCount == 5
                ? Container(
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
                    "For Staff: Get Started with KYC".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/staffVerification.jpg",
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Join as Staff – It's Simple!".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Register your profession, complete your KYC, and get listed on the platform.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1 ?
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Prev".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                      ElevatedButton(
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Next".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : imageCount == 6
                ? Container(
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
                    "Go Online When You're Free".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/onoff.png",
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Flexible Working, Your Control".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You control your availability—go online when you're ready to work, offline when you're not.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1 ?
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Prev".trKey, style: TextStyle(color: Colors.black),),
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Finish".trKey, style: TextStyle(color: Colors.white),),
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Next".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : imageCount == 7
                ? Container(
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
                    "Get Job Requests in Real Time".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/notification.jpg",
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Earn Instantly, Get Hired Fast".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Get notified when users need your service. Accept jobs, start earning.".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1 ?
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Prev".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                      ElevatedButton(
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
                        child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Next".trKey, style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                : Container(
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
                    "Please tell us who you are".trKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.blueGrey[700]),
                      const SizedBox(width: 8),
                      Container(
                        width: 250,
                        child: Text(
                          "Looking to hire someone?".trKey,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, color: Colors.blueGrey[700]),
                      const SizedBox(width: 8),
                      Text(
                        "Need a part-time job?".trKey,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tap the button that matches you best".trKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8.0, // gap between items horizontally
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            sawAd = true;
                            isStaff = true;
                            setIntroRead(true);
                          });
                        },
                        icon: const Icon(Icons.work, color: Colors.white),
                        label:  Text(
                          "I want to work".trKey,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          elevation: 2,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            sawAd = true;
                            isStaff = false;
                            setIntroRead(true);
                          });
                        },
                        icon: const Icon(
                            Icons.person_search, color: Colors.white),
                        label:  Text(
                          "I need help".trKey,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          elevation: 2,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: imageCount == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      imageCount == 1
                          ? Container()
                          : ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            imageCount--;
                          });
                        },
                        icon: const Icon(
                            Icons.arrow_back, color: Colors.black87),
                        label:  Text(
                          "Back".trKey,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          elevation: 0,
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
      child: Stack(
        children: [
          Container(
            color: Globle.theme,
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
                          if (details.primaryVelocity != null &&
                              details.primaryVelocity! < 0) {
                            // Swiped left
                            isStaff = true; // Swipe left → Staff (left side)
                          } else if (details.primaryVelocity != null &&
                              details.primaryVelocity! > 0) {
                            // Swiped right
                            isStaff = false; // Swipe right → User (right side)
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
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
                              duration: const Duration(milliseconds: 300),
                              alignment: isStaff
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              curve: Curves.easeInOut,
                              child: Container(
                                width: (MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.8) / 2,
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
                                        "Staff".trKey,
                                        style: TextStyle(
                                          color: isStaff ? Colors.black : Colors
                                              .black,
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
                                        "User".trKey,
                                        style: TextStyle(
                                          color: !isStaff
                                              ? Colors.black
                                              : Colors.black,
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
