import 'package:carehub/LoginPage.dart';
import 'package:carehub/StaffProfilePage.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordImpl.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordService.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ContactUs.dart';
import 'Deals.dart';
import 'Feedback.dart';
import 'LoaderSupport.dart';
import 'Models/PaymentRecordModel.dart';
import 'TC.dart';
import 'client.dart';
import 'globle.dart';
import 'main.dart';

class StaffPage extends StatefulWidget {
  String Skill;
  StaffPage({super.key, required this.Skill});
  @override
  State<StatefulWidget> createState() => _StaffPage(Skill: Skill);
}

class _StaffPage extends State<StaffPage> {
  @override
  void initState() {
    super.initState();
    _liveLocation();
    SearchStaff();
  }
  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
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
      },
    );
  }

  String Skill;

  bool isStaffAvailable = false;

  _StaffPage({required this.Skill});
  var StaffData;
  var documentID;
  late String currentUserID;
  String SearchGlobal = '';

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
      } else {
      }
    } catch (e) {
    }
  }

  bool isFilter = false;
  bool isAnyTime = false;
  bool isImmediately = false;
  PaymentRecordModel? paymentRecordModel;
  PaymentRecordService paymentRecordService = PaymentRecordImpl();

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StaffProfilePage(
                                      StaffID: currentUserID,
                                      Skill: StaffData['professionOfStaff'] ??
                                          'user'),
                                ));
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
                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                ])),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('Home'.trKey),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(),
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
                      builder: (context) => const Deals(),
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
          Container(
            height: 150,
            color: Globle.theme,
            child: AppBar(
              iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 35
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  width: screenWidth * 0.6,
                  child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      (Skill[0].toUpperCase() + Skill.substring(1)).trKey,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              backgroundColor: Globle.theme,
              automaticallyImplyLeading: true,
            ),
          ),
          // Profile photo
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (StaffData != null && StaffData['professionOfStaff'] != null)
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StaffProfilePage(
                                    StaffID: currentUserID,
                                    Skill: StaffData['professionOfStaff'] ??
                                        'user'),
                              ));
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
                              MaterialPageRoute(
                                builder: (context) => const ActualUser(),
                              ));
                        },
                        child: StaffData != null &&
                                StaffData['Profile_Pic'] != null
                            ? Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        NetworkImage(StaffData['Profile_Pic']),
                                    fit: BoxFit
                                        .cover, // Adjust the fit if necessary
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 1),
                                  ],
                                ),
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
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
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03),
                            width: screenWidth * 0.73,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
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
                                  padding: EdgeInsets.only(left: 10, right : 10),
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
                                      contentPadding:
                                          EdgeInsets.symmetric(
                                              horizontal: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isFilter = !isFilter;
                                });
                              },
                              child: Container(
                                height: 50,
                                width: screenWidth * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        spreadRadius: 1,
                                        color: Colors.black26,
                                        blurRadius: 1),
                                  ],
                                ),
                                child: const Icon(Icons.filter_list_sharp,
                                    size: 30, color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(Skill)
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<Row> chefViews = [];
                          if (snapshot.hasData) {
                            final chefs = snapshot.data?.docs.reversed.toList();
                            for (var chef in chefs!) {

                              Row rowCopy = Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {

                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(milliseconds: 500),
                                            pageBuilder: (context, animation, secondaryAnimation) => StaffProfilePage(
                                                StaffID: chef.id,
                                                Skill: Skill),
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
                                        height: screenHeight * 0.15,
                                        width: screenWidth * 0.95,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 1,
                                                  spreadRadius: 1)
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    10.0),
                                                child: Container(
                                                  height: 75,
                                                  width: 75,
                                                  decoration:
                                                  BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(50),
                                                    color: Colors.orange,
                                                    image:
                                                    DecorationImage(
                                                      image: NetworkImage(
                                                          chef[
                                                          'Profile_Pic']),
                                                      fit: BoxFit
                                                          .cover, // Adjust the fit if necessary
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    top: 10,
                                                    right: 5,
                                                    bottom: 40),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      "${chef['First_name']} ${chef['Last_name']}",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: 12),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                            chef["Status"]
                                                                ? "Online".trKey
                                                                : "Offline".trKey,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .green)),
                                                        const Text(" | "),
                                                        Text(
                                                            "${chef['Rating']}",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .green))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.3,
                                                height:
                                                screenHeight * 0.2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          bottom: 10),
                                                      child: Text(
                                                        chef['City'],
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: 120,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              15),
                                                          color: Colors.white,
                                                          boxShadow: const [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                spreadRadius:
                                                                1,
                                                                blurRadius:
                                                                1)
                                                          ]),
                                                      child: Center(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                            child: Text(
                                                              (Skill[0].toUpperCase() + Skill.substring(1)).trKey,
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                              maxLines: 1,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize:
                                                                  15),
                                                            ),
                                                          )),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                              DateTime now = DateTime.now();
                              final data = chef.data() as Map<String, dynamic>;
                              if(data.containsKey("expire") && data["expire"].toDate().isAfter(now))
                              {
                                if (isAnyTime) {
                                  if (chef["Verified"] == "verified" &&
                                      !chef["Status"]) {
                                    final chefView = rowCopy;
                                    chefViews.add(chefView);
                                  }
                                }
                                if (isImmediately) {
                                  if (chef["Verified"] == "verified" &&
                                      chef["Status"]) {
                                    final chefView = rowCopy;
                                    chefViews.add(chefView);
                                  }
                                }
                                if (chef["Verified"] == "verified" &&
                                    !isImmediately &&
                                    !isAnyTime) {
                                  final chefView = rowCopy;
                                  chefViews.add(chefView);
                                }
                              }
                              else{
                              }
                            }
                          }
                          if(chefViews.isEmpty){
                            return Center(child: Text("No Staff".trKey, style: TextStyle(fontSize: 24),));
                          }
                          return ListView(
                            padding: EdgeInsets.zero,
                            children: chefViews,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              isFilter
                  ? Positioned(
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 180),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topLeft: Radius.circular(15)),
                            border: Border.all(color: Colors.blue, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Availability".trKey,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isImmediately = !isImmediately;
                                        isAnyTime = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: isImmediately
                                              ? Colors.green
                                              : Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: const [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.blue,
                                                spreadRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Immediately".trKey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isImmediately = false;
                                        isAnyTime = !isAnyTime;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: isAnyTime
                                              ? Colors.green
                                              : Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: const [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.blue,
                                                spreadRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Any Time".trKey),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),

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

                                      if(data.containsKey("expire") && (data["expire"] as Timestamp).toDate().isAfter(now)) {
                                        if (data['professionOfStaff'] != null &&
                                            Skill == data['professionOfStaff'] &&
                                            data['First_name'] != null &&
                                            data["Verified"] == "verified" &&
                                            data['First_name']
                                                .toString()
                                                .toLowerCase()
                                                .startsWith(
                                                SearchGlobal.toLowerCase())) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StaffProfilePage(
                                                              StaffID: UID,
                                                              Skill: data[
                                                              'professionOfStaff']),
                                                    ));
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
                                        } else if (data['professionOfStaff'] !=
                                            null &&
                                            Skill == data['professionOfStaff'] &&
                                            data["Verified"] == "verified" &&
                                            data['First_name'] != null &&
                                            data['City']
                                                .toString()
                                                .toLowerCase()
                                                .startsWith(
                                                SearchGlobal.toLowerCase())) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StaffProfilePage(
                                                              StaffID: UID,
                                                              Skill: data[
                                                              'professionOfStaff']),
                                                    ));
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
    );
  }
}
