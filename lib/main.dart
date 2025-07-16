import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:carehub/Deals.dart';
import 'package:carehub/PrivacyPolicy.dart';
import 'package:carehub/StaffPage.dart';
import 'package:carehub/Feedback.dart';
import 'package:carehub/services/NotificationService.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:carehub/services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'StaffProfileHome.dart';
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
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundhandler);
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('fr'),
        Locale('ru'),
        Locale('ur'),
        Locale('ar'),
        Locale('ja'),
        Locale('te'),
        Locale('ta'),
        Locale('ml'),
        Locale('de'),
        Locale('id'),
        Locale('bn'),
        Locale('tr'),
        Locale('pt'),
        Locale('es'),
        Locale('vi'),
        Locale('zh'),
        Locale('ko'),
        Locale('it'),
        Locale('pl'),
        Locale('th'),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
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
      title: Text("No Internet Connection".trKey),
      content: Text("Please turn on your internet to use the app.".trKey),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            checkInternet(context); // Retry
          },
          child: Text("Retry".trKey),
        ),
      ],
    ),
  );
}

void showLocationDialog(BuildContext context,
    {required bool permissionDeniedForever}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Location Required".trKey),
      content: Text(permissionDeniedForever
          ? "Location permission is permanently denied. Please enable it from settings.".trKey
          : "Location is disabled or denied. Please allow access to continue.".trKey),
      actions: [
        if (!permissionDeniedForever)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry permission check
              Geolocator.requestPermission();
            },
            child: Text("Retry".trKey),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            AppSettings.openAppSettings(); // opens location permission settings
          },
          child: Text("Open Settings".trKey),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _determineStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginPage(); // Not logged in

    final isStaff = prefs.getBool("Staff") ?? false;

    return isStaff ? const StaffProfileHome() : const MyHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: FutureBuilder<Widget>(
        future: _determineStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: LoaderSupport.loadingAnimation.widget),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Something went wrong".trKey)),
            );
          }

          return snapshot.data!;
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
    _startTimer();
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
          'PlatformException(TASK_FAILURE, -10: Install Error(-10): The app is not owned by any user on this device. An app is "owned" if it has been acquired from Play. (https://developer.android.com/reference/com/google/android/play/core/install/model/InstallErrorCode#ERROR_APP_NOT_OWNED), null, null)') {
        _showSnack('Update failed: Testing Version'.trKey);
      } else {
        _showSnack('Update failed : Unknown Error'.trKey);
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
          .then((_) => print("Token updated"))
          .catchError((e) => print("Failed to update token: $e"));
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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
        ),
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
    } catch (e) {}
  }

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
    } catch (e) {}
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

  String CurrentLocation = "Loading...".trKey;

  final List<Map<String, dynamic>> staffProfiles = [];

  int currentIndex = 0;
  Timer? _timer;

  void _startTimer() {
    if (staffProfiles.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
        setState(() {
          currentIndex = (currentIndex + 1) % staffProfiles.length;
        });
      });
    }
  }

  List<Map<String, bool>> isProfessionFlash = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final profile = staffProfiles.isNotEmpty ? staffProfiles[currentIndex] : {};

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
                  (StaffData != null && StaffData['professionOfStaff'] != null)
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                                pageBuilder: (context, animation,
                                        secondaryAnimation) =>
                                    StaffProfilePage(
                                        StaffID: currentUserID,
                                        Skill: StaffData['professionOfStaff'] ??
                                            'user'),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0); // From bottom
                                  const end = Offset.zero;
                                  const curve = Curves.easeOut;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  final offsetAnimation =
                                      animation.drive(tween);

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
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ActualUser(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0); // From bottom
                                  const end = Offset.zero;
                                  const curve = Curves.easeOut;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  final offsetAnimation =
                                      animation.drive(tween);

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
                                  child: const Icon(
                                      CupertinoIcons.profile_circled))),
                  (StaffData == null)
                      ? const Text(
                          "Empty",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : Text(
                          "${StaffData['First_name']} ${StaffData['Last_name']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                ])),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('Home'.trKey),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const MyHomePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
              leading: const Icon(Icons.history),
              title: Text('Deals'.trKey),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Deals(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // From bottom
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
              title: Text('Contact Us'.trKey),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ContactUs(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PrivacyPolicy(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
              title: Text('Terms and Conditions'.trKey),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        TC(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
              title: Text('Feedback'.trKey),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Feedbacks(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
              title: Text('Logout'.trKey),
              onTap: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
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
            )
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
              iconTheme: const IconThemeData(color: Colors.white, size: 35),
              title: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
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
            padding: const EdgeInsets.only(top: 60, right: 20, left : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (StaffData != null && StaffData['professionOfStaff'] != null)
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  StaffProfilePage(
                                      StaffID: currentUserID,
                                      Skill: StaffData['professionOfStaff'] ??
                                          'user'),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOut;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
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
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ActualUser(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOut;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
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
                                    padding: EdgeInsets.only(left: 10, right: 10),
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
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Search...'.trKey,
                                        contentPadding: EdgeInsets.symmetric(
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
                            (true && staffProfiles.isNotEmpty)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 13.0, top: 10),
                                        child: Text(
                                          "Recommendations".trKey,
                                          style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 13.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.blue.shade100,
                                                child: Text(
                                                  profile['name'][0],
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(profile['name'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                    Text(profile['profession'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors.grey[
                                                                        700])),
                                                    Text(profile['city'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors.grey[
                                                                        600])),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                profile['active']
                                                    ? Icons.circle
                                                    : Icons.circle_outlined,
                                                color: profile['active']
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),

                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("Profession Categories").orderBy("priority", descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const FullScreenFlash();
                                }
                                final professionCategories = snapshot.data!.docs.reversed.toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: professionCategories.map((category) {

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 13.0, top: 5, right : 13),
                                          child: Text(
                                            category.id.trKey,
                                            style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold, fontSize: 20),
                                          ),
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection(category.id)
                                              .snapshots(),
                                          builder: (context, professionSnapshot) {
                                            if (!professionSnapshot.hasData) {
                                              return const ProfessionCardFlash();
                                            }

                                            final professions = professionSnapshot.data!.docs.reversed.toList();

                                            return SizedBox(
                                              height: 240,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                itemCount: professions.length,
                                                itemBuilder: (context, index) {
                                                  final profession = professions[index];
                                                  return InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          transitionDuration: const Duration(milliseconds: 500),
                                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                                              StaffPage(Skill: profession.id.toLowerCase()),
                                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                            const begin = Offset(1.0, 0.0);
                                                            const end = Offset.zero;
                                                            const curve = Curves.easeOut;

                                                            final tween = Tween(begin: begin, end: end)
                                                                .chain(CurveTween(curve: curve));
                                                            final offsetAnimation = animation.drive(tween);

                                                            return SlideTransition(
                                                              position: offsetAnimation,
                                                              child: child,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    child: ProfessionCard(profession: profession),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
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
                                      child:
                                          LoaderSupport.loadingAnimation.widget,
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text("No Users Found".trKey),
                                    );
                                  }

                                  if (SearchGlobal.isEmpty) {
                                    return Center(child: Text("Empty".trKey));
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index]
                                          .data() as Map<String, dynamic>;
                                      var UID = snapshot.data!.docs[index].id;
                                      DateTime now = DateTime.now();

                                      if (data.containsKey("expire") &&
                                          (data["expire"] as Timestamp)
                                              .toDate()
                                              .isAfter(now)) {
                                        if (data['professionOfStaff'] != null &&
                                            data["Verified"] == "verified" &&
                                            data['First_name'] != null &&
                                            data['First_name']
                                                .toString()
                                                .toLowerCase()
                                                .startsWith(SearchGlobal
                                                    .toLowerCase())) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 500),
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        StaffProfilePage(
                                                            StaffID: UID,
                                                            Skill: data[
                                                                'professionOfStaff']),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      const begin = Offset(1.0,
                                                          0.0); // From bottom
                                                      const end = Offset.zero;
                                                      const curve =
                                                          Curves.easeOut;

                                                      final tween = Tween(
                                                              begin: begin,
                                                              end: end)
                                                          .chain(CurveTween(
                                                              curve: curve));
                                                      final offsetAnimation =
                                                          animation
                                                              .drive(tween);

                                                      return SlideTransition(
                                                        position:
                                                            offsetAnimation,
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
                                                        BorderRadius.circular(
                                                            5),
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
                                                                    .circular(
                                                                        40),
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
                                                            overflow:
                                                                TextOverflow
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
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (data['professionOfStaff'] !=
                                                null &&
                                            data["Verified"] == "verified" &&
                                            data['First_name'] != null &&
                                            data['City']
                                                .toString()
                                                .toLowerCase()
                                                .startsWith(SearchGlobal
                                                    .toLowerCase())) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 500),
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        StaffProfilePage(
                                                            StaffID: UID,
                                                            Skill: data[
                                                                'professionOfStaff']),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      const begin = Offset(1.0,
                                                          0.0); // From bottom
                                                      const end = Offset.zero;
                                                      const curve =
                                                          Curves.easeOut;

                                                      final tween = Tween(
                                                              begin: begin,
                                                              end: end)
                                                          .chain(CurveTween(
                                                              curve: curve));
                                                      final offsetAnimation =
                                                          animation
                                                              .drive(tween);

                                                      return SlideTransition(
                                                        position:
                                                            offsetAnimation,
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
                                                        BorderRadius.circular(
                                                            15),
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
                                                                    .circular(
                                                                        40),
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
                                                            overflow:
                                                                TextOverflow
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
                                                                FontWeight
                                                                    .bold),
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
      bottomNavigationBar: SafeArea(
        child: Container(
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
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const MyHomePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // From bottom
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
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
                  child: const Icon(Icons.home,
                      color: Colors.blueAccent, size: 28),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const MainMap(whichStaff: "All"),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // From bottom
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
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
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ClientNotificationPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // From bottom
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
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
                  child: const Icon(Icons.notifications,
                      color: Colors.purple, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfessionCard extends StatefulWidget {
  final DocumentSnapshot profession;

  const ProfessionCard({super.key, required this.profession});

  @override
  State<ProfessionCard> createState() => _ProfessionCardState();
}

class _ProfessionCardState extends State<ProfessionCard> {
  bool _imageLoaded = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.profession["image"];
    final professionId = widget.profession.id.trKey;
    final slogan = "${widget.profession["slogan"]}".trKey ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    if (!_imageLoaded) {
                      Future.microtask(() {
                        setState(() {
                          _imageLoaded = true;
                        });
                      });
                    }
                    return child;
                  } else {
                    return const ImageFlash(); // Placeholder widget
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
            ),
            if (_imageLoaded) ...[
              const SizedBox(height: 5),
              Text(
                professionId,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slogan,
                style: GoogleFonts.roboto(fontSize: 14),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class ProfessionCardFlash extends StatefulWidget {
  const ProfessionCardFlash({super.key});

  @override
  State<ProfessionCardFlash> createState() => _ProfessionCardFlash();
}

class _ProfessionCardFlash extends State<ProfessionCardFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade100,
      end: Colors.blue.shade100,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: _colorAnimation.value,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: 19.2,
                      decoration: BoxDecoration(
                        color: _colorAnimation.value,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: double.infinity,
                      height: 16.8,
                      decoration: BoxDecoration(
                        color: _colorAnimation.value,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ImageFlash extends StatefulWidget {
  const ImageFlash({super.key});

  @override
  State<ImageFlash> createState() => _ImageFlash();
}

class _ImageFlash extends State<ImageFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade100,
      end: Colors.blue.shade100,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) => Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
            ),
          )
      );
  }
}

class FullScreenFlash extends StatefulWidget {
  const FullScreenFlash({super.key});

  @override
  State<FullScreenFlash> createState() => _FullScreenFlash();
}

class _FullScreenFlash extends State<FullScreenFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade100,
      end: Colors.blue.shade200,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: screenWidth - 16,
            height: 700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: _colorAnimation.value,
            ),
          ),
        )
    );
  }
}