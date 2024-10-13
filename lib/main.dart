import 'package:carehub/Deals.dart';
import 'package:carehub/StaffPage.dart';
import 'package:carehub/Feedback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'ContactUs.dart';
import 'MainMap.dart';
import 'StaffProfilePage.dart';
import 'SubMap.dart';
import 'TC.dart';
import 'firebase_options.dart';
import 'LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  @override
  void initState() {
    super.initState();
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

  List<String> Profession = [
    "Chef", "Personal Care Assistants", "Driver", "Security Guards",
    "Home Guards", "Elder Companions", "Babysitters", "Cleaner",
    "Housekeepers", "Elderly", "Paramedics", "Occupational Therapists",
    "Physiotherapists", "Home Health Aides", "Certified Nursing Assistants",
    "Licensed Practical Nurses", "Registered Nurses"
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
      CollectionReference documentSnapshotDish = await user.doc(currentUserID).collection("dishes");

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
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                children: [
              (StaffData != null && StaffData['Profile_Pic'] != null)
                  ? InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfilePage(StaffID: currentUserID, Skill:StaffData['professionOfStaff'] ?? 'user'),));
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
                      fit: BoxFit.cover, // Adjust the fit if necessary
                    ),
                                    ),
                                  ),
                  )
                  : Container(
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
                ),
              ),
                  (StaffData == null)?Text(
                    "Empty",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ):Text(
                    "${StaffData['First_name']} ${StaffData['Last_name']}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
              ]
              )
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Deals'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Deals(),));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUs(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Terms and Conditions'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TC(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Feedbacks(),));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 150,
            color: Colors.red,
            child: AppBar(
              title: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainMap(),));
                  },
                  child: Text((StaffData != null && StaffData['City'] != null)? StaffData['City'] : "Location...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              backgroundColor: Colors.red,
              automaticallyImplyLeading: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (StaffData != null && StaffData['Profile_Pic'] != null)? Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(StaffData['Profile_Pic']),
                      fit: BoxFit.cover, // Adjust the fit if necessary
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 1),
                    ],
                  ),
                ) : Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 1),
                    ],
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: screenWidth * 0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(spreadRadius: 1, color: Colors.black26, blurRadius: 1)
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Icon(Icons.search, color: Colors.blue, size: 25),
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
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    BoxShadow(spreadRadius: 1, color: Colors.black26, blurRadius: 1),
                                  ],
                                ),
                                child: Icon(Icons.filter_list_sharp, size: 30, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: Profession.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffPage(Skill: Profession[index].toLowerCase()),));
                                },
                                child: Container(
                                  height: 150,
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black26, blurRadius: 1, spreadRadius: 1),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(Profession[index], style: TextStyle(fontSize: 18)),
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
              SearchGlobal.isEmpty? Container() : Padding(
                padding: const EdgeInsets.only(top: 180,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: screenHeight * 0.5,
                        width: screenWidth * 0.85,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 2
                            )]
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('user').snapshots(),
                          builder: (context, snapshot) {

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text("No Users Found"),
                              );
                            }

                            if (SearchGlobal.isEmpty) {
                              return Center(child: Text("Empty"));
                            }

                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                var UID = snapshot.data!.docs[index].id;
                                if (data['professionOfStaff'] != null && data['First_name'] != null &&
                                    data['First_name'].toString().toLowerCase().startsWith(SearchGlobal.toLowerCase())) {
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfilePage(StaffID: UID, Skill: data['professionOfStaff']),));
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [BoxShadow(
                                            color: Colors.black26,
                                            spreadRadius: 1,
                                            blurRadius: 1
                                          )]
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(40),
                                                  image: DecorationImage(
                                                      image: NetworkImage(data['Profile_Pic']),
                                                      fit: BoxFit.cover
                                                  )
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Container(
                                                  width: 150,
                                              child: Text("${data['First_name']} ${data['Last_name']}", overflow: TextOverflow.ellipsis, maxLines: 1,)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text(data['City'][0].toUpperCase()+data['City'].substring(1), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                else if(data['professionOfStaff'] != null && data['First_name'] != null &&
                                    data['City'].toString().toLowerCase().startsWith(SearchGlobal.toLowerCase())){
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfilePage(StaffID: UID, Skill: data['professionOfStaff']),));
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [BoxShadow(
                                                color: Colors.black26,
                                                spreadRadius: 1,
                                                blurRadius: 1
                                            )]
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(40),
                                                    image: DecorationImage(
                                                        image: NetworkImage(data['Profile_Pic']),
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Container(
                                                  width: 150,
                                                  child: Text("${data['First_name']} ${data['Last_name']}", overflow: TextOverflow.ellipsis, maxLines: 1,)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text(data['City'][0].toUpperCase()+data['City'].substring(1), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
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
                        )

                    ),
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
