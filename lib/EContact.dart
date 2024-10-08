import 'package:carehub/StaffProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EContact extends StatefulWidget {
  String Skill;
  EContact({required this.Skill});
  @override
  State<StatefulWidget> createState() => _EContact(Skill: Skill);
}

class _EContact extends State<EContact> {
  String Skill;
  _EContact({required this.Skill});
  DateTime? pickedDate;
  String? selectedPhoneCode01;
  String? selectedPhoneCode02;

  TextEditingController PrimeryNumber = TextEditingController();
  TextEditingController SeconderyNumber = TextEditingController();
  TextEditingController Email = TextEditingController();

  List<String> PhoneCode = ["+91", "+1", "+44",  "+52", "+86", "+33", "+63"];

  List<String> Gender = ["Male", "Female", "Bigender", "Lesbian", "Homosexual"];
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Information"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: screenHeight * 0.9,
            width: screenWidth,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 1
                )]
            ),
            child: SingleChildScrollView(
              scrollDirection:Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 5),
                    child: Text("Make Changes", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1,
                          spreadRadius: 1
                        )]
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              height: 50,
                              width: 60,
                              child: DropdownButton<String>(
                                value: selectedPhoneCode01,
                                items: PhoneCode.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 40,
                                      ),
                                      child: Text(
                                        item,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedPhoneCode01 = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: screenWidth * 0.45,
                            child: TextField(
                              controller: PrimeryNumber,
                              decoration: InputDecoration(
                                  hintText: "Primary Phone Number", // Placeholder text
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                              ),
                            ),
                          ),
                          ElevatedButton(onPressed: () {

                          }, style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red
                          ),child: Text("Send", style: TextStyle(color:Colors.white),))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(onPressed: () {

                        }, style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red
                        ),
                            child: Text("Resend", style: TextStyle(color: Colors.white),)),
                        Container(
                          height: 50,
                          width: screenWidth * 0.45,
                          child: TextField(
                              controller: PrimeryNumber,
                              decoration: InputDecoration(
                                  hintText: "OTP", // Placeholder text
                                  border: OutlineInputBorder(
                                    borderRadius:  BorderRadius.circular(10)
                                  ),
                                  contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                              color: Colors.black26,
                              blurRadius: 1,
                              spreadRadius: 1
                          )]
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              height: 50,
                              width: 60,
                              child: DropdownButton<String>(
                                value: selectedPhoneCode02,
                                items: PhoneCode.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 40,
                                      ),
                                      child: Text(
                                        item,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedPhoneCode02 = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: screenWidth * 0.45,
                            child: TextField(
                              controller: SeconderyNumber,
                              decoration: InputDecoration(
                                  hintText: "Secondary Phone Number", // Placeholder text
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                              ),
                            ),
                          ),
                          ElevatedButton(onPressed: () {

                          }, style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red
                          ),child: Text("Send", style: TextStyle(color:Colors.white),))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(onPressed: () {

                        }, style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red
                        ),
                            child: Text("Resend", style: TextStyle(color: Colors.white),)),
                        Container(
                          height: 50,
                          width: screenWidth * 0.45,
                          child: TextField(
                            controller: PrimeryNumber,
                            decoration: InputDecoration(
                                hintText: "OTP", // Placeholder text
                                border: OutlineInputBorder(
                                    borderRadius:  BorderRadius.circular(10)
                                ),
                                contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                              color: Colors.black26,
                              blurRadius: 1,
                              spreadRadius: 1
                          )]
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: screenWidth * 0.60,
                            child: TextField(
                              controller: Email,
                              decoration: InputDecoration(
                                  hintText: "Email", // Placeholder text
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                              ),
                            ),
                          ),
                          ElevatedButton(onPressed: () {

                          }, style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red
                          ),child: Text("Send", style: TextStyle(color:Colors.white),))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(onPressed: () {

                        }, style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red
                        ),
                            child: Text("Resend", style: TextStyle(color: Colors.white),)),
                        Container(
                          height: 50,
                          width: screenWidth * 0.45,
                          child: TextField(
                            controller: PrimeryNumber,
                            decoration: InputDecoration(
                                hintText: "OTP", // Placeholder text
                                border: OutlineInputBorder(
                                    borderRadius:  BorderRadius.circular(10)
                                ),
                                contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: () async {
                          String PrimeryNum = PrimeryNumber.text;
                          String SeconderyNum = SeconderyNumber.text;
                          String email = Email.text;
                          if(PrimeryNum.isNotEmpty && SeconderyNum.isNotEmpty && email.isNotEmpty){
                            try{
                              User? user = FirebaseAuth.instance.currentUser;
                              late String currentUID = user?.uid ?? '';
                              await FirebaseFirestore.instance.collection(Skill).doc(currentUID).update({
                                "Phone_Number1": PrimeryNum,
                                "Phone_Number2": SeconderyNum,
                                "Email" : email,
                              });
                              await FirebaseFirestore.instance.collection('user').doc(currentUID).update({
                                "Phone_Number1": PrimeryNum,
                                "Phone_Number2": SeconderyNum,
                                "Email" : email,
                              });
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StaffProfilePage(StaffID: currentUID, Skill: Skill),));
                            }catch (e){
                              Fluttertoast.showToast(
                                msg: "$e",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          }
                        },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green
                            ),
                            child: Text("Confirm", style: TextStyle(color: Colors.white),)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}