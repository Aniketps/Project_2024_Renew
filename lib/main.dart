import 'package:carehub/Deals.dart';
import 'package:carehub/StaffPage.dart';
import 'package:carehub/Feedback.dart';
import 'package:carehub/services/NotificationService.dart';
import 'package:carehub/services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'ContactUs.dart';
import 'MainMap.dart';
import 'StaffProfilePage.dart';
import 'SubMap.dart';
import 'TC.dart';
import 'api/firebase_api.dart';
import 'client.dart';
import 'firebase_options.dart';
import 'LoginPage.dart';

@pragma('vm:entry-point')
Future<void> _firebasebackgroundhandler(RemoteMessage message)async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundhandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String SearchGlobal = '';
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    FcmService.FirebaseInit();

    SearchStaff();
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
    };
    _liveLocation();
  }

  List<String> Profession = [
    "Chef",
    "Personal Care Assistants",
    "Driver",
    "Security Guards",
    "Home Guards",
    "Elder Companions",
    "Babysitters",
    "Cleaner",
    "Housekeepers",
    "Elderly",
    "Paramedics",
    "Occupational Therapists",
    "Physiotherapists",
    "Home Health Aides",
    "Certified Nursing Assistants",
    "Licensed Practical Nurses",
    "Registered Nurses"
  ];
  List<String> ProfessionBack = [
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2Fchef.png?alt=media&token=dc1537c3-7702-4e18-af59-52418a5b10f8",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FPersonal%20Care%20Assistance.png?alt=media&token=72ff2a8b-7270-4599-bb4c-f915cdd362bb",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2Fdriver.png?alt=media&token=909ddaad-4d41-458c-a291-e38a1dc7a987",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2Fsecuritygaurd.jpeg?alt=media&token=36451ce8-f9df-4359-9d9c-1f7fd87a18e0",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2Fhouse%20gaurd.jpeg?alt=media&token=7a6bd94a-ff6b-45dc-8f67-2091f4521209",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2010.26.09%20-%20A%20professional%20banner%20showing%20an%20elderly%20individual%20receiving%20care%20from%20a%20single%20staff%20member.%20The%20caregiver%20is%20portrayed%20warmly%20assisting%20the%20senior%20.png?alt=media&token=7c74601b-a907-434c-ba74-13d95b6130e6",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2Fbabysitter.jpeg?alt=media&token=a627c925-57a4-4b5c-baed-13325fc3b081",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2010.30.13%20-%20A%20professional%20oil-painting-style%20background%20banner%20featuring%20a%20housekeeper%20in%20a%20modern%2C%20sophisticated%20home%20setting.%20The%20housekeeper%20is%20wearing%20a%20form.png?alt=media&token=91c66206-706d-450e-87d3-a38269599376",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2Fhouse%20keeper.jpeg?alt=media&token=ba8bafa1-e40b-442c-b3d9-9b4f484d8450",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2010.26.03%20-%20A%20professional%20banner%20showing%20an%20elderly%20individual%20being%20assisted%20by%20a%20single%20staff%20member%2C%20conveying%20warmth%2C%20empathy%2C%20and%20personalized%20care.%20The%20ima.png?alt=media&token=a44e5d9d-0a28-41a3-bf3e-d7958d72397f",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2010.19.17%20-%20A%20professional%20banner%20in%20an%20oil%20painting%20style%20featuring%20a%20paramedic%20in%20a%20modern%20uniform%20standing%20confidently%20with%20medical%20equipment.%20The%20paramedic%20is.png?alt=media&token=f3e70c44-cff8-4a31-b5e1-2f5058854503",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2010.15.14%20-%20A%20refined%20professional%20banner%20image%20featuring%20an%20occupational%20therapist%20in%20an%20oil%20paint%20style.%20The%20therapist%20is%20assisting%20a%20patient%20with%20exercises%20in%20.png?alt=media&token=f4a3c1fb-1e16-4e56-94f8-0c5d7a83ea9e",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2021.59.01%20-%20A%20professional%20oil%20painting%20style%20banner%20featuring%20a%20physiotherapist%20assisting%20a%20patient%20in%20a%20calm%2C%20modern%20clinic%20setting.%20The%20physiotherapist%20is%20demo.png?alt=media&token=26205d6e-bc64-4a41-abde-a21b9bf98a8d",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2010.10.17%20-%20A%20professional%20background%20banner%20image%20for%20a%20healthcare%20application%20featuring%20home%20health%20aides%20in%20an%20oil%20painting%20style%20with%20enhanced%20blue%20watercolor.png?alt=media&token=bc4d0507-cc70-4961-9616-73d1cfa77700",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2021.38.26%20-%20A%20professional%2C%20oil-paint%20style%20image%20of%20a%20Certified%20Nursing%20Assistant%20(CNA)%20providing%20care%20in%20a%20modern%20healthcare%20setting.%20The%20CNA%20is%20shown%20attending.png?alt=media&token=2021a3c7-fd31-4c8f-8a59-386fe8a557a5",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2021.47.57%20-%20A%20professional%20oil-paint-style%20banner%20image%20for%20a%20healthcare%20application%2C%20showing%20a%20Licensed%20Practical%20Nurse%20(LPN)%20providing%20one-on-one%20assistance%20to%20.png?alt=media&token=1341665f-1c3a-4a5a-8e04-442e5d38b6ea",
    "https://firebasestorage.googleapis.com/v0/b/carehub-af7ec.appspot.com/o/professions%2FDALL%C2%B7E%202024-10-24%2021.52.06%20-%20A%20professional%20banner%20image%20with%20an%20oil%20painting%20style%20featuring%20a%20registered%20nurse.%20The%20nurse%20is%20wearing%20a%20neat%20uniform%20with%20a%20stethoscope%20around%20the.png?alt=media&token=a30a228b-88c5-485c-b98b-9546f93c9546",
    "img.png",
  ];

  var StaffData;
  var documentID;
  late String currentUserID;

  Future<void> SearchStaff() async {
    User? user1 = await FirebaseAuth.instance.currentUser;
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
        print("No staff found with ID: $currentUserID");
      }
    } catch (e) {
      print("Error fetching user by Staff ID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: Drawer(
        width: screenWidth * 0.7,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Color(0xfffffcc9)),
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
                              boxShadow: [
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
                                  builder: (context) => ActualUser(),
                                ));
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 1,
                                  spreadRadius: 1,
                                  color: Colors.black26,
                                ),
                              ],
                              image: StaffData != null && StaffData['Profile_Pic'] != null
                                  ? DecorationImage(
                                image: NetworkImage(StaffData['Profile_Pic']),
                                fit: BoxFit.cover, // Adjust the fit if necessary
                              )
                                  : null,
                            ),
                          ),
                        ),
                  (StaffData == null)
                      ? Text(
                          "Empty",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : Text(
                          "${StaffData['First_name']} ${StaffData['Last_name']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ])),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Deals'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Deals(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUs(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Terms and Conditions'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TC(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Feedbacks(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
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
            color: Color(0xfffffcc9),
            child: AppBar(
              title: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMap(),
                        ));
                  },
                  child: Text(
                      (StaffData != null && StaffData['City'] != null)
                          ? StaffData['City']
                          : "Location...",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              backgroundColor: Color(0xfffffcc9),
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
                            boxShadow: [
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
                                builder: (context) => ActualUser(),
                              ));
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            image: StaffData != null && StaffData['Profile_Pic'] != null
                                ? DecorationImage(
                              image: NetworkImage(StaffData['Profile_Pic']),
                              fit: BoxFit.cover, // Adjust the fit if necessary
                            )
                                : null,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
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
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 1,
                                      color: Colors.black26,
                                      blurRadius: 1)
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
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
                                        hintText: 'Search...',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                height: 50,
                                width: screenWidth * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1,
                                        color: Colors.black26,
                                        blurRadius: 1),
                                  ],
                                ),
                                child: Icon(Icons.filter_list_sharp,
                                    size: 30, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Professions
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: Profession.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StaffPage(
                                            Skill: Profession[index]
                                                .toLowerCase()),
                                      ));
                                },
                                child: Container(
                                  height: 150,
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          spreadRadius: 1),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage("${ProfessionBack[index]}"),
                                      fit: BoxFit
                                          .cover, // Adjust the fit if necessary
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(Profession[index],
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 1,
                                                  color: Colors.black,
                                                  offset: Offset(1, 1))
                                            ])),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
                              width: screenWidth * 0.85,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
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
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text("No Users Found"),
                                    );
                                  }

                                  if (SearchGlobal.isEmpty) {
                                    return Center(child: Text("Empty"));
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index]
                                          .data() as Map<String, dynamic>;
                                      var UID = snapshot.data!.docs[index].id;
                                      if (data['professionOfStaff'] != null &&
                                          data['First_name'] != null &&
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
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
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
                                                    child: Container(
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
                                                      style: TextStyle(
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
                                                  boxShadow: [
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
                                                    child: Container(
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
                                                      style: TextStyle(
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
