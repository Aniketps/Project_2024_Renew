import 'package:carehub/StaffProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EPersonal extends StatefulWidget {
  String Skill;
  EPersonal({required this.Skill});
  @override
  State<StatefulWidget> createState() => _EPersonal(Skill: Skill);
}

class _EPersonal extends State<EPersonal> {
  String Skill;
  _EPersonal({required this.Skill});
  DateTime? pickedDate;
  String? selectedGender;
  TextEditingController City = TextEditingController();
  TextEditingController FirstName = TextEditingController();
  TextEditingController LastName = TextEditingController();

  List<String> Gender = ["Male", "Female", "Bigender", "Lesbian", "Homosexual"];
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Informatioin"),
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
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: FirstName,
                        decoration: InputDecoration(
                            labelText: "First Name", // Placeholder text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: LastName,
                        decoration: InputDecoration(
                            labelText: "Last Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                    child: InkWell(
                      onTap: () async {
                        setState(() async {
                          pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now()
                          );
                        });
                      },
                      child: Container(
                        height: 50,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: Colors.black54)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: [
                              Text((pickedDate == null)? "Select Date of Birth" : "Selected ${pickedDate?.day}/${pickedDate?.month}/${pickedDate?.year}" ),
                            ],
                          ),
                        )
                      ),
                    ),
                  ),

                  // Dropp down button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: Colors.black54)
                      ),
                      width: screenWidth * 0.84,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButton<String>(
                          value: selectedGender,
                          hint: Text("Select an Gender"),
                          items: Gender.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth * 0.9,
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
                              selectedGender = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: City,
                        decoration: InputDecoration(
                            labelText: "City",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: () async {
                          String city = City.text;
                          String firstname = FirstName.text;
                          String lastname = LastName.text;
                          String DOB = "${pickedDate?.day}/${pickedDate?.month}/${pickedDate?.year}";
                          String? gender = selectedGender;
                          if(city.isNotEmpty && firstname.isNotEmpty && lastname.isNotEmpty && DOB.isNotEmpty){
                            try{
                              User? user = FirebaseAuth.instance.currentUser;
                              late String currentUID = user?.uid ?? '';
                              await FirebaseFirestore.instance.collection(Skill).doc(currentUID).update({
                                "City": city,
                                "First_name": firstname,
                                "Last_name" : lastname,
                                "DOB" : DOB,
                                "Gender" : gender
                              });
                              await FirebaseFirestore.instance.collection('user').doc(currentUID).update({
                                "City": city,
                                "First_name": firstname,
                                "Last_name" : lastname,
                                "DOB" : DOB,
                                "Gender" : gender
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