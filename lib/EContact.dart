import 'package:carehub/services/convertToTranslate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class EContact extends StatefulWidget {
  String Skill;
  EContact({super.key, required this.Skill});
  @override
  State<StatefulWidget> createState() => _EContact(Skill: Skill);
}

class _EContact extends State<EContact> {
  String Skill;
  _EContact({required this.Skill});
  DateTime? pickedDate;
  String selectedPhoneCode01 = "+91";
  String selectedPhoneCode02 = "+91";

  TextEditingController PrimeryNumber = TextEditingController();
  TextEditingController SeconderyNumber = TextEditingController();

  bool loading = false;
  List<String> PhoneCode = ["+91", "+1", "+44", "+52", "+86", "+33", "+63"];

  List<String> Gender = ["Male", "Female", "Bigender", "Lesbian", "Homosexual"];
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

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
                    child: Text("Contact Information".trKey,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
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
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 1,
                                      blurRadius: 1)
                                ]),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, top: 10, bottom: 5),
                                    child: Text(
                                      "Make Changes".trKey,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10, top: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 1,
                                                spreadRadius: 1)
                                          ]),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: CountryCodePicker(
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedPhoneCode01 = value.toString();
                                                });
                                              },
                                              initialSelection: '+91',
                                              favorite: ['+91'],
                                              showCountryOnly: false,
                                              showOnlyCountryWhenClosed: false,
                                              alignLeft: false,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: PrimeryNumber,
                                              decoration:
                                              InputDecoration(
                                                      hintText: "Primary Phone Number".trKey, // Placeholder text
                                                      border: InputBorder.none,
                                              )
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10, top: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 1,
                                                spreadRadius: 1)
                                          ]),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: CountryCodePicker(
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedPhoneCode02 = value.toString();
                                                });
                                              },
                                              initialSelection: '+91',
                                              favorite: ['+91'],
                                              showCountryOnly: false,
                                              showOnlyCountryWhenClosed: false,
                                              alignLeft: false,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: SeconderyNumber,
                                              decoration:
                                                  InputDecoration(
                                                      hintText: "Secondary Phone Number".trKey, // Placeholder text
                                                      border: InputBorder.none,
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              setState((){
                                                loading = true;
                                              });
                                              String PrimeryNum = PrimeryNumber.text == ""? PrimeryNumber.text : "$selectedPhoneCode01${PrimeryNumber.text}";
                                              String SeconderyNum = SeconderyNumber.text == ""? SeconderyNumber.text : "$selectedPhoneCode02${SeconderyNumber.text}";

                                                try {
                                                  User? user = FirebaseAuth
                                                      .instance.currentUser;
                                                  late String currentUID =
                                                      user?.uid ?? '';
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(Skill)
                                                      .doc(currentUID)
                                                      .update({
                                                    "Phone_Number1":
                                                        PrimeryNum,
                                                    "Phone_Number2":
                                                        SeconderyNum,
                                                  });
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('user')
                                                      .doc(currentUID)
                                                      .update({
                                                    "Phone_Number1":
                                                        PrimeryNum,
                                                    "Phone_Number2":
                                                        SeconderyNum,
                                                  });
                                                  setState((){
                                                    loading = false;
                                                  });
                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  setState((){
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
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.green),
                                            child:  Text(
                                              "Confirm".trKey,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
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
