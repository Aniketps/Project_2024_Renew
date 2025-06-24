import 'package:carehub/LoaderSupport.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'StaffProfilePage.dart';
import 'globle.dart';

class EServiceRate extends StatefulWidget {
  var Skill;
  EServiceRate({required this.Skill});

  @override
  State<EServiceRate> createState() => _EServiceRateState(Skill: Skill);
}

class _EServiceRateState extends State<EServiceRate> {
  TextEditingController HourRate = TextEditingController();
  TextEditingController DayRate = TextEditingController();
  TextEditingController DayShift = TextEditingController();
  TextEditingController TravelingCharges = TextEditingController();
  bool loading = false;

  var Skill;
  _EServiceRateState({required this.Skill});

  Currency? _selectedCurrency;
  void _showCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true, // show country flag
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          _selectedCurrency = currency;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenHeight = mediaquery.size.height;
    final screenWidth = mediaquery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Globle.theme,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: Center(
                    child: Text("Professional",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  backgroundColor: Globle.theme,
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: screenHeight * 0.9,
                              width: screenWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 10, bottom: 5),
                                      child: Text(
                                        "Make Changes",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: HourRate,
                                          decoration: InputDecoration(
                                            labelText: "Hour Rate",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: DayRate,
                                          decoration: InputDecoration(
                                            labelText: "Day service rate",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: DayShift,
                                          decoration: InputDecoration(
                                            labelText: "Hours in a day shift",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: Container(
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: TravelingCharges,
                                          decoration: InputDecoration(
                                            labelText: "Traveling Charges",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                20, 16, 16, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.85, // 80% width
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5), // Border radius of 5
                                          ),
                                        ),
                                        onPressed: _showCurrencyPicker,
                                        child: Text(
                                          _selectedCurrency == null
                                              ? 'Pick a currency'
                                              : '${_selectedCurrency!.name} (${_selectedCurrency!.code})',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 25, top: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              setState(() {
                                                loading = true;
                                              });
                                              if (HourRate.text.isNotEmpty &&
                                                  DayRate.text.isNotEmpty &&
                                                  DayShift.text.isNotEmpty &&
                                                  TravelingCharges
                                                      .text.isNotEmpty && _selectedCurrency != null) {
                                                try {
                                                  User? user = FirebaseAuth
                                                      .instance.currentUser;
                                                  if (user != null) {
                                                    String currentUID =
                                                        user.uid;
                                                    int hourRate = int.parse(
                                                        HourRate.text);
                                                    int dayRate =
                                                        int.parse(DayRate.text);
                                                    int dayShift = int.parse(
                                                        DayShift.text);
                                                    int travelingCharges =
                                                        int.parse(
                                                            TravelingCharges
                                                                .text);

                                                    // Update Firebase Firestore
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(Skill)
                                                        .doc(currentUID)
                                                        .update({
                                                      "Hour_Rate": hourRate,
                                                      "Day_Rate": dayRate,
                                                      "Day_Shift": dayShift,
                                                      "Traveling_Charges":
                                                          travelingCharges,
                                                      "Currency" : _selectedCurrency!.code
                                                    });

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('user')
                                                        .doc(currentUID)
                                                        .update({
                                                      "Hour_Rate": hourRate,
                                                      "Day_Rate": dayRate,
                                                      "Day_Shift": dayShift,
                                                      "Traveling_Charges":
                                                          travelingCharges,
                                                      "Currency" : _selectedCurrency!.code
                                                    });
                                                    // Navigate to Staff Profile Page
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Navigator.pop(context);
                                                  } else {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                      msg: "No user logged in",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                    );
                                                  }
                                                } catch (e) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "$e",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                  );
                                                }
                                              } else {
                                                setState(() {
                                                  loading = false;
                                                });
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "Please fill all fields with valid numbers",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
          loading
              ? Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Center(child: LoaderSupport.loadingAnimation.widget),
          )
              : Container(),
        ],
      ),
    );
  }
}
