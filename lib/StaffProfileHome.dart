import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:carehub/EContact.dart';
import 'package:carehub/EPersonal.dart';
import 'package:carehub/EServiceRate.dart';
import 'package:carehub/KYC.dart';
import 'package:carehub/LoaderSupport.dart';
import 'package:carehub/Models/PaymentRecordModel.dart';
import 'package:carehub/Rating.dart';
import 'package:carehub/services/NotificationService.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordImpl.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordService.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:carehub/services/fcm_service.dart';
import 'package:carehub/services/sendNotificationService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ContactUs.dart';
import 'Deals.dart';
import 'Feedback.dart';
import 'LoginPage.dart';
import 'StaffNotificationPage.dart';
import 'TC.dart';
import 'client.dart';
import 'package:http/http.dart' as http;

import 'globle.dart';

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

class StaffProfileHome extends StatefulWidget {
  const StaffProfileHome({super.key});

  @override
  State<StatefulWidget> createState() => _StaffProfileHome();
}

class _StaffProfileHome extends State<StaffProfileHome> {
  NotificationService notificationService = NotificationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    SearchStaff();
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    _checkAndUpdate();
    FcmService.FirebaseInit();
    _liveLocation();
    updateToken();
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
        _showSnack('Update failed: Testing Version'.trKey);
      }
      else {
        _showSnack('Update failed : Unknown Error'.trKey);
      }
    }
  }
  void _showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  String CurrentLocation = "Loading...".trKey;

  Future<void> getCurrentLocationName(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      String place = "${placemarks.first.locality}";
      setState(() {
        CurrentLocation = "CareNest in $place";
      });
    }
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
    } catch (e) {
    }
  }

  var StaffData;
  var StaffData1;
  late String currentUserID;

  Future<void> SearchStaff() async {
    User? user1 = FirebaseAuth.instance.currentUser;
    currentUserID = user1?.uid ?? '';

    // Get current user's main document
    DocumentSnapshot documentSnapshot1 = await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUserID)
        .get();
    StaffData1 = documentSnapshot1.data() as Map<String, dynamic>?;

    if (StaffData1 == null || StaffData1["professionOfStaff"] == null) {
      print("professionOfStaff is missing in user profile.");
      return;
    }

    // Now get staff document from that profession's collection
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("${StaffData1["professionOfStaff"]}")
        .doc(currentUserID)
        .get();

    if (!documentSnapshot.exists) {
      print("Staff document does not exist.");
      return;
    }

    if (!mounted) return;

    setState(() {
      StaffData = documentSnapshot.data() as Map<String, dynamic>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;

    if (StaffData == null) {
      return Scaffold(
        drawer: Drawer(
          width: screenWidth * 0.7,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(color: Globle.theme),
                  child: Column(children: [
                    (StaffData != null &&
                            StaffData['professionOfStaff'] != null)
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
                                image: NetworkImage(StaffData['Profile_Pic']),
                                fit:
                                    BoxFit.cover, // Adjust the fit if necessary
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ActualUser(),
                                  ));
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
                                  ),
                          ),
                    (StaffData == null)
                        ? Text(
                            "Empty".trKey,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        : Text(
                            "${StaffData['First_name']} ${StaffData['Last_name']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                  ])),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text('Home'.trKey),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaffProfileHome(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text('Deals'.trKey),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DealsForStaff(),
                      ));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.headset_mic),
                title: Text('Contact Us'.trKey),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUs(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: Text('Terms and Conditions'.trKey),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TC(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: Text('Feedback'.trKey),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Feedbacks(),
                      ));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text('Logout'.trKey),
                onTap: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()));
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
                title: SizedBox(
                  width: screenWidth * 0.6,
                  child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      "City".trKey,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                backgroundColor: Globle.theme,
                automaticallyImplyLeading: true,
              ),
            ),

            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 125),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top : 250.0),
                            child: Center(
                              child: LoaderSupport.loadingAnimation.widget,
                            )
                        ), // Loading indicator
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

    return Scaffold(
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => StaffProfileHome(
                            //           StaffID: currentUserID,
                            //           Skill: StaffData['professionOfStaff'] ??
                            //               'user'),
                            //     ));
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
                                MaterialPageRoute(
                                  builder: (context) => const ActualUser(),
                                ));
                          },
                          child: StaffData['Profile_Pic'] == null
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
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          StaffData['Profile_Pic']),
                                      fit: BoxFit
                                          .cover, // Adjust the fit if necessary
                                    ),
                                  ),
                                ),
                        ),
                  (StaffData == null)
                      ? Text(
                          "Empty".trKey,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : Text(
                          "${StaffData['First_name']} ${StaffData['Last_name']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ])),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('Home'.trKey),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffProfileHome(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text('Deals'.trKey),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DealsForStaff(),
                    ));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: Text('Contact Us'.trKey),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUs(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: Text('Terms and Conditions'.trKey),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TC(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: Text('Feedback'.trKey),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Feedbacks(),
                    ));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text('Logout'.trKey),
              onTap: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
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
          AppBar(
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 30
            ),
            title: SizedBox(
              width: double.infinity,
              child: Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  CurrentLocation,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            backgroundColor: Globle.theme,
            automaticallyImplyLeading: true,
          ),

          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      StaffView(
                        StaffData: StaffData,
                        UID: currentUserID,
                      )
                    ],
                  ),
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
                    MaterialPageRoute(
                      builder: (context) =>
                          const StaffProfileHome(),
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
                    MaterialPageRoute(
                      builder: (context) =>
                          const DealsForStaff(),
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
                  child: const Icon(Icons.work_history_rounded, color: Colors.green, size: 28),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const StaffNotificationPage(),
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
      ),
    );
  }
}

class StaffView extends StatefulWidget {
  final StaffData;
  final UID;
  const StaffView({super.key, required this.StaffData, required this.UID});
  @override
  State<StatefulWidget> createState() =>
      _StaffView(StaffData: StaffData, UID: UID);
}

class _StaffView extends State<StaffView> {
  late Razorpay _razorpay;
  String? _razorpayKey;
  String? _razorpayKeySecret;
  PaymentRecordService paymentRecordService = PaymentRecordImpl();
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchRazorpayKey();
    fetchVerificationDocs();
    paymentRecordModels();
    profilePicUrl = widget.StaffData['Profile_Pic'] ?? "";
  }

  Future<void> _fetchRazorpayKey() async {
    try {
      final response = await http.get(Uri.parse("https://aniketapi.ancientcoders.in/razorpay_key"));
      final data = jsonDecode(response.body);
      setState(() {
        _razorpayKey = data['key_id'];
        _razorpayKeySecret = data["key_secret"];
      });
    } catch (e) {
      debugPrint('Failed to fetch key: $e');
    }
  }

  late String _planTitle;
  late int _amountInPaise;

  void _startPayment({required int amountInPaise, required String plan, required String planTitle, required String userEmail, required String userContact}) {
    if (_razorpayKey == null) {
      _showAlert("Error", "Razorpay Key not loaded.");
      return;
    }
    // Store data in state
    _planTitle = planTitle;
    _amountInPaise = amountInPaise;

    var options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'name': 'CareNest',
      'description': 'Subscription Plan $plan',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': false,
      'prefill': {'contact': userContact, 'email': userEmail},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showAlert("Success", "Payment ID: ${response.paymentId}");

    FirebaseFirestore.instance.collection("Payment Records").add({
      "duration" : _planTitle == "COMBO"? "2 Months" : "1 Month",
      "expire" : _planTitle == "COMBO" ? DateTime.now().add(const Duration(days: 60)) : DateTime.now().add(const Duration(days: 30)),
      "plan" : "₹${_amountInPaise/100}",
      "staffUID" : UID,
      "start" : DateTime.now(),
      "feature1" : _planTitle == "BASIC"? "None" : "Recommendations",
    });

    FirebaseFirestore.instance.collection(StaffData['professionOfStaff'].toString().toLowerCase()).doc(UID).update({
      "expire" : _planTitle == "COMBO" ? DateTime.now().add(const Duration(days: 60)) : DateTime.now().add(const Duration(days: 30)),
    });

    FirebaseFirestore.instance.collection("user").doc(UID).update({
      "expire" : _planTitle == "COMBO" ? DateTime.now().add(const Duration(days: 60)) : DateTime.now().add(const Duration(days: 30)),
    });
    capturePayment(_amountInPaise, response.paymentId.toString());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StaffProfileHome(),));
  }

  Future<void> capturePayment(int amount, String id) async {
    try {
      final Uri uri = Uri.https('api.razorpay.com', '/v1/payments/$id/capture');
      final String auth = 'Basic ${base64Encode(
          utf8.encode('$_razorpayKey:$_razorpayKeySecret'))}';
      final http.Response response = await http.post(
        uri,
        headers: {
      'Content-Type': 'application/json',
      "Authorization": auth
        },
        body: jsonEncode({
          'amount': amount,
          'currency': 'INR',
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Payment Capture Successefull: ${response.body}');
        }
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['error']['description'];
        throw errorMessage ?? 'Failed to Capture Payment';
      }
    }catch(e){
      rethrow;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
    });
    _showAlert("Payment Failed".trKey, "Code: ${response.code}\nMessage: ${response.message}");
  }

  String wrapText(String text, int maxCharsPerLine) {
    if (text.length <= maxCharsPerLine) return text;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i += maxCharsPerLine) {
      buffer.writeln(
          text.substring(i, (i + maxCharsPerLine).clamp(0, text.length))
      );
    }
    return buffer.toString();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showAlert("Wallet Selected".trKey, "Wallet: ${response.walletName}");
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  PaymentRecordModel? paymentRecordModel;

  Future<void> paymentRecordModels() async {
    var result = await paymentRecordService.getPaymentRecordByUID(UID);
    if (!mounted) return; // optional safety
    setState(() {
      paymentRecordModel = result;
    });
  }


  final StaffData;
  final UID;
  String profilePicUrl = "";
  Future<void> pickAndUploadImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    File imagePath = File(pickedImage.path);
    String fileName = imagePath.path.split('/').last;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        Reference ref =
            FirebaseStorage.instance.ref().child("${user.uid}/$fileName");
        UploadTask uploadTask = ref.putFile(imagePath);
        TaskSnapshot snapshot = await uploadTask;
        String profileURL = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection(StaffData['professionOfStaff'].toLowerCase())
            .doc(user.uid)
            .update({
          "Profile_Pic": profileURL,
        });

        await FirebaseFirestore.instance
            .collection("user")
            .doc(user.uid)
            .update({
          "Profile_Pic": profileURL,
        });

        setState(() {
          profilePicUrl = profileURL;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile picture updated successfully!".trKey)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> fetchVerificationDocs() async {
    try {
      // Fetch URLs asynchronously
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _aadharUrl = await FirebaseStorage.instance
            .ref()
            .child("VerificationDoc/AadharCard/${user.uid}")
            .getDownloadURL();

        _professionVerDocUrl = await FirebaseStorage.instance
            .ref()
            .child("VerificationDoc/ProfessionalDoc/${user.uid}")
            .getDownloadURL();
      }
    } catch (e) {
    } finally {
      // Update the state to reflect loading completion
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isLoading = true;
  String? _aadharUrl;
  String? _professionVerDocUrl;
  bool isShowPlans = false;

  _StaffView({required this.StaffData, required this.UID});
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;
    
    
    
    Container plans(String title, String price, IconData icon3,  IconData icon4, Color color1, Color color2){
      return Container(
        height: 400,
        width: screenWidth * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xfc001238),
          border: Border.all(color: const Color(0xffefbf04), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0xFFEFBF04),
                spreadRadius: 0,
                blurRadius: 1,
                offset: Offset(0, 1))
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: (){
                        setState(() {
                          isShowPlans = false;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.white, size: 18,)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title.trKey, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                const SizedBox(height: 10,),
                Text("₹$price/mo", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("BENEFITS".trKey, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Text("Your profile will be presented on our platform, along with real-time visibility on the map for convenience.".trKey, style: GoogleFonts.roboto(color: Colors.white), textAlign: TextAlign.center,),
                const SizedBox(height: 10),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18,),
                          const SizedBox(width: 8),
                          Text("Profile visibility on platform".trKey, style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Text("Live map visibility".trKey, style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(icon3, color: color1, size: 18),
                          const SizedBox(width: 8),
                          Text("Profile in recommendations".trKey, style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(icon4, color: color2, size: 18),
                          const SizedBox(width: 8),
                          Text("Extra 1 month".trKey, style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
                SizedBox(
                  width: 200, // Adjust width as needed
                  child: ElevatedButton(
                    onPressed: () async {
                      if(title == "BASIC"){
                        int amount = int.parse(price.toString());
                        String plan = "$price₹ ${title == "COMBO"? "2 Months" : "1 Month"}";

                        try {
                          _startPayment(
                            amountInPaise: amount * 100,
                            plan: plan,
                            planTitle: title,
                            userEmail: StaffData["Email"].toString(),
                            userContact: StaffData["Phone_Number1"],
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Payment failed to initialize".trKey);
                        }
                      }else{
                        Fluttertoast.showToast(msg: "Not available yet".trKey);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shadowColor: const Color(0xFFFFD700),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Select".trKey,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                width: screenWidth,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26, spreadRadius: 1, blurRadius: 1)
                    ]),
                child: Column(
                  children: [
                    // Profile Actual details
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SizedBox(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: pickAndUploadImage,
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(80),
                                          color: Colors.green,
                                          image: DecorationImage(
                                            image: profilePicUrl.isEmpty
                                                ? const NetworkImage(
                                                "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=")
                                                : NetworkImage(profilePicUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                        5), // Space between image and text
                                    Container(
                                      width : 80,
                                        child: Text("Tap to change".trKey, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey),),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 8,),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ("${StaffData['First_name']} ${StaffData['Last_name']}").length > 14 ? "${StaffData['First_name']} ${StaffData['Last_name']}".substring(0, 13) + "..." : "${StaffData['First_name']} ${StaffData['Last_name']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 20),
                                            child: Container(
                                              height: 35,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                boxShadow: const [BoxShadow(
                                                  color: Colors.black,
                                                  blurRadius: 2,
                                                  offset: Offset(1.5, 1.5)
                                                )],
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Center(
                                                child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EPersonal(
                                                                    Skill: StaffData[
                                                                    'professionOfStaff']),
                                                          ));
                                                    },
                                                    child: Text(
                                                      "Change".trKey,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                          FontWeight.bold, color: Colors.white),
                                                    )),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              StaffData["Status"]
                                                  ? "Online".trKey
                                                  : "Offline".trKey,
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12)),
                                          const Text(
                                            " | ",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(StaffData["City"],
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RatingState(UID: UID),
                                              ));
                                        },
                                        child: Container(
                                          height: 45,
                                          margin: const EdgeInsets.only(top: 10),
                                          width: screenHeight * 0.28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xff00008B),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Color(0xffFFD700),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10, left: 5),
                                                child: Text(
                                                  "${StaffData["Rating"]}/5.0",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                              Text(
                                                "Check".trKey,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                              const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 45,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            spreadRadius: 1,
                                            blurRadius: 1)
                                      ],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Center(
                                        child: Text(
                                          "${
                                        StaffData['professionOfStaff'][0]
                                                .toUpperCase() +
                                            StaffData['professionOfStaff']
                                                .substring(1)
                                      }".trKey,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Color(0xff089000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        )),
                                  ),
                                ),
                                Row(
                                  children: [
                                    !StaffData["Status"]
                                        ? InkWell(
                                      onTap: () async {
                                        try {
                                          // Only update if status needs to be changed to "Available"
                                          var docSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection(StaffData[
                                          'professionOfStaff'])
                                              .doc(UID)
                                              .get();

                                          if (docSnapshot.exists &&
                                              docSnapshot['Status'] != true) {
                                            await FirebaseFirestore.instance
                                                .collection(StaffData[
                                            'professionOfStaff'])
                                                .doc(UID)
                                                .update({
                                              "Status": true,
                                            });

                                            // Show Snackbar message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content:
                                                  Text("You are now live".trKey)),
                                            );
                                            // Notification to staff that he/she is online
                                            String? currentToken = await FirebaseMessaging.instance.getToken();
                                            sendNotificationService
                                                .sendNotificationUsingApi(
                                                body:
                                                'Send Successful',
                                                data: {
                                                  "screen":
                                                  "Empty",
                                                  "notificationId":
                                                  "2",
                                                },
                                                title:
                                                "Status",
                                                token:
                                                currentToken);

                                            // Refresh and navigate to StaffProfileHome
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const StaffProfileHome()),
                                            );
                                          }
                                        } catch (e) {
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.black,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Tap To Go Online".trKey,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        : InkWell(
                                      onTap: () async {
                                        try {
                                          // Only update if status needs to be changed to "Busy"
                                          var docSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection(StaffData[
                                          'professionOfStaff'])
                                              .doc(UID)
                                              .get();

                                          if (docSnapshot.exists &&
                                              docSnapshot['Status'] != false) {
                                            await FirebaseFirestore.instance
                                                .collection(StaffData[
                                            'professionOfStaff'])
                                                .doc(UID)
                                                .update({
                                              "Status": false,
                                            });

                                            // Show Snackbar message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "You are now offline".trKey)),
                                            );
                                            await FlutterLocalNotificationsPlugin().cancel(2);

                                            // Refresh and navigate to StaffProfileHome
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const StaffProfileHome()),
                                            );
                                          }
                                        } catch (e) {
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.black,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right: 15, left: 5),
                                          child: Center(
                                            child: Text(
                                              "Tap To Go Offline".trKey,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // false 
                                //     ? InkWell(
                                //   onTap: () {
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) =>
                                //               StaffNotificationPage(),
                                //         ));
                                //   },
                                //   child: Container(
                                //     height: 40,
                                //     width: 40,
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(40),
                                //     ),
                                //     child: Icon(Icons.notifications),
                                //   ),
                                // ) 
                                //     : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    StaffData["Verified"] == "unverified" || StaffData["Verified"] == "rejected"
                        ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        height: 100,
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (StaffData["Verified"] == "unverified") ...[
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => KYC(
                                                  Skill: StaffData[
                                                  'professionOfStaff']),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Verify your profile before free trial ends... click...".trKey,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    )
                                  ] else if (StaffData["Verified"] ==
                                      "pending") ...[
                                    Text(
                                      "Under Verification Process".trKey,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ] else if (StaffData["Verified"] ==
                                      "rejected") ...[
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => KYC(
                                                Skill: StaffData[
                                                'professionOfStaff']),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "${"Rejected, Click to apply again...".trKey}${StaffData["Feedback"]?? ""}",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    )
                                  ] else ...[
                                    Text(
                                      "Unknown State".trKey,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ) 
                        : Container(),
                    // Subscription plan
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xff0202b1),
                              Color(0xFFEFBF04),
                            ],
                            stops: [0, 100],
                          ),
                          border: Border.all(color: const Color(0xffefbf04), width: 2),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFFEFBF04),
                                spreadRadius: 0,
                                blurRadius: 1,
                                offset: Offset(0, 1))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: paymentRecordModel == null
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 200,
                                      child: Text("You’ar not active with \nany subscription plan.".trKey, style: GoogleFonts.aclonica(fontSize: 16,color: const Color(0xFFFFFFff), shadows: [const BoxShadow(color: Color(0x000000ff))]),)),
                                  Container(
                                      width: 200,
                                      child: Text("Your profile won't appear until \nyou subscribe to a plan.".trKey, style: GoogleFonts.alkalami(fontSize: 12, color: Colors.white),)),
                                  InkWell(
                                      onTap: (){
                                        setState(() {
                                          isShowPlans = !isShowPlans;
                                        });
                                      },
                                      child: Text("Check Plans".trKey, style: GoogleFonts.alkatra(),)),
                                ],
                              ),
                              Container(
                                  width: 100,
                                  child: const Image(image: AssetImage("assets/icons/expired.png",), width: 90, height: 90,)),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 200,
                                      child: Text("${"Congratulations, Your\nActive on".trKey}\n${"${paymentRecordModel?.plan}".trKey} \n${"${paymentRecordModel?.duration}".trKey} ${"plan".trKey}", style: GoogleFonts.aclonica(fontSize: 16,color: const Color(0xFFFFFFff), shadows: [const BoxShadow(color: Color(0x000000ff))]),)),
                                  Container(
                                      width : 200,
                                      child: Text("Valid till".trKey+" ${DateFormat("d MMM y").format(paymentRecordModel!.expire)}", style: GoogleFonts.alkatra(),))
                                ],
                              ),
                              Container(
                                  height: 100,
                                  child: const Image(image: AssetImage("assets/icons/congrats.png")))
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Contact information
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 10, bottom: 5, right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                              width: 200,
                                    child: Text(
                                      "Contact Information".trKey,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Container(
                                      height: 35,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          boxShadow: const [BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(1.5, 1.5)
                                          )],
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Center(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EContact(
                                                        Skill: StaffData[
                                                        'professionOfStaff']),
                                                  ));
                                            },
                                            child: Text(
                                              "Change".trKey,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold, color: Colors.white),
                                            )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: InkWell(
                                          onTap: () async {
                                            var phoneNumber =
                                            StaffData['Phone_Number1'];
                                            final Uri phoneUri = Uri(
                                              scheme: 'tel',
                                              path: phoneNumber,
                                            );
                                            if (await canLaunchUrl(phoneUri)) {
                                              await launchUrl(phoneUri);
                                            } else {
                                              throw "Could not lounch phone dialer".trKey;
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(60),
                                                color: Colors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.blueAccent,
                                                      blurRadius: 1,
                                                      spreadRadius: 1)
                                                ]),
                                            child: const Icon(
                                              Icons.call,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Text("${StaffData['Phone_Number1']?? "No Number".trKey}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: InkWell(
                                          onTap: () async {
                                            var phonenumber01 =
                                            StaffData["Phone_Number2"];
                                            final Uri phoneUri01 = Uri(
                                              scheme: 'tel',
                                              path: phonenumber01,
                                            );
                                            if (phonenumber01 != null) {
                                              if (await canLaunchUrl(phoneUri01)) {
                                                launchUrl(phoneUri01);
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg: "Empty".trKey,
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                );
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: "Empty".trKey,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(60),
                                                color: Colors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.greenAccent,
                                                      blurRadius: 1,
                                                      spreadRadius: 1)
                                                ]),
                                            child: const Icon(
                                              Icons.call,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(StaffData['Phone_Number2'] == ""? "No Number".trKey : "${StaffData['Phone_Number2']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    // Service Rate
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 10, bottom: 5, right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 200,
                                    child: Text(
                                      "Service Rate".trKey,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Container(
                                      height: 35,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          boxShadow: const [BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(1.5, 1.5)
                                          )],
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Center(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EServiceRate(
                                                            Skill: StaffData[
                                                            'professionOfStaff']),
                                                  ));
                                            },
                                            child: Text(
                                              "Change".trKey,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold, color: Colors.white),
                                            )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.only(right: 40, left: 40),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: screenWidth * 0.5,
                                      child: Text("Hour based".trKey)),
                                  Text("${StaffData['Hour_Rate'] ?? '--'} ${StaffData['Currency'] ?? '-'}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 40, left: 40),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: screenWidth * 0.5,
                                      child: Text("Day based".trKey)),
                                  Text("${StaffData['Day_Rate'] ?? '--'} ${StaffData['Currency'] ?? '-'}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 40, left: 40),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: screenWidth * 0.5,
                                      child: Text(
                                        "Day service shift".trKey+" ${StaffData['Day_Shift'] ?? '--'}"+("hours".trKey),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.blue),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Professional Details
                    StaffData["Verified"] == "verified" || StaffData["Verified"] == "pending"
                        ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        height: screenHeight * 0.5,
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 1)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (StaffData["Verified"] == "unverified") ...[
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => KYC(
                                                  Skill: StaffData[
                                                  'professionOfStaff']),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Verify your profile before free trial ends... click...".trKey,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    )
                                  ] else if (StaffData["Verified"] ==
                                      "pending") ...[
                                    Text(
                                      "Under Verification Process".trKey,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ] else if (StaffData["Verified"] ==
                                      "rejected") ...[
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => KYC(
                                                Skill: StaffData[
                                                'professionOfStaff']),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Rejected, Click to apply again...".trKey+" ${StaffData["Feedback"]?? ""}",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    )
                                  ] else if (StaffData["Verified"] ==
                                      "verified") ...[
                                    Column(
                                      children: [
                                        Text(
                                          "Verified Documents".trKey,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          height: 200,
                                          width:
                                          MediaQuery.sizeOf(context).width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  _aadharUrl.toString()),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          height: 200,
                                          width:
                                          MediaQuery.sizeOf(context).width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  _professionVerDocUrl.toString()),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ] else ...[
                                    Text(
                                      "Unknown State".trKey,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ) 
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
        isShowPlans
            ? Center(
              child: SizedBox(
                width: screenWidth * 0.9,
                height: screenHeight,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.8,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              plans("BASIC", "29", Icons.cancel, Icons.cancel, Colors.red, Colors.red),
                              const SizedBox(height: 15),
                              plans("ADVANCE", "49", Icons.check_circle, Icons.cancel, Colors.green, Colors.red),
                              const SizedBox(height: 15),
                              plans("COMBO", "99", Icons.check_circle, Icons.check_circle, Colors.green, Colors.green),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
            : Container(),
      ],
    );
  }
}
