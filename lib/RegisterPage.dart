import 'package:carehub/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'StaffDetailInputPage.dart';

class RegisterPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage>{
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    final isWeb = screenWidth > 700;

    return Scaffold(
        backgroundColor: Colors.white,
        body: isWeb? WebView() : AndroidView()
    );
  }
}

class AndroidStaffPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AndroidStaffPage();
}

class _AndroidStaffPage extends State<AndroidStaffPage>{

  TextEditingController FirstName = TextEditingController();
  TextEditingController LastName = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password1 = TextEditingController();
  TextEditingController Password2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          margin: EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(80),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1),
            ],
            image: DecorationImage(
              image: AssetImage("assets/images/logo.png"),
              fit: BoxFit.cover, // Adjust the fit if necessary
            ),
          ),
        ),
        Center(
          child: Container(
            height: 500,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                ]
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text("Staff Registration", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: FirstName,
                      decoration: InputDecoration(
                          labelText: "First name", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: LastName,
                      decoration: InputDecoration(
                          labelText: "Last name", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: Email,
                      decoration: InputDecoration(
                          labelText: "Email", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: Password1,
                      decoration: InputDecoration(
                          labelText: "Password", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),

                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: Password2,
                      decoration: InputDecoration(
                          labelText: "Confirm password", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),

                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 5, left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                          },
                          child: Text("Already have an account", style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),)
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                      onPressed: () {
                        String firstName = FirstName.text;
                        String lastName = LastName.text;
                        String email = Email.text;
                        String password1 = Password1.text;
                        String password2 = Password2.text;
                        if(firstName.isNotEmpty && lastName.isNotEmpty && email.isNotEmpty && password1.isNotEmpty && password2.isNotEmpty){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailInputPage(Email: email, FirstName: firstName, Password: password1, LastName: lastName,),));
                        }
                      },
                      child: Text("Next")),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AndroidUserPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AndroidUserPage();
}

class _AndroidUserPage extends State<AndroidUserPage>{
  TextEditingController FirstName = TextEditingController();
  TextEditingController LastName = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password1 = TextEditingController();
  TextEditingController Password2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          margin: EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(80),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1),
            ],
            image: DecorationImage(
              image: AssetImage("assets/images/logo.png"),
              fit: BoxFit.cover, // Adjust the fit if necessary
            ),
          ),
        ),
        Center(
          child: Container(
            height: 500,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                ]
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text("User Registration", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: FirstName,
                      decoration: InputDecoration(
                          labelText: "First name", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: LastName,
                      decoration: InputDecoration(
                          labelText: "Last name", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: Email,
                      decoration: InputDecoration(
                          labelText: "Email", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: Password1,
                      decoration: InputDecoration(
                          labelText: "Password", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),

                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: Password2,
                      decoration: InputDecoration(
                          labelText: "Confirm password", // Placeholder text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),

                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16)// Adds border around the text field
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 5, left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {

                          },
                          child: Text("Already have an account", style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),)
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                      onPressed: () async {
                        String firstname = FirstName.text;
                        String lastname = LastName.text;
                        String email = Email.text;
                        String password1 = Password1.text;
                        String password2 = Password2.text;
                        if(firstname.isNotEmpty && lastname.isNotEmpty && email.isNotEmpty && password1.isNotEmpty && password2.isNotEmpty){
                          if(password1 == password2){
                            UserCredential usercredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password1);
                            User? user = usercredential.user;
                            await FirebaseFirestore.instance.collection("user").doc(user?.uid).set({
                              'Email': email,
                              'Password': password1,
                              'First_name': firstname,
                              'Last_name': lastname,
                            });

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                          }
                        }else{
                          print("Error");
                        }
                      },
                      child: Text("Submit")),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WebStaffPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WebStaffPage();
}

class _WebStaffPage extends State<WebStaffPage>{
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenHeight = mediaquery.size.height;
    final screenWidth = mediaquery.size.width;

    return Container(
      height: screenHeight * 0.50,
      width: screenWidth * 0.65,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          children: [
            Container(
              height: (screenHeight * 0.55) * 0.75,
              width: (screenWidth * 0.65) * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                  ),
                  // Login
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                  ),
                  // Use your user account to login
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: (screenHeight * 0.55) * 0.75,
              width: (screenWidth * 0.65) * 0.38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email input
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 50,
                      width: (screenWidth * 0.65) * 0.38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                      ),
                    ),
                  ),

                  // Email Forgot
                  Container(
                    height: 20,
                    width: ((screenWidth * 0.65) * 0.38) * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                    ),
                  ),

                  // Email input
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 50,
                      width: (screenWidth * 0.65) * 0.38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                      ),
                    ),
                  ),

                  // Email forgot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        width: ((screenWidth * 0.65) * 0.38) * 0.4,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                        ),
                      ),
                      Container(
                        height: 20,
                        width: ((screenWidth * 0.65) * 0.38) * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                        ),
                      ),
                    ],
                  ),

                  // Submit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Container(
                          height: 40,
                          width: (screenWidth * 0.65) * 0.1,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebUserPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WebUserPage();
}

class _WebUserPage extends State<WebUserPage>{
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;
    return Center(
      child: Container(
        height: screenHeight * 0.50,
        width: screenWidth * 0.65,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)
            ]
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            children: [
              Container(
                height: (screenHeight * 0.55) * 0.75,
                width: (screenWidth * 0.65) * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                    ),
                    // Login
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                    ),
                    // Use your user account to login
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: (screenHeight * 0.55) * 0.75,
                width: (screenWidth * 0.65) * 0.38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email input
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        height: 50,
                        width: (screenWidth * 0.65) * 0.38,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                        ),
                      ),
                    ),

                    // Email Forgot
                    Container(
                      height: 20,
                      width: ((screenWidth * 0.65) * 0.38) * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                      ),
                    ),

                    // Email input
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        height: 50,
                        width: (screenWidth * 0.65) * 0.38,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                        ),
                      ),
                    ),

                    // Email forgot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 20,
                          width: ((screenWidth * 0.65) * 0.38) * 0.4,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                          ),
                        ),
                        Container(
                          height: 20,
                          width: ((screenWidth * 0.65) * 0.38) * 0.3,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                          ),
                        ),
                      ],
                    ),

                    // Submit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Container(
                            height: 40,
                            width: (screenWidth * 0.65) * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 2, blurRadius: 1)]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AndroidView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AndroidView();
}

class _AndroidView extends State<AndroidView>{
  Color StaffColorTrue = Colors.blueAccent;
  Color StaffColorFalse = Colors.white;
  bool StaffPressed = false;
  Color StaffColor = Colors.white;
  Color UserColorTrue = Colors.blueAccent;
  Color UserColorFalse = Colors.white;
  bool UserPressed = true;
  Color UserColor = Colors.blueAccent;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Color(0xff2020b7),
          height: 320,
          width: double.maxFinite,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                          ]
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(onPressed: () {
                            setState(() {
                              StaffPressed = !StaffPressed;
                              if(StaffPressed){
                                StaffColor = StaffColorTrue;
                                UserColor = UserColorFalse;
                                UserPressed = false;
                              }else{
                                StaffColor = StaffColorFalse;
                              }
                            });
                          },style: ElevatedButton.styleFrom(
                              backgroundColor: StaffColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(50),
                                      topRight: Radius.circular(0)
                                  )
                              )
                          ),
                              child: Text("Staff", style: TextStyle(color: Color(0xff013220), fontWeight: FontWeight.bold),)),
                          ElevatedButton(onPressed: () {
                            setState(() {
                              UserPressed = !UserPressed;
                              if(UserPressed){
                                StaffColor = StaffColorFalse;
                                UserColor = UserColorTrue;
                                StaffPressed = false;
                              }else{
                                UserColor = UserColorFalse;
                              }
                            });
                          },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: UserColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(50),
                                          bottomLeft: Radius.circular(0),
                                          topRight: Radius.circular(50)
                                      )
                                  )
                              ),
                              child: Text("User",style: TextStyle(color: Color(0xff8B0000), fontWeight: FontWeight.bold),))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StaffPressed? AndroidStaffPage() : AndroidUserPage()
            ],
          ),
        )
      ],
    );
  }
}

class WebView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WebView();
}

class _WebView extends State<WebView>{
  Color StaffColorTrue = Colors.blueAccent;
  Color StaffColorFalse = Colors.white;
  bool StaffPressed = false;
  Color StaffColor = Colors.white;
  Color UserColorTrue = Colors.blueAccent;
  Color UserColorFalse = Colors.white;
  bool UserPressed = true;
  Color UserColor = Colors.blueAccent;
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Stack(
      children: [
        ClipPath(
          clipper: BlueShapeClipper(),
          child: Container(
            height: screenHeight,
            width: screenWidth,// Adjust the height accordingly
            color: Color(0xff2020b7),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, right: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 1)
                          ]
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(onPressed: () {
                            setState(() {
                              StaffPressed = !StaffPressed;
                              if(StaffPressed){
                                StaffColor = StaffColorTrue;
                                UserColor = UserColorFalse;
                                UserPressed = false;
                              }else{
                                StaffColor = StaffColorFalse;
                              }
                            });
                          },style: ElevatedButton.styleFrom(
                              backgroundColor: StaffColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(50),
                                      topRight: Radius.circular(0)
                                  )
                              ),
                              minimumSize: Size(100, 50)
                          ),
                              child: Text("Staff", style: TextStyle(color: Color(0xff013220), fontWeight: FontWeight.bold),)),
                          ElevatedButton(onPressed: () {
                            setState(() {
                              UserPressed = !UserPressed;
                              if(UserPressed){
                                StaffColor = StaffColorFalse;
                                UserColor = UserColorTrue;
                                StaffPressed = false;
                              }else{
                                UserColor = UserColorFalse;
                              }
                            });
                          },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: UserColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(50),
                                          bottomLeft: Radius.circular(0),
                                          topRight: Radius.circular(50)
                                      )
                                  ),
                                  minimumSize: Size(100, 50)
                              ),
                              child: Text("User",style: TextStyle(color: Color(0xff8B0000), fontWeight: FontWeight.bold),))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StaffPressed? WebStaffPage() : WebUserPage()
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
    path.lineTo(size.width , 0); // Top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}