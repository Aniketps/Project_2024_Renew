import 'package:carehub/StaffProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Deals extends StatefulWidget {
  const Deals({super.key});

  @override
  State<StatefulWidget> createState() => _Deals();
}

class _Deals extends State<Deals> {
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

    checkUserid();
    liveLocation();
  }

  Future<void> checkUserid() async {
    User? user = FirebaseAuth.instance.currentUser;

    var currentUserData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.uid)
        .get();
    if (currentUserData['professionOfStaff'] == null) {
      setState(() {
        isStaff = true;
        print(isStaff);
      });
    }
  }

  bool isStaff = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    var snapshot =
        await FirebaseFirestore.instance.collection("user").doc(uid).get();
    return snapshot.data();
  }

  Future<Map<String, dynamic>?> getStaffData(String skill, String uid) async {
    var snapshot =
        await FirebaseFirestore.instance.collection(skill).doc(uid).get();
    return snapshot.data();
  }

  bool isFilter = false;
  bool isAnyTime = false;
  bool isImmediately = false;

  String SearchGlobal = '';
  bool isRatingOpen = false;

  Widget Giverating(String uid, String docID) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            selectedUID = uid;
            selectedDoc = docID;
            isRatingOpen = true;
          });
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(7, 0, 0, 63),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text("Give Feedback"));
  }

  Future<void> reCountRating(String UID) async {
    var docSnapshot =
        await FirebaseFirestore.instance.collection("Ratings").doc(UID).get();

    if (!docSnapshot.exists) {
      print("Ratings document not found.");
      return;
    }

    var data = docSnapshot.data() as Map<String, dynamic>;

    // Fetch the star counts safely
    int firstStar = data['1Star'] ?? 0;
    int secondStar = data['2Star'] ?? 0;
    int thirdStar = data['3Star'] ?? 0;
    int fourthStar = data['4Star'] ?? 0;
    int fifthStar = data['5Star'] ?? 0;

    // Calculate weighted total
    int weightedTotal = (firstStar * 1) +
        (secondStar * 2) +
        (thirdStar * 3) +
        (fourthStar * 4) +
        (fifthStar * 5);

    // Calculate total number of ratings
    int totalCount =
        firstStar + secondStar + thirdStar + fourthStar + fifthStar;

    // Ensure totalCount is not zero to prevent division by zero
    double rating = (totalCount > 0) ? (weightedTotal / totalCount) : 0.0;

    // Fetch user profession
    var userDoc =
        await FirebaseFirestore.instance.collection("user").doc(UID).get();

    if (!userDoc.exists) {
      print("User document not found.");
      return;
    }

    var staffData = userDoc.data();
    if (staffData == null || !staffData.containsKey("professionOfStaff")) {
      print("professionOfStaff field is missing.");
      return;
    }

    // Update the rating in the respective profession collection
    await FirebaseFirestore.instance
        .collection(staffData["professionOfStaff"].toString())
        .doc(UID)
        .update({
      "Rating": rating.toStringAsFixed(2), // Rounds to 2 decimal places
    });

    print("Updated rating: $rating");
  }

  String selectedUID = '';
  String selectedDoc = '';

  void Rate(int rate) async {
    var data = await FirebaseFirestore.instance
        .collection("Ratings")
        .doc(selectedUID)
        .get();
    var userRecordDoc = await FirebaseFirestore.instance
        .collection("NotificationForUser")
        .doc(selectedDoc)
        .get();

    String staffRecordDoc = '';

    if (userRecordDoc.exists) {
      Map<String, dynamic>? data = userRecordDoc.data();
      staffRecordDoc = data?["DocUID"] ?? "";

      print(staffRecordDoc);
    } else {
      print("Document does not exist");
    }

    if (data.exists) {
      int oneStar = data["1Star"] ?? 0;
      int twoStar = data["2Star"] ?? 0;
      int threeStar = data["3Star"] ?? 0;
      int fourStar = data["4Star"] ?? 0;
      int fiveStar = data["5Star"] ?? 0;

      switch (rate) {
        case 1:
          oneStar += 1;
          FirebaseFirestore.instance
              .collection("Ratings")
              .doc(selectedUID)
              .update({
            "1Star": oneStar,
          });
          FirebaseFirestore.instance
              .collection("NotificationForUser")
              .doc(selectedDoc)
              .update({
            "Rating": rate.toString(),
          });
          FirebaseFirestore.instance
              .collection("NotificationForStaff")
              .doc(staffRecordDoc)
              .update({
            "Rating": rate.toString(),
          });
          reCountRating(selectedUID);
          setState(() {
            isRatingOpen = false;
          });
          break;
        case 2:
          twoStar += 1;
          FirebaseFirestore.instance
              .collection("Ratings")
              .doc(selectedUID)
              .update({
            "2Star": twoStar,
          });
          FirebaseFirestore.instance
              .collection("NotificationForUser")
              .doc(selectedDoc)
              .update({
            "Rating": rate.toString(),
          });
          FirebaseFirestore.instance
              .collection("NotificationForStaff")
              .doc(staffRecordDoc)
              .update({
            "Rating": rate.toString(),
          });
          reCountRating(selectedUID);
          setState(() {
            isRatingOpen = false;
          });
          break;
        case 3:
          threeStar += 1;
          FirebaseFirestore.instance
              .collection("Ratings")
              .doc(selectedUID)
              .update({
            "3Star": threeStar,
          });
          FirebaseFirestore.instance
              .collection("NotificationForUser")
              .doc(selectedDoc)
              .update({
            "Rating": rate.toString(),
          });
          FirebaseFirestore.instance
              .collection("NotificationForStaff")
              .doc(staffRecordDoc)
              .update({
            "Rating": rate.toString(),
          });
          reCountRating(selectedUID);
          setState(() {
            isRatingOpen = false;
          });
          break;
        case 4:
          fourStar += 1;
          FirebaseFirestore.instance
              .collection("Ratings")
              .doc(selectedUID)
              .update({
            "4Star": fourStar,
          });
          FirebaseFirestore.instance
              .collection("NotificationForUser")
              .doc(selectedDoc)
              .update({
            "Rating": rate.toString(),
          });
          FirebaseFirestore.instance
              .collection("NotificationForStaff")
              .doc(staffRecordDoc)
              .update({
            "Rating": rate.toString(),
          });
          reCountRating(selectedUID);
          setState(() {
            isRatingOpen = false;
          });
          break;
        case 5:
          fiveStar += 1;
          FirebaseFirestore.instance
              .collection("Ratings")
              .doc(selectedUID)
              .update({
            "5Star": fiveStar,
          });
          FirebaseFirestore.instance
              .collection("NotificationForUser")
              .doc(selectedDoc)
              .update({
            "Rating": rate.toString(),
          });
          FirebaseFirestore.instance
              .collection("NotificationForStaff")
              .doc(staffRecordDoc)
              .update({
            "Rating": rate.toString(),
          });
          reCountRating(selectedUID);
          setState(() {
            isRatingOpen = false;
          });
          break;
        default:
          print("Invalid rating value");
      }
    } else {
      print("No data found for the selected UID");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: const Color(0xfffffcc9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Center(
                      child: Text("Deals History",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  backgroundColor: const Color(0xfffffcc9),
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 125),
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // Search bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    width: screenWidth * 0.7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("NotificationForUser")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              var users =
                                  snapshot.data?.docs.reversed.toList() ?? [];
                              List<Widget> userViews = [];

                              for (var user in users) {
                                if (user["userUID"] == uid &&
                                    user['status'] == "Completed") {
                                  userViews.add(
                                    FutureBuilder(
                                      future: Future.wait([
                                        getUserData(user['userUID']),
                                        getStaffData(user['professionOfStaff'],
                                            user['staffUID']),
                                      ]),
                                      builder: (context,
                                          AsyncSnapshot<List<dynamic>>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }

                                        var currentUserData = snapshot.data?[0];
                                        var currentStaffData =
                                            snapshot.data?[1];
                                        if (SearchGlobal != '') {
                                          isImmediately = false;
                                          isAnyTime = false;
                                          if (currentStaffData['First_name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .startsWith(SearchGlobal
                                                      .toLowerCase()) ||
                                              currentStaffData['Last_name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .startsWith(SearchGlobal
                                                      .toLowerCase()) ||
                                              currentStaffData['City']
                                                  .toString()
                                                  .toLowerCase()
                                                  .startsWith(SearchGlobal
                                                      .toLowerCase())) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Container(
                                                        height:
                                                            screenHeight * 0.37,
                                                        width:
                                                            screenWidth * 0.9,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              spreadRadius: 1,
                                                              blurRadius: 1,
                                                            )
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 20),
                                                              child: SizedBox(
                                                                height:
                                                                    screenHeight *
                                                                        0.1,
                                                                width:
                                                                    screenWidth *
                                                                        0.85,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          70,
                                                                      width: 70,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(70),
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.black26,
                                                                            blurRadius:
                                                                                1,
                                                                            spreadRadius:
                                                                                1,
                                                                          )
                                                                        ],
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              NetworkImage(currentStaffData['Profile_Pic']),
                                                                          fit: BoxFit
                                                                              .cover, // Adjust the fit if necessary
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                          ),
                                                                          Text(
                                                                              currentStaffData['Status'] ? "Available" : "Busy",
                                                                              style: const TextStyle(fontSize: 10, color: Colors.green)),
                                                                          Text(
                                                                              "${user['timeofdeal']}",
                                                                              style: const TextStyle(fontSize: 12)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Text(
                                                                              "For",
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                                          const Divider(),
                                                                          Text(
                                                                            "${user['professionOfStaff']}",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                            style: const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 18,
                                                                                color: Colors.red),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              25,
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width:
                                                                        screenWidth *
                                                                            0.25,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius: BorderRadius.circular(5),
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                              color: Colors.black26,
                                                                              blurRadius: 1,
                                                                              spreadRadius: 1)
                                                                        ]),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "${user['ServiceBase']} base",
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 80,
                                                              width:
                                                                  screenWidth *
                                                                      0.75,
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                Text("${user['ServiceBase']}")),
                                                                        Text(
                                                                            "${user['hours']}"),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        const Text(
                                                                            "Total",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 10),
                                                                          child: Text(
                                                                              "Know more",
                                                                              style: TextStyle(color: Colors.green)),
                                                                        ),
                                                                        const Spacer(),
                                                                        Text(
                                                                            "${user['totalcost']}",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  user["Rating"] ==
                                                                          "0"
                                                                      ? Giverating(
                                                                          user[
                                                                              "staffUID"],
                                                                          user.id)
                                                                      : Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "Overall Service Rating",
                                                                              style: TextStyle(fontSize: 12),
                                                                            ),
                                                                            user["Rating"] == "5"
                                                                                ? Row(
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                : user["Rating"] == "4"
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : user["Rating"] == "3"
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                color: Color(0xffFFD700),
                                                                                              ),
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                color: Color(0xffFFD700),
                                                                                              ),
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                color: Color(0xffFFD700),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : user["Rating"] == "2"
                                                                                            ? Row(
                                                                                                children: [
                                                                                                  Icon(
                                                                                                    Icons.star,
                                                                                                    color: Color(0xffFFD700),
                                                                                                  ),
                                                                                                  Icon(
                                                                                                    Icons.star,
                                                                                                    color: Color(0xffFFD700),
                                                                                                  ),
                                                                                                ],
                                                                                              )
                                                                                            : Row(
                                                                                                children: [
                                                                                                  Icon(
                                                                                                    Icons.star,
                                                                                                    color: Color(0xffFFD700),
                                                                                                  )
                                                                                                ],
                                                                                              )
                                                                          ],
                                                                        ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            25),
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => StaffProfilePage(StaffID: user['staffUID'], Skill: currentStaffData['professionOfStaff']),
                                                                              ));
                                                                        },
                                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                        child: const Text(
                                                                          "Deal Again",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }
                                        } else {
                                          if (isImmediately) {
                                            if (currentStaffData['Status']) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Container(
                                                          height: screenHeight *
                                                              0.37,
                                                          width:
                                                              screenWidth * 0.9,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                spreadRadius: 1,
                                                                blurRadius: 1,
                                                              )
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            20),
                                                                child: SizedBox(
                                                                  height:
                                                                      screenHeight *
                                                                          0.1,
                                                                  width:
                                                                      screenWidth *
                                                                          0.85,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            70,
                                                                        width:
                                                                            70,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(70),
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                              color: Colors.black26,
                                                                              blurRadius: 1,
                                                                              spreadRadius: 1,
                                                                            )
                                                                          ],
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                NetworkImage(currentStaffData['Profile_Pic']),
                                                                            fit:
                                                                                BoxFit.cover, // Adjust the fit if necessary
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                            Text(currentStaffData['Status'] ? "Available" : "Busy",
                                                                                style: const TextStyle(fontSize: 10, color: Colors.green)),
                                                                            Text("${user['timeofdeal']}",
                                                                                style: const TextStyle(fontSize: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            const Text("For",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                                            const Divider(),
                                                                            Text(
                                                                              "${user['professionOfStaff']}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            25,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          30,
                                                                      width: screenWidth *
                                                                          0.25,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                                color: Colors.black26,
                                                                                blurRadius: 1,
                                                                                spreadRadius: 1)
                                                                          ]),
                                                                      child: Center(
                                                                          child: Text(
                                                                        "${user['ServiceBase']} base",
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 80,
                                                                width:
                                                                    screenWidth *
                                                                        0.75,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: Text("${user['ServiceBase']}")),
                                                                          Text(
                                                                              "${user['hours']}"),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Text(
                                                                              "Total",
                                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                                          const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 10),
                                                                            child:
                                                                                Text("Know more", style: TextStyle(color: Colors.green)),
                                                                          ),
                                                                          const Spacer(),
                                                                          Text(
                                                                              "${user['totalcost']}",
                                                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    user["Rating"] ==
                                                                            "0"
                                                                        ? Giverating(
                                                                            user["staffUID"],
                                                                            user.id)
                                                                        : Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Overall Service Rating",
                                                                                style: TextStyle(fontSize: 12),
                                                                              ),
                                                                              user["Rating"] == "5"
                                                                                  ? Row(
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : user["Rating"] == "4"
                                                                                      ? Row(
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : user["Rating"] == "3"
                                                                                          ? Row(
                                                                                              children: [
                                                                                                Icon(
                                                                                                  Icons.star,
                                                                                                  color: Color(0xffFFD700),
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.star,
                                                                                                  color: Color(0xffFFD700),
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.star,
                                                                                                  color: Color(0xffFFD700),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          : user["Rating"] == "2"
                                                                                              ? Row(
                                                                                                  children: [
                                                                                                    Icon(
                                                                                                      Icons.star,
                                                                                                      color: Color(0xffFFD700),
                                                                                                    ),
                                                                                                    Icon(
                                                                                                      Icons.star,
                                                                                                      color: Color(0xffFFD700),
                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              : Row(
                                                                                                  children: [
                                                                                                    Icon(
                                                                                                      Icons.star,
                                                                                                      color: Color(0xffFFD700),
                                                                                                    )
                                                                                                  ],
                                                                                                )
                                                                            ],
                                                                          ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              25),
                                                                      child: ElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => StaffProfilePage(StaffID: user['staffUID'], Skill: currentStaffData['professionOfStaff']),
                                                                                ));
                                                                          },
                                                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                          child: const Text(
                                                                            "Deal Again",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                          )),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                          }
                                          if (isAnyTime) {
                                            if (!currentStaffData['Status']) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Container(
                                                          height: screenHeight *
                                                              0.37,
                                                          width:
                                                              screenWidth * 0.9,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                spreadRadius: 1,
                                                                blurRadius: 1,
                                                              )
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            20),
                                                                child: SizedBox(
                                                                  height:
                                                                      screenHeight *
                                                                          0.1,
                                                                  width:
                                                                      screenWidth *
                                                                          0.85,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            70,
                                                                        width:
                                                                            70,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(70),
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                              color: Colors.black26,
                                                                              blurRadius: 1,
                                                                              spreadRadius: 1,
                                                                            )
                                                                          ],
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                NetworkImage(currentStaffData['Profile_Pic']),
                                                                            fit:
                                                                                BoxFit.cover, // Adjust the fit if necessary
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                            Text(currentStaffData['Status'] ? "Available" : "Busy",
                                                                                style: const TextStyle(fontSize: 10, color: Colors.green)),
                                                                            Text("${user['timeofdeal']}",
                                                                                style: const TextStyle(fontSize: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            const Text("For",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                                            const Divider(),
                                                                            Text(
                                                                              "${user['professionOfStaff']}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            25,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          30,
                                                                      width: screenWidth *
                                                                          0.25,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                                color: Colors.black26,
                                                                                blurRadius: 1,
                                                                                spreadRadius: 1)
                                                                          ]),
                                                                      child: Center(
                                                                          child: Text(
                                                                        "${user['ServiceBase']} base",
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 80,
                                                                width:
                                                                    screenWidth *
                                                                        0.75,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: Text("${user['ServiceBase']}")),
                                                                          Text(
                                                                              "${user['hours']}"),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Text(
                                                                              "Total",
                                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                                          const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 10),
                                                                            child:
                                                                                Text("Know more", style: TextStyle(color: Colors.green)),
                                                                          ),
                                                                          const Spacer(),
                                                                          Text(
                                                                              "${user['totalcost']}",
                                                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    user["Rating"] ==
                                                                            "0"
                                                                        ? Giverating(
                                                                            user["staffUID"],
                                                                            user.id)
                                                                        : Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Overall Service Rating",
                                                                                style: TextStyle(fontSize: 12),
                                                                              ),
                                                                              user["Rating"] == "5"
                                                                                  ? Row(
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.star,
                                                                                          color: Color(0xffFFD700),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : user["Rating"] == "4"
                                                                                      ? Row(
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: Color(0xffFFD700),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : user["Rating"] == "3"
                                                                                          ? Row(
                                                                                              children: [
                                                                                                Icon(
                                                                                                  Icons.star,
                                                                                                  color: Color(0xffFFD700),
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.star,
                                                                                                  color: Color(0xffFFD700),
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.star,
                                                                                                  color: Color(0xffFFD700),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          : user["Rating"] == "2"
                                                                                              ? Row(
                                                                                                  children: [
                                                                                                    Icon(
                                                                                                      Icons.star,
                                                                                                      color: Color(0xffFFD700),
                                                                                                    ),
                                                                                                    Icon(
                                                                                                      Icons.star,
                                                                                                      color: Color(0xffFFD700),
                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              : Row(
                                                                                                  children: [
                                                                                                    Icon(
                                                                                                      Icons.star,
                                                                                                      color: Color(0xffFFD700),
                                                                                                    )
                                                                                                  ],
                                                                                                )
                                                                            ],
                                                                          ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              25),
                                                                      child: ElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => StaffProfilePage(StaffID: user['staffUID'], Skill: currentStaffData['professionOfStaff']),
                                                                                ));
                                                                          },
                                                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                          child: const Text(
                                                                            "Deal Again",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                          )),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                          }
                                          if (!isImmediately && !isAnyTime) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Container(
                                                        height:
                                                            screenHeight * 0.37,
                                                        width:
                                                            screenWidth * 0.9,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              spreadRadius: 1,
                                                              blurRadius: 1,
                                                            )
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 20),
                                                              child: SizedBox(
                                                                height:
                                                                    screenHeight *
                                                                        0.1,
                                                                width:
                                                                    screenWidth *
                                                                        0.85,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          70,
                                                                      width: 70,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(70),
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.black26,
                                                                            blurRadius:
                                                                                1,
                                                                            spreadRadius:
                                                                                1,
                                                                          )
                                                                        ],
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              NetworkImage(currentStaffData['Profile_Pic']),
                                                                          fit: BoxFit
                                                                              .cover, // Adjust the fit if necessary
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                          ),
                                                                          Text(
                                                                              currentStaffData['Status'] ? "Available" : "Busy",
                                                                              style: const TextStyle(fontSize: 10, color: Colors.green)),
                                                                          Text(
                                                                              "${user['timeofdeal']}",
                                                                              style: const TextStyle(fontSize: 12)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Text(
                                                                              "For",
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                                          const Divider(),
                                                                          Text(
                                                                            "${user['professionOfStaff']}",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                            style: const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 18,
                                                                                color: Colors.red),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              25,
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width:
                                                                        screenWidth *
                                                                            0.25,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius: BorderRadius.circular(5),
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                              color: Colors.black26,
                                                                              blurRadius: 1,
                                                                              spreadRadius: 1)
                                                                        ]),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "${user['ServiceBase']} base",
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 80,
                                                              width:
                                                                  screenWidth *
                                                                      0.75,
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                Text("${user['ServiceBase']}")),
                                                                        Text(
                                                                            "${user['hours']}"),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        const Text(
                                                                            "Total",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 10),
                                                                          child: Text(
                                                                              "Know more",
                                                                              style: TextStyle(color: Colors.green)),
                                                                        ),
                                                                        const Spacer(),
                                                                        Text(
                                                                            "${user['totalcost']}",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  user["Rating"] ==
                                                                          "0"
                                                                      ? Giverating(
                                                                          user[
                                                                              "staffUID"],
                                                                          user.id)
                                                                      : Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "Overall Service Rating",
                                                                              style: TextStyle(fontSize: 12),
                                                                            ),
                                                                            user["Rating"] == "5"
                                                                                ? Row(
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.star,
                                                                                        color: Color(0xffFFD700),
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                : user["Rating"] == "4"
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.star,
                                                                                            color: Color(0xffFFD700),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : user["Rating"] == "3"
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                color: Color(0xffFFD700),
                                                                                              ),
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                color: Color(0xffFFD700),
                                                                                              ),
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                color: Color(0xffFFD700),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : user["Rating"] == "2"
                                                                                            ? Row(
                                                                                                children: [
                                                                                                  Icon(
                                                                                                    Icons.star,
                                                                                                    color: Color(0xffFFD700),
                                                                                                  ),
                                                                                                  Icon(
                                                                                                    Icons.star,
                                                                                                    color: Color(0xffFFD700),
                                                                                                  ),
                                                                                                ],
                                                                                              )
                                                                                            : Row(
                                                                                                children: [
                                                                                                  Icon(
                                                                                                    Icons.star,
                                                                                                    color: Color(0xffFFD700),
                                                                                                  )
                                                                                                ],
                                                                                              )
                                                                          ],
                                                                        ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            25),
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => StaffProfilePage(StaffID: user['staffUID'], Skill: currentStaffData['professionOfStaff']),
                                                                              ));
                                                                        },
                                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                        child: const Text(
                                                                          "Deal Again",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }
                                        }
                                        return Container();
                                      },
                                    ),
                                  );
                                }
                              }
                              return Column(children: userViews);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              isRatingOpen
                  ? Center(
                      child: Container(
                        height: 90,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                Rate(1);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Image.asset("assets/Rating/star1.png",
                                    height: 30, width: 30),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Rate(2);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Image.asset("assets/Rating/star2.png",
                                    height: 30, width: 30),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Rate(3);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Image.asset("assets/Rating/star3.png",
                                    height: 30, width: 30),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Rate(4);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Image.asset("assets/Rating/star4.png",
                                    height: 30, width: 30),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Rate(5);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Image.asset("assets/Rating/star5.png",
                                    height: 30, width: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              isFilter
                  ? Positioned(
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.only(top: 180),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topLeft: Radius.circular(15)),
                            border: Border.all(color: Colors.blue, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Availability",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.blue,
                                                spreadRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Immediately"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.blue,
                                                spreadRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Any Time"),
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
            ],
          )
        ],
      ),
    );
  }
}

class DealsForStaff extends StatefulWidget {
  const DealsForStaff({super.key});

  @override
  State<StatefulWidget> createState() => _DealsForStaff();
}

class _DealsForStaff extends State<DealsForStaff> {
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

    checkUserid();
    liveLocation();
  }

  Future<void> checkUserid() async {
    User? user = FirebaseAuth.instance.currentUser;

    var currentUserData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.uid)
        .get();
    if (currentUserData['professionOfStaff'] == null) {
      setState(() {
        isStaff = true;
        print(isStaff);
      });
    }
  }

  bool isStaff = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    var snapshot =
        await FirebaseFirestore.instance.collection("user").doc(uid).get();
    return snapshot.data();
  }

  bool isFilter = false;
  bool isAnyTime = false;
  bool isImmediately = false;

  Future<Map<String, dynamic>?> getStaffData(String skill, String uid) async {
    var snapshot =
        await FirebaseFirestore.instance.collection(skill).doc(uid).get();
    return snapshot.data();
  }

  String SearchGlobal = '';
  bool knowMore = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: const Color(0xfffffcc9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Center(
                      child: Text("Deals History",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  backgroundColor: const Color(0xfffffcc9),
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 125),
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // Search bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    width: screenWidth * 0.7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("NotificationForStaff")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              var users =
                                  snapshot.data?.docs.reversed.toList() ?? [];
                              List<Widget> userViews = [];

                              for (var user in users) {
                                if (user["staffUID"] == uid &&
                                    user['status'] == "Completed") {
                                  print("Current user " + user["staffUID"]);
                                  print(uid);
                                  userViews.add(
                                    FutureBuilder(
                                      future: Future.wait([
                                        getUserData(user['userUID']),
                                        getStaffData(user['professionOfStaff'],
                                            user['staffUID']),
                                      ]),
                                      builder: (context,
                                          AsyncSnapshot<List<dynamic>>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }

                                        var currentStaffData =
                                            snapshot.data?[0];
                                        var currentUserData = snapshot.data?[1];

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Container(
                                                    height: screenHeight * 0.37,
                                                    width: screenWidth * 0.9,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          spreadRadius: 1,
                                                          blurRadius: 1,
                                                        )
                                                      ],
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20),
                                                          child: SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.1,
                                                            width: screenWidth *
                                                                0.85,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height: 70,
                                                                  width: 70,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            70),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black26,
                                                                        blurRadius:
                                                                            1,
                                                                        spreadRadius:
                                                                            1,
                                                                      )
                                                                    ],
                                                                    image:
                                                                        DecorationImage(
                                                                      image: currentStaffData['Profile_Pic'] ==
                                                                                  null &&
                                                                              currentStaffData ==
                                                                                  null
                                                                          ? const NetworkImage(
                                                                              "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=")
                                                                          : NetworkImage(
                                                                              currentStaffData['Profile_Pic']),
                                                                      fit: BoxFit
                                                                          .cover, // Adjust the fit if necessary
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 16),
                                                                      ),
                                                                      Text(
                                                                          "${user['timeofdeal']}",
                                                                          style:
                                                                              const TextStyle(fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Text(
                                                                          "For",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 12)),
                                                                      const Divider(),
                                                                      Text(
                                                                        "${user['professionOfStaff']}",
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 25,
                                                                      top: 5,
                                                                      bottom:
                                                                          5),
                                                              child: Container(
                                                                height: 30,
                                                                width:
                                                                    screenWidth *
                                                                        0.25,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .black26,
                                                                          blurRadius:
                                                                              1,
                                                                          spreadRadius:
                                                                              1)
                                                                    ]),
                                                                child: Center(
                                                                    child: Text(
                                                                  "${user['ServiceBase']} base",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 80,
                                                          width: screenWidth *
                                                              0.75,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child: Text(
                                                                            "${user['ServiceBase']}")),
                                                                    Text(
                                                                        "${user['hours']}"),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Divider(),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    const Text(
                                                                        "Total",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            knowMore =
                                                                                true;
                                                                          });
                                                                        },
                                                                        child: const Text(
                                                                            "Know more",
                                                                            style:
                                                                                TextStyle(color: Colors.green)),
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                        "${user['totalcost']}",
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Divider(),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 30),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Overall Service Rating",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Color(
                                                                            0xffFFD700),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Color(
                                                                            0xffFFD700),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Color(
                                                                            0xffFFD700),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Color(
                                                                            0xffFFD700),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Color(
                                                                            0xffFFD700),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              isStaff
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              25),
                                                                      child: ElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => StaffProfilePage(StaffID: user['staffUID'], Skill: currentStaffData['professionOfStaff']),
                                                                                ));
                                                                          },
                                                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                          child: const Text(
                                                                            "Deal Again",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                          )),
                                                                    )
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                }
                              }
                              return Column(children: userViews);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              isFilter
                  ? Positioned(
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.only(top: 180),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topLeft: Radius.circular(15)),
                            border: Border.all(color: Colors.blue, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Availability",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.blue,
                                                spreadRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Immediately"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.blue,
                                                spreadRadius: 1)
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Any Time"),
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
              SearchGlobal == ''
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
                                    return const Center(
                                      child: CircularProgressIndicator(),
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
                                      return Container();
                                    },
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
              knowMore
                  ? Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            knowMore = false;
                          });
                        },
                        child: Container(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.7,
                          decoration: const BoxDecoration(),
                        ),
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }
}
