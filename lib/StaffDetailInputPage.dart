import 'dart:io';

import 'package:carehub/LoginPage.dart';
import 'package:carehub/StaffProfileHome.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class StaffDetailInputPage extends StatefulWidget {
  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  const StaffDetailInputPage(
      {super.key, required this.FirstName,
      required this.LastName,
      required this.Email,
      required this.Password});
  @override
  State<StatefulWidget> createState() => _StaffDetailInputPage(
      Password: Password,
      FirstName: FirstName,
      Email: Email,
      LastName: LastName);
}

class _StaffDetailInputPage extends State<StaffDetailInputPage> {
  @override
  void initState() {
    super.initState();
    void liveLocation() {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          setState(() async {
            String lat = position.latitude.toString();
            String long = position.longitude.toString();
            User? user = FirebaseAuth.instance.currentUser;

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
    liveLocation();
  }

  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  _StaffDetailInputPage(
      {required this.FirstName,
      required this.LastName,
      required this.Email,
      required this.Password});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context);


    return Scaffold(
        backgroundColor: Colors.white,
        body: AndroidView(
                Password: Password,
                FirstName: FirstName,
                Email: Email,
                LastName: LastName));
  }
}

class AndroidStaffPage extends StatefulWidget {
  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  const AndroidStaffPage(
      {super.key, required this.FirstName,
      required this.LastName,
      required this.Email,
      required this.Password});

  @override
  State<StatefulWidget> createState() => _AndroidStaffPage(
      Password: Password,
      FirstName: FirstName,
      Email: Email,
      LastName: LastName);
}

Future<bool> _setUserPageStatus(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool("Staff", value);
}

class _AndroidStaffPage extends State<AndroidStaffPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
  }

  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  _AndroidStaffPage(
      {required this.FirstName,
      required this.LastName,
      required this.Email,
      required this.Password});

  List<String> items = [
    "Cleaner",
    "Gardener",
    "Housekeepers",
    "Personal Care Assistants",
    "Elder Companions",
    "Elderly",
    "Babysitters",
    "Teacher",
    "Driver",
    "Home Guards",
    "Security Guards",
    "Chef",
    "Event Helpers",
    "Bartender",
    "Certified Nursing Assistants",
    "Home Health Aides",
    "Physiotherapists",
    "AC Technician",
    "Electrician",
    "Plumber",
    "Carpenter",
    "Painter",
    "Fitness Trainer",
    "Yoga Trainer",
    "Photographer",
  ];
  String? selectedValue;
  String ErrorData = "";

  TextEditingController PhoneNo = TextEditingController();
  TextEditingController OTP = TextEditingController();
  TextEditingController ProfilePic = TextEditingController();
  TextEditingController City = TextEditingController(text: "Loading...");

  bool isLoading = false;

  File? imagePath;
  late LocationPermission permission;
  bool isValidPhone = true;
  bool isValidCity = true;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // Wait and retry if location is still disabled
    if (!serviceEnabled) {
      // Retry after a short delay
      await Future.delayed(const Duration(seconds: 1));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
    await getCurrentLocationName(position.latitude, position.longitude);
  }
  Future<void> getCurrentLocationName(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      String place = "${placemarks.first.locality}";
      CurrentLocation = place;
      City.text = place;
    }
  }
  String CurrentLocation = "";

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      Column(
        children: [
          const SizedBox(height: 100,),
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
                children: [
                  const SizedBox(height: 10,),
                  // logo title
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
                          child: Text(
                            "CARENEST \n"+("EXTRA INFORMATION".trKey),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
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

                  // Profession
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          width: screenWidth - 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6)
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: selectedValue,
                            hint: Text("Select Job".trKey),
                            items: items.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: Text(
                                    item.trKey,
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

                  // Phone Number
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: screenWidth - 60,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(),
                            controller: PhoneNo,
                            onChanged: (value) {
                              setState(() {
                                isValidPhone = RegExp(
                                  r"^\d{7,12}$",
                                ).hasMatch(value);
                              });
                            },
                            decoration: InputDecoration(
                                labelText: "Phone no.".trKey, // Placeholder text
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    16,
                                    16) // Adds border around the text field
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  !isValidPhone
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Phone Number".trKey,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // City name
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: City,
                        onChanged: (value) {
                          setState(() {
                            isValidCity = RegExp(
                              r"^[a-zA-Z ]+$",
                            ).hasMatch(value);
                          });
                        },
                        decoration: InputDecoration(
                            labelText: "City".trKey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(20, 16, 16,
                                16) // Adds border around the text field
                            ),
                      ),
                    ),
                  ),
                  !isValidCity
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid City".trKey,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Image and submit
                  SizedBox(
                    width: 265,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: imagePath == null
                              ? ElevatedButton(
                            onPressed: () async {
                              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedImage != null) {
                                setState(() {
                                  imagePath = File(pickedImage.path);
                                });
                              }
                            },
                            child: Text("Select Image".trKey),
                          )
                              : ClipOval(
                            child: Image.file(
                              imagePath!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });

                                String phone = PhoneNo.text;
                                String city = City.text;
                                String skill = selectedValue.toString().toLowerCase();
                                if (phone.isNotEmpty &&
                                    city.isNotEmpty &&
                                    skill.isNotEmpty && selectedValue!.isNotEmpty) {
                                  try {
                                    UserCredential userCredential = await FirebaseAuth
                                        .instance
                                        .createUserWithEmailAndPassword(
                                        email: Email, password: Password);
                                    User? user = userCredential.user;

                                    String? fileName =
                                        imagePath?.path.split('/').last;
                                    UploadTask uploadTask = FirebaseStorage.instance
                                        .ref()
                                        .child("${user?.uid}/$fileName")
                                        .putFile(imagePath!);
                                    TaskSnapshot snapshot = await uploadTask;
                                    Reference ref = snapshot.ref;
                                    String profileURL = await ref.getDownloadURL();
                                    String? token = await FirebaseMessaging.instance.getToken();

                                    await FirebaseFirestore.instance
                                        .collection(skill.toLowerCase())
                                        .doc(user?.uid)
                                        .set({
                                      'Email': Email,
                                      'City': city,
                                      'First_name': FirstName,
                                      'professionOfStaff':
                                      skill[0].toLowerCase() + skill.substring(1),
                                      'Password': Password,
                                      'Phone_Number1': phone,
                                      'Profile_Pic': profileURL,
                                      'Last_name': LastName,
                                      "expire" : DateTime.now().add(const Duration(days: 37)),
                                      'Rating': 0,
                                      'Status': false,
                                      'Verified': 'unverified',
                                      'Date_of_registered': DateFormat("dd/MM/yyyy")
                                          .format(DateTime.now()),
                                      'Verified_status': false,
                                      'token' : token
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(user?.uid)
                                        .set({
                                      "Email": Email,
                                      "First_name": FirstName,
                                      'professionOfStaff':
                                      skill[0].toLowerCase() + skill.substring(1),
                                      "Last_name": LastName,
                                      'Rating': 0,
                                      "Password": Password,
                                      "expire" : DateTime.now().add(const Duration(days: 37)),
                                      'Verified': 'unverified',
                                      "Phone_Number1": phone,
                                      "City": city,
                                      "Profile_Pic": profileURL,
                                      'token' : token
                                    });

                                    await FirebaseFirestore.instance
                                        .collection('Ratings')
                                        .doc(user?.uid)
                                        .set({
                                      "1Star": 0,
                                      "2Star": 0,
                                      "3Star": 0,
                                      "4Star": 0,
                                      "5Star": 0,
                                    });

                                    FirebaseFirestore.instance.collection("Payment Records").add({
                                      "duration" : "1 Month",
                                      "expire" : DateTime.now().add(const Duration(days: 37)),
                                      "plan" : "Free Trial",
                                      "staffUID" : user?.uid,
                                      "start" : DateTime.now(),
                                      "feature1" : "None",
                                    });

                                    user?.sendEmailVerification();
                                    await FirebaseAuth.instance.signOut();
                                    Fluttertoast.showToast(
                                        msg:
                                        "Link send, A link has been send to your email".trKey,
                                        toastLength: Toast.LENGTH_LONG);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginPage(),
                                        ));
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Fluttertoast.showToast(msg: e.message!);
                                    setState(() {
                                      ErrorData = e.message!;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Fluttertoast.showToast(msg: "$e");
                                    setState(() {
                                      ErrorData = "$e";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Fluttertoast.showToast(msg: "Fill all the blanks".trKey);
                                  setState(() {
                                    ErrorData = "Fill all the blanks".trKey;
                                  });
                                }
                              },
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Color(
                                    0xff0009a2))
                              ),
                              child: Text("Submit".trKey, style: const TextStyle(color: Colors.white),)),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Text(ErrorData, textAlign: TextAlign.justify, style: const TextStyle(color: Colors.red),),
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
                              "Privacy Policy,".trKey,
                              style: const TextStyle(
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
                              style: const TextStyle(
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
                              "Refund Policy".trKey,
                              style: const TextStyle(
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

class AndroidStaffPageGoogle extends StatefulWidget {
  final String FirstName;
  final String LastName;
  final AuthCredential credential;

  const AndroidStaffPageGoogle(
      {super.key, required this.FirstName,
        required this.LastName,
        required this.credential});

  @override
  State<StatefulWidget> createState() => _AndroidStaffPageGoogle(
      credential: credential,
      FirstName: FirstName,
      LastName: LastName);
}

class _AndroidStaffPageGoogle extends State<AndroidStaffPageGoogle> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
  }

  final String FirstName;
  final String LastName;
  final AuthCredential credential;

  _AndroidStaffPageGoogle(
      {required this.FirstName,
        required this.LastName,
      required this.credential});

  List<String> items = [
    "Cleaner",
    "Gardener",
    "Housekeepers",
    "Personal Care Assistants",
    "Elder Companions",
    "Elderly",
    "Babysitters",
    "Teacher",
    "Driver",
    "Home Guards",
    "Security Guards",
    "Chef",
    "Event Helpers",
    "Bartender",
    "Certified Nursing Assistants",
    "Home Health Aides",
    "Physiotherapists",
    "AC Technician",
    "Electrician",
    "Plumber",
    "Carpenter",
    "Painter",
    "Fitness Trainer",
    "Yoga Trainer",
    "Photographer",
  ];
  String? selectedValue;
  String ErrorData = "";

  TextEditingController PhoneNo = TextEditingController();
  TextEditingController OTP = TextEditingController();
  TextEditingController ProfilePic = TextEditingController();
  TextEditingController City = TextEditingController(text: "Loading...");

  bool isLoading = false;

  File? imagePath;
  late LocationPermission permission;
  bool isValidPhone = true;
  bool isValidCity = true;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // Wait and retry if location is still disabled
    if (!serviceEnabled) {
      // Retry after a short delay
      await Future.delayed(const Duration(seconds: 1));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
    await getCurrentLocationName(position.latitude, position.longitude);
  }
  Future<void> getCurrentLocationName(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      String place = "${placemarks.first.locality}";
      CurrentLocation = place;
      City.text = place;
    }
  }
  String CurrentLocation = "";

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 100,),
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
                    children: [
                      const SizedBox(height: 10,),
                      // logo title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                            child: Text(
                              "CARENEST \n"+("EXTRA INFORMATION".trKey),
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 18,
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

                      // Profession
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              width: screenWidth - 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6)
                                ],
                              ),
                              child: DropdownButton<String>(
                                value: selectedValue,
                                hint: Text("Select Job".trKey),
                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: Text(
                                        item.trKey,
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

                      // Phone Number
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 50,
                              width: screenWidth - 60,
                              child: TextField(
                                keyboardType: const TextInputType.numberWithOptions(),
                                controller: PhoneNo,
                                onChanged: (value) {
                                  setState(() {
                                    isValidPhone = RegExp(
                                      r"^\d{7,12}$",
                                    ).hasMatch(value);
                                  });
                                },
                                decoration: InputDecoration(
                                    labelText: "Phone no.".trKey, // Placeholder text
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        16,
                                        16,
                                        16) // Adds border around the text field
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      !isValidPhone
                          ? Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                        child: Row(
                          children: [
                            Text(
                              "Invalid Phone Number".trKey,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      )
                          : Container(),

                      // City name
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: City,
                            onChanged: (value) {
                              setState(() {
                                isValidCity = RegExp(
                                  r"^[a-zA-Z ]+$",
                                ).hasMatch(value);
                              });
                            },
                            decoration: InputDecoration(
                                labelText: "City".trKey,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(20, 16, 16,
                                    16) // Adds border around the text field
                            ),
                          ),
                        ),
                      ),
                      !isValidCity
                          ? Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                        child: Row(
                          children: [
                            Text(
                              "Invalid City".trKey,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      )
                          : Container(),

                      // Image and submit
                      SizedBox(
                        width: 265,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: imagePath == null
                                  ? ElevatedButton(
                                onPressed: () async {
                                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    setState(() {
                                      imagePath = File(pickedImage.path);
                                    });
                                  }
                                },
                                child: Text("Select Image".trKey),
                              )
                                  : ClipOval(
                                child: Image.file(
                                  imagePath!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    String phone = PhoneNo.text;
                                    String city = City.text;
                                    String skill = selectedValue.toString().toLowerCase();
                                    if (phone.isNotEmpty &&
                                        city.isNotEmpty &&
                                        skill.isNotEmpty && selectedValue!.isNotEmpty) {
                                      try {
                                        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                                        User? user = userCredential.user;

                                        String? fileName =
                                            imagePath?.path.split('/').last;
                                        UploadTask uploadTask = FirebaseStorage.instance
                                            .ref()
                                            .child("${user?.uid}/$fileName")
                                            .putFile(imagePath!);
                                        TaskSnapshot snapshot = await uploadTask;
                                        Reference ref = snapshot.ref;
                                        String profileURL = await ref.getDownloadURL();

                                        await FirebaseFirestore.instance
                                            .collection(skill.toLowerCase())
                                            .doc(user?.uid)
                                            .set({
                                          'Email': user?.email,
                                          'City': city,
                                          'First_name': FirstName,
                                          'professionOfStaff':
                                          skill[0].toLowerCase() + skill.substring(1),
                                          'Password': '',
                                          'Phone_Number1': phone,
                                          'Profile_Pic': profileURL,
                                          'Last_name': LastName,
                                          "expire" : DateTime.now().add(const Duration(days: 37)),
                                          'Rating': 0,
                                          'Status': false,
                                          'Verified': 'unverified',
                                          'Date_of_registered': DateFormat("dd/MM/yyyy")
                                              .format(DateTime.now()),
                                          'Verified_status': false,
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(user?.uid)
                                            .set({
                                          "Email": user?.email,
                                          "First_name": FirstName,
                                          'professionOfStaff':
                                          skill[0].toLowerCase() + skill.substring(1),
                                          "Last_name": LastName,
                                          'Rating': 0,
                                          "Password": '',
                                          "expire" : DateTime.now().add(const Duration(days: 37)),
                                          'Verified': 'unverified',
                                          "Phone_Number1": phone,
                                          "City": city,
                                          "Profile_Pic": profileURL,
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('Ratings')
                                            .doc(user?.uid)
                                            .set({
                                          "1Star": 0,
                                          "2Star": 0,
                                          "3Star": 0,
                                          "4Star": 0,
                                          "5Star": 0,
                                        });

                                        FirebaseFirestore.instance.collection("Payment Records").add({
                                          "duration" : "1 Month",
                                          "expire" : DateTime.now().add(const Duration(days: 37)),
                                          "plan" : "Free Trial",
                                          "staffUID" : user?.uid,
                                          "start" : DateTime.now(),
                                          "feature1" : "None",
                                        });

                                        await _setUserPageStatus(true);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => StaffProfileHome()),
                                              (Route<dynamic> route) => false, // removes everything before
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                      } on FirebaseAuthException catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Fluttertoast.showToast(msg: e.message!);
                                        setState(() {
                                          ErrorData = e.message!;
                                        });
                                      } catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Fluttertoast.showToast(msg: "$e");
                                        setState(() {
                                          ErrorData = "$e";
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Fluttertoast.showToast(msg: "Fill all the blanks".trKey);
                                      setState(() {
                                        ErrorData = "Fill all the blanks".trKey;
                                      });
                                    }
                                  },
                                  style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(Color(
                                          0xff0009a2))
                                  ),
                                  child: Text("Submit".trKey, style: const TextStyle(color: Colors.white),)),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                        child: Text(ErrorData, textAlign: TextAlign.justify, style: const TextStyle(color: Colors.red),),
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
                                  "Privacy Policy,".trKey,
                                  style: const TextStyle(
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
                                  style: const TextStyle(
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
                              style: const TextStyle(
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
        ),
        isLoading
            ? Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.35),
            child: LoaderSupport.loadingAnimation.widget,
          ),
        )
            : Container(),
      ]),
    );
  }
}

class AndroidView extends StatefulWidget {
  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  const AndroidView(
      {super.key, required this.FirstName,
      required this.LastName,
      required this.Email,
      required this.Password});
  @override
  State<StatefulWidget> createState() => _AndroidView(
      Password: Password,
      FirstName: FirstName,
      Email: Email,
      LastName: LastName);
}

class _AndroidView extends State<AndroidView> {
  final String FirstName;
  final String LastName;
  final String Email;
  final String Password;

  _AndroidView(
      {required this.FirstName,
      required this.LastName,
      required this.Email,
      required this.Password});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              AndroidStaffPage(
                  Password: Password,
                  FirstName: FirstName,
                  Email: Email,
                  LastName: LastName)
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
