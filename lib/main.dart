import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:carehub/Admin.dart';
import 'package:carehub/Deals.dart';
import 'package:carehub/PrivacyPolicy.dart';
import 'package:carehub/StaffPage.dart';
import 'package:carehub/Feedback.dart';
import 'package:carehub/services/NotificationService.dart';
import 'package:carehub/services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ClientNotificationPage.dart';
import 'ContactUs.dart';
import 'LoaderSupport.dart';
import 'MainMap.dart';
import 'StaffProfilePage.dart';
import 'TC.dart';
import 'api/firebase_api.dart';
import 'client.dart';
import 'firebase_options.dart';
import 'LoginPage.dart';
import 'globle.dart';

@pragma('vm:entry-point')
Future<void> _firebasebackgroundhandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundhandler);
  runApp(const MyApp());
}

Future<void> checkInternet(BuildContext context) async {
  final hasInternet = await InternetConnection().hasInternetAccess;
  if (!hasInternet) {
    showNoInternetDialog(context);
  }
}

void showNoInternetDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("No Internet Connection"),
      content: const Text("Please turn on your internet to use the app."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            checkInternet(context); // Retry
          },
          child: const Text("Retry"),
        ),
      ],
    ),
  );
}

void showLocationDialog(BuildContext context, {required bool permissionDeniedForever}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Location Required"),
      content: Text(permissionDeniedForever
          ? "Location permission is permanently denied. Please enable it from settings."
          : "Location is disabled or denied. Please allow access to continue."),
      actions: [
        if (!permissionDeniedForever)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry permission check
              Geolocator.requestPermission();
            },
            child: const Text("Retry"),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            AppSettings.openAppSettings(); // opens location permission settings
          },
          child: const Text("Open Settings"),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _getAgreementStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("IsAgree") ?? false; // Default to false if null
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _getAgreementStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                  child:
                      CircularProgressIndicator()), // Loading while fetching data
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Error loading data!")),
            );
          }

          checkInternet(context);

          return const LoginPage();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String SearchGlobal = '';
  NotificationService notificationService = NotificationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _liveLocation();
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    _checkAndUpdate();
    FcmService.FirebaseInit();
    SearchStaff();
    updateToken();
  }

  void _showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }
  Future<void> _checkAndUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate(); // completes silently
      }
    } catch (e) {
      if (e.toString() ==
          'PlatformException(TASK_FAILURE, -10: Install Error(-10): The app is not owned by any user on this device. An app is "owned" if it has been acquired from Play. (https://developer.android.com/reference/com/google/android/play/core/install/model/InstallErrorCode#ERROR_APP_NOT_OWNED), null, null)'){
        _showSnack('Update failed: Testing Version');
      }
      else {
        _showSnack('Update failed : Unknown Error');
      }
    }
  }
  void updateToken() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return; // Always check for null

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance
          .collection("user")
          .doc(user.uid)
          .update({
        'token': newToken,
      })
          .then((_) => print("✅ Token updated successfully"))
          .catchError((e) => print("❌ Failed to update token: $e"));
    });
  }



  Future<void> _liveLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showLocationDialog(context, permissionDeniedForever: false);
        return;
      }

      // Check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            showLocationDialog(context, permissionDeniedForever: false);
            return;
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showLocationDialog(context, permissionDeniedForever: true);
        return;
      }

      // Fetch position quickly
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final String lat = position.latitude.toStringAsFixed(6);
      final String long = position.longitude.toStringAsFixed(6);
      final double latA = position.latitude;
      final double longA = position.longitude;

      await getCurrentLocationName(latA, longA);

      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('user').doc(user.uid);

      DocumentSnapshot snapshot = await userDoc.get();
      String? oldLat = snapshot['lat'];
      String? oldLong = snapshot['long'];

      if (oldLat != lat || oldLong != long) {
        await userDoc.update({
          'lat': lat,
          'long': long,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
    }
  }


  List<String>  CreativeWellness = [
    "Fitness Trainer",
    "Yoga Trainer",
    "Photographer",
  ];
  List<String>  CreativeWellnessDesc = [
    "🏃‍♂️Stay Fit, Stay Happy",
    "🧘‍♀️Find Your Inner Peace",
    "📸 Moments Made Timeless",
  ];
  List<String>  CreativeWellnessImg = [
    "gym.jpg",
    "yoga.jpg",
    "photographer.avif",
  ];

  List<String> SkilledTechnical = [
    "AC Technician",
    "Electrician",
    "Plumber",
    "Carpenter",
    "Painter",
  ];
  List<String> SkilledTechnicalDesc = [
    "❄ Cool Air, Just a Tap",
    "⚡ Light Up Your Space",
    "💧 Flow Fixed, Peace Restored",
    "🪵 Built with Heart",
    "🎨 Walls that Speak",
  ];
  List<String> SkilledTechnicalImg = [
    "repairing-air-conditioner.avif",
    "electrician.avif",
    "Plumber.avif",
    "Carpenter.jpg",
    "Painter.avif",
  ];

  List<String> MedicalHealthcare = [
    "Certified Nursing Assistants",
    "Home Health Aides",
    "Physiotherapists",
  ];
  List<String> MedicalHealthcareDesc = [
    "👩‍⚕️ Gentle Hands, Big Heart",
    "🏡 Care That Comes Home",
    "💪 Move. Heal. Live.",
  ];
  List<String> MedicalHealthcareImg = [
    "CNACopy.png",
    "aidesCopy.png",
    "PhysiotherepistCopy.png",
  ];

  List<String> CookingHospitality = [
    "Chef",
    "Event Helpers",
    "Bartender",
  ];
  List<String> CookingHospitalityDesc = [
    "🍽️ Crafted With Flavor",
    "🎉 Every Detail Matters",
    "🍸 Poured to Perfection",
  ];
  List<String> CookingHospitalityImg = [
    "chefCopy.png",
    "Event Helpers.jpeg",
    "Bartender.avif",
  ];

  List<String> SecuritySupport = [
    "Driver",
    "Home Guards",
    "Security Guards",
  ];
  List<String> SecuritySupportDesc = [
    "🚗 Safe Ride, Every Time",
    "🏠 Watchful, Always There",
    "🛡️ Your Safety, Our Duty",
  ];
  List<String> SecuritySupportImg = [
    "driverCopy.png",
    "house gaurdCopy.jpeg",
    "securitygaurdCopy.jpeg",
  ];

  List<String> ChildcareEducation = [
    "Babysitters",
    "Teacher",
  ];
  List<String> ChildcareEducationDesc = [
    "👶 Gentle Hands, Big Heart",
    "🎓 Inspire. Learn. Shine.",
  ];
  List<String> ChildcareEducationImg = [
    "babysitter.jpeg",
    "Teacher.avif",
  ];

  List<String> ElderlyPersonalCare = [
    "Personal Care Assistants",
    "Elder Companions",
    "Elderly",
  ];
  List<String> ElderlyPersonalCareDesc = [
    "🤝 Dignity in Every Touch",
    "	🕊️ Kindness by Their Side",
    "👵 Care with True Respect",
  ];
  List<String> ElderlyPersonalCareImg = [
    "Personal Care AssistanceCopy.png",
    "elderly individualSecondCopy.png",
    "ederlyCopy.png",
  ];

  List<String> HomeServices = [
    "Cleaner",
    "Gardener",
    "Housekeepers",
  ];
  List<String> HomeServicesDesc = [
    "🧼 Fresh Spaces, Always",
    "🌿 Beauty Grows Here",
    "🏠 Your Home, Cared For",
  ];
  List<String> HomeServicesImg = [
    "housekeeperSecondCopy.png",
    "Gardener.avif",
    "house keeper.jpeg",
  ];

  var StaffData;
  var documentID;
  late String currentUserID;

  Future<void> SearchStaff() async {
    User? user1 = FirebaseAuth.instance.currentUser;
    currentUserID = user1?.uid ?? '';
    CollectionReference user = FirebaseFirestore.instance.collection('user');
    try {
      DocumentSnapshot documentSnapshot = await user.doc(currentUserID).get();

      if (documentSnapshot.exists) {
        setState(() {
          StaffData = documentSnapshot.data();
          documentID = documentSnapshot.id;
        });
        double lat = double.tryParse(StaffData["lat"].toString()) ?? 0.0;
        double long = double.tryParse(StaffData["long"].toString()) ?? 0.0;
        await getCurrentLocationName(lat, long);
      }
    } catch (e) {
    }
  }

  Future<void> getCurrentLocationName(double lat, double long) async {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        String place = "${placemarks.first.locality}";
        setState(() {
          CurrentLocation = "CareNest \nin $place";
        });
      }
  }
  String CurrentLocation = "Loading...";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: screenWidth * 0.7,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    color: Globle.theme
                ),
                child: Column(children: [
                  (StaffData != null && StaffData['professionOfStaff'] != null)
                      ? InkWell(
                          onTap: () {

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => StaffProfilePage(
                                    StaffID: currentUserID,
                                    Skill: StaffData['professionOfStaff'] ??
                                        'user'),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0); // From bottom
                                  const end = Offset.zero;
                                  const curve = Curves.easeOut;

                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  final offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
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
                              image: DecorationImage(
                                image: NetworkImage(StaffData['Profile_Pic']),
                                fit:
                                    BoxFit.cover, // Adjust the fit if necessary
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => const ActualUser(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0); // From bottom
                                  const end = Offset.zero;
                                  const curve = Curves.easeOut;

                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  final offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: StaffData != null &&
                                  StaffData['Profile_Pic'] != null
                              ? Container(
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
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          StaffData['Profile_Pic']),
                                      fit: BoxFit
                                          .cover, // Adjust the fit if necessary
                                    ),
                                  ),
                                )
                              : Container(
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
                                  ),
                                  child: const Icon(CupertinoIcons.profile_circled))),
                  (StaffData == null)
                      ? const Text(
                          "Empty",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : Text(
                          "${StaffData['First_name']} ${StaffData['Last_name']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                ])),
            InkWell(
              onLongPress: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const AdminLogin(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // From bottom
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        final offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Deals'),
              onTap: () {

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const Deals(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);// From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Contact Us'),
              onTap: () {

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const ContactUs(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              onLongPress: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => PrivacyPolicy(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Terms and Conditions'),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => TC(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const Feedbacks(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Globle.theme,
            child: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 35
              ),
              title: Column(
                children: [
                  const SizedBox(height: 10,),
                  Text(
                    CurrentLocation,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Standard clickable link color
                    ),
                  ),
                ],
              ),
              backgroundColor: Globle.theme,
              automaticallyImplyLeading: true,
            ),
          ),

          // Profile photo
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (StaffData != null && StaffData['professionOfStaff'] != null)
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (context, animation, secondaryAnimation) => StaffProfilePage(
                                  StaffID: currentUserID,
                                  Skill: StaffData['professionOfStaff'] ??
                                      'user'),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOut;

                                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(StaffData['Profile_Pic']),
                              fit: BoxFit.cover, // Adjust the fit if necessary
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (context, animation, secondaryAnimation) => const ActualUser(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOut;

                                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            image: StaffData != null &&
                                    StaffData['Profile_Pic'] != null
                                ? DecorationImage(
                                    image:
                                        NetworkImage(StaffData['Profile_Pic']),
                                    fit: BoxFit
                                        .cover, // Adjust the fit if necessary
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),

          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 125),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, left: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
                                          SearchGlobal = value;
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
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recommendations
                            false
                                ? Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Recommendations", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            )
                                : Container(),
                            false
                                ?Padding(
                              padding: const EdgeInsets.only(left: 13.0, right: 8, bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(width: 1, color: Colors.black)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text("Chef", style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                    ),
                                  )
                                ],
                              ),
                            )
                                : Container(),

                            // Trending
                            false
                                ? Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("More Requested", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            )
                                : Container(),
                            false
                                ? Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: HomeServices.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => StaffPage(
                                                      Skill: HomeServices[index]
                                                          .toLowerCase()),
                                                ));
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${HomeServicesImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(HomeServices[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(HomeServicesDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                                : Container(),

                            // Home Services
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Home Services", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: HomeServices.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) => StaffPage(
                                                    Skill: HomeServices[index].toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0);
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${HomeServicesImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(HomeServices[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(HomeServicesDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Childcare & Education
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Childcare & Education", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: ChildcareEducation.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) => StaffPage(
                                                    Skill: ChildcareEducation[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${ChildcareEducationImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(ChildcareEducation[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(ChildcareEducationDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Elderly & Personal Care
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Elderly & Personal Care", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: ElderlyPersonalCare.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) => StaffPage(
                                                    Skill: ElderlyPersonalCare[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${ElderlyPersonalCareImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(ElderlyPersonalCare[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(ElderlyPersonalCareDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Cooking & Hospitality
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Cooking & Hospitality", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: CookingHospitality.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) =>StaffPage(
                                                    Skill: CookingHospitality[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${CookingHospitalityImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(CookingHospitality[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(CookingHospitalityDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Medical & Healthcare
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Medical & Healthcare", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: MedicalHealthcare.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) =>StaffPage(
                                                    Skill: MedicalHealthcare[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${MedicalHealthcareImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(MedicalHealthcare[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(MedicalHealthcareDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Skilled & Technical
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Skilled & Technical", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: SkilledTechnical.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {

                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) =>StaffPage(
                                                    Skill: SkilledTechnical[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${SkilledTechnicalImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(SkilledTechnical[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(SkilledTechnicalDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Security & Support
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Security & Support", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: SecuritySupport.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) => StaffPage(
                                                    Skill: SecuritySupport[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${SecuritySupportImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(SecuritySupport[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(SecuritySupportDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Creative & Wellness
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0, top: 10),
                              child: Text("Creative & Wellness", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                              child: SizedBox(
                                height: 205,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: CreativeWellness.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: const Duration(milliseconds: 500),
                                                pageBuilder: (context, animation, secondaryAnimation) => StaffPage(
                                                    Skill: CreativeWellness[index]
                                                        .toLowerCase()),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0); // From bottom
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeOut;

                                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  final offsetAnimation = animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            height: 220,
                                            width: screenWidth * 0.7,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage("assets/Professions/${CreativeWellnessImg[index]}"),
                                                      fit: BoxFit.cover, // Adjust the fit if necessary
                                                    ),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 1,
                                                          spreadRadius: 1),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(CreativeWellness[index], style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),),
                                                const SizedBox(height: 2,),
                                                Text(CreativeWellnessDesc[index], style: GoogleFonts.roboto(fontSize: 16),),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Professions
                            // Expanded(
                            //   child: ListView.builder(
                            //     padding: EdgeInsets.zero,
                            //     itemCount: Profession.length,
                            //     itemBuilder: (context, index) {
                            //       return Padding(
                            //         padding: const EdgeInsets.all(10.0),
                            //         child: InkWell(
                            //           onTap: () {
                            //             Navigator.push(
                            //                 context,
                            //                 MaterialPageRoute(
                            //                   builder: (context) => StaffPage(
                            //                       Skill: Profession[index]
                            //                           .toLowerCase()),
                            //                 ));
                            //           },
                            //           child: Container(
                            //             height: 150,
                            //             width: screenWidth,
                            //             decoration: BoxDecoration(
                            //               image: DecorationImage(
                            //                 image: AssetImage("assets/Professions/${ProfessionBack[index]}"),
                            //                 fit: BoxFit.cover, // Adjust the fit if necessary
                            //               ),
                            //               color: Colors.white,
                            //               borderRadius: BorderRadius.circular(15),
                            //               boxShadow: [
                            //                 BoxShadow(
                            //                     color: Colors.black26,
                            //                     blurRadius: 1,
                            //                     spreadRadius: 1),
                            //               ],
                            //             ),
                            //             child: Padding(
                            //               padding: const EdgeInsets.all(10.0),
                            //               child: Text(Profession[index],
                            //                   style: TextStyle(
                            //                       fontSize: 18,
                            //                       color: Colors.white,
                            //                       fontWeight: FontWeight.bold,
                            //                       shadows: [
                            //                         Shadow(
                            //                             blurRadius: 1,
                            //                             color: Colors.black,
                            //                             offset: Offset(1, 1))
                            //                       ])),
                            //             ),
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // Search result
              SearchGlobal.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 180,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: screenHeight * 0.5,
                              width: screenWidth - 16,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 2)
                                  ]),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('user')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: LoaderSupport.loadingAnimation.widget,
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text("No Users Found"),
                                    );
                                  }

                                  if (SearchGlobal.isEmpty) {
                                    return const Center(child: Text("Empty"));
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index]
                                          .data() as Map<String, dynamic>;
                                      var UID = snapshot.data!.docs[index].id;
                                      DateTime now = DateTime.now();

                                      if(data.containsKey("expire") && (data["expire"] as Timestamp).toDate().isAfter(now)){
                                        if (data['professionOfStaff'] != null &&
                                            data["Verified"] == "verified" &&
                                            data['First_name'] != null &&
                                            data['First_name'].toString()
                                                .toLowerCase()
                                                .startsWith(
                                                SearchGlobal.toLowerCase())) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    transitionDuration: const Duration(milliseconds: 500),
                                                    pageBuilder: (context, animation, secondaryAnimation) => StaffProfilePage(
                                                        StaffID: UID,
                                                        Skill: data[
                                                        'professionOfStaff']),
                                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                      const begin = Offset(1.0, 0.0); // From bottom
                                                      const end = Offset.zero;
                                                      const curve = Curves.easeOut;

                                                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                      final offsetAnimation = animation.drive(tween);

                                                      return SlideTransition(
                                                        position: offsetAnimation,
                                                        child: child,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(5),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          spreadRadius: 1,
                                                          blurRadius: 1)
                                                    ]),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(40),
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    data[
                                                                    'Profile_Pic']),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: SizedBox(
                                                          width: 150,
                                                          child: Text(
                                                            "${data['First_name']} ${data['Last_name']}",
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        data['City'][0]
                                                            .toUpperCase() +
                                                            data['City']
                                                                .substring(1),
                                                        style: const TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        else
                                        if (data['professionOfStaff'] != null &&
                                            data["Verified"] == "verified" &&
                                            data['First_name'] != null &&
                                            data['City'].toString()
                                                .toLowerCase()
                                                .startsWith(
                                                SearchGlobal.toLowerCase())) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    transitionDuration: const Duration(milliseconds: 500),
                                                    pageBuilder: (context, animation, secondaryAnimation) => StaffProfilePage(
                                                        StaffID: UID,
                                                        Skill: data[
                                                        'professionOfStaff']),
                                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                      const begin = Offset(1.0, 0.0); // From bottom
                                                      const end = Offset.zero;
                                                      const curve = Curves.easeOut;

                                                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                      final offsetAnimation = animation.drive(tween);

                                                      return SlideTransition(
                                                        position: offsetAnimation,
                                                        child: child,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(15),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          spreadRadius: 1,
                                                          blurRadius: 1)
                                                    ]),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(40),
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    data[
                                                                    'Profile_Pic']),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: SizedBox(
                                                          width: 150,
                                                          child: Text(
                                                            "${data['First_name']} ${data['Last_name']}",
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        data['City'][0]
                                                            .toUpperCase() +
                                                            data['City']
                                                                .substring(1),
                                                        style: const TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      return Container();
                                    },
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
            ],
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home, color: Colors.blueAccent, size: 28),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const MainMap(whichStaff: "All"),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map, color: Colors.green, size: 28),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const ClientNotificationPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications, color: Colors.purple, size: 28),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
