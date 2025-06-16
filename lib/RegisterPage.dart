import 'package:carehub/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoaderSupport.dart';
import 'StaffDetailInputPage.dart';

class RegisterPage extends StatefulWidget {
  final bool isStaff;
  const RegisterPage({super.key, required this.isStaff});

  @override
  State<StatefulWidget> createState() => _RegisterPage(isStaff: isStaff);
}

class _RegisterPage extends State<RegisterPage> {
  final bool isStaff;

  _RegisterPage({required this.isStaff});

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;

    return Scaffold(
        backgroundColor: Colors.white, body: AndroidView(isStaff: isStaff,));
  }
}

class AndroidStaffPage extends StatefulWidget {
  final bool isStaff;

  const AndroidStaffPage({super.key, required this.isStaff});

  @override
  State<StatefulWidget> createState() => _AndroidStaffPage(isStaff: isStaff);
}

class _AndroidStaffPage extends State<AndroidStaffPage> {
  final bool isStaff;
  bool _isPasswordVisible = false;

  bool isValidFirstName = true;
  bool isValidLastName = true;
  bool isValidEmail = true;
  bool isValidPassword = true;
  bool isPasswordMatch = true;

  TextEditingController FirstName = TextEditingController();
  TextEditingController LastName = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password1 = TextEditingController();
  TextEditingController Password2 = TextEditingController();
  bool isLoading = false;

  bool validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  _AndroidStaffPage({required this.isStaff});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      Column(
        children: [
          Center(
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
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
                  SizedBox(height: 10,),
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: EdgeInsets.only(bottom: 10, top: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, spreadRadius: 2, blurRadius: 1),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.none, // No scaling
                              alignment: Alignment.center,
                              scale: 2, // Zoom in (smaller = more zoom)
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "CARENEST \nSTAFF SIGN UP",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
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

                  // First name
                  Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        onChanged: (value) {
                          bool isValid = true;
                          for (int i = 0; i < value.length; i++) {
                            String char = value[i];
                            if (!(char.contains(RegExp(r'[a-zA-Z]')))) {
                              isValid = false;
                              break;
                            }
                          }
                          setState(() {
                            isValidFirstName = isValid;
                          });
                        },
                        controller: FirstName,
                        decoration: InputDecoration(
                          labelText: "First name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16),
                        ),
                      ),
                    ),
                  ),
                  !isValidFirstName
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid First Name",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Last name
                  Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        onChanged: (value) {
                          bool isValid = true;
                          for (int i = 0; i < value.length; i++) {
                            String char = value[i];
                            if (!(char.contains(RegExp(r'[a-zA-Z]')))) {
                              isValid = false;
                              break;
                            }
                          }
                          setState(() {
                            isValidLastName = isValid;
                          });
                        },
                        controller: LastName,
                        decoration: InputDecoration(
                          labelText: "Last name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16),
                        ),
                      ),
                    ),
                  ),
                  !isValidLastName
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Last Name",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Email field
                  Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          // Check entire email string using RegExp
                          setState(() {
                            isValidEmail = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            ).hasMatch(value);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16),
                        ),
                      ),
                    ),
                  ),
                  !isValidEmail
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Password
                  Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Password1,
                        obscureText: !_isPasswordVisible,
                        onChanged: (value) {
                          setState(() {
                            isValidPassword = validatePassword(value);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  !isValidPassword
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Password must include:", style: TextStyle(color: Colors.red)),
                            Text("• At least 8 characters", style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text("• Uppercase & lowercase letters", style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text("• At least 1 digit", style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text("• At least 1 special character", style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  )
                      : Container(),


                  // Confirm Password field
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Password2,
                        onChanged: (value) {
                          setState(() {
                            isPasswordMatch = (value == Password1.text);
                          });
                        },
                        obscureText: true, // Hides the text for password fields
                        decoration: InputDecoration(
                          labelText: "Confirm Password", // Label text
                          hintText:
                              "Re-enter your password", // Hint text for better guidance
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                              20, 16, 16, 16), // Padding inside the text field
                        ),
                      ),
                    ),
                  ),
                  !isPasswordMatch
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Passwords don't match",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Already have account
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ));
                            },
                            child: Text(
                              "Already have an account?",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),

                  // Next Button
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 45,
                      width: double.infinity, // Make the container full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Border radius 10
                          ),
                        ),
                        onPressed: () {
                          if(isValidFirstName && isValidEmail && isValidLastName && isValidPassword && isPasswordMatch){
                            setState(() {
                              isLoading = true;
                            });
                            String firstName = FirstName.text;
                            String lastName = LastName.text;
                            String email = Email.text;
                            String password1 = Password1.text;
                            String password2 = Password2.text;
                            if (firstName.isNotEmpty &&
                                lastName.isNotEmpty &&
                                email.isNotEmpty &&
                                password1.isNotEmpty &&
                                password2.isNotEmpty) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StaffDetailInputPage(
                                      Email: email,
                                      FirstName: firstName,
                                      Password: password1,
                                      LastName: lastName,
                                    ),
                                  ));
                              setState(() {
                                isLoading = false;
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Fluttertoast.showToast(msg: "Fill the blanks");
                            }
                          }else{
                            Fluttertoast.showToast(msg: "Check all Boxes");
                          }
                        },
                        child: Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

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
                              "Privacy Policy, ",
                              style: TextStyle(
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
                              "Terms & Conditions, ",
                              style: TextStyle(
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
                              "Refund Policy",
                              style: TextStyle(
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

class AndroidUserPage extends StatefulWidget {
  final bool isStaff;

  const AndroidUserPage({super.key, required this.isStaff});

  @override
  State<StatefulWidget> createState() => _AndroidUserPage(isStaff: isStaff);
}

class _AndroidUserPage extends State<AndroidUserPage> {
  final bool isStaff;

  TextEditingController FirstName = TextEditingController();
  TextEditingController LastName = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password1 = TextEditingController();
  TextEditingController Password2 = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  bool isValidFirstName = true;
  bool isValidLastName = true;
  bool isValidEmail = true;
  bool isValidPassword = true;
  bool isPasswordMatch = true;

  bool validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  _AndroidUserPage({required this.isStaff});
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      Column(
        children: [
          Center(
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
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
                  SizedBox(height: 10,),
                  // logo title
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: EdgeInsets.only(bottom: 10, top: 20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, spreadRadius: 2, blurRadius: 1),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.none, // No scaling
                              alignment: Alignment.center,
                              scale: 2, // Zoom in (smaller = more zoom)
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "CARENEST \nCUSTOMER SIGN UP",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
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

                  // First name
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: FirstName,
                        onChanged: (value) {
                          bool isValid = true;
                          for (int i = 0; i < value.length; i++) {
                            String char = value[i];
                            if (!(char.contains(RegExp(r'[a-zA-Z]')))) {
                              isValid = false;
                              break;
                            }
                          }
                          setState(() {
                            isValidFirstName = isValid;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: "First name", // Placeholder text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                                16) // Adds border around the text field
                            ),
                      ),
                    ),
                  ),
                  !isValidFirstName
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid First Name",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Last name
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: LastName,
                        onChanged: (value) {
                          bool isValid = true;
                          for (int i = 0; i < value.length; i++) {
                            String char = value[i];
                            if (!(char.contains(RegExp(r'[a-zA-Z]')))) {
                              isValid = false;
                              break;
                            }
                          }
                          setState(() {
                            isValidLastName = isValid;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: "Last name", // Placeholder text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                                16) // Adds border around the text field
                            ),
                      ),
                    ),
                  ),
                  !isValidLastName
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Last Name",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Email field
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Email, // Controller for the email input
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          // Check entire email string using RegExp
                          setState(() {
                            isValidEmail = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            ).hasMatch(value);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Email", // Label for the TextField
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 16,
                              16), // Adds padding inside the TextField
                        ),
                      ),
                    ),
                  ),
                  !isValidEmail
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Invalid Email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Password
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Password1,
                        onChanged: (value) {
                          setState(() {
                            isValidPassword = validatePassword(value);
                          });
                        },
                        obscureText: !_isPasswordVisible, // Hides the text for password fields
                        decoration: InputDecoration(
                          labelText: "Password", // Label text
                          hintText:
                              "Enter your password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),// Hint text for better guidance
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                              20, 16, 16, 16), // Padding inside the text field
                        ),
                      ),
                    ),
                  ),
                  !isValidPassword
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Password must include:", style: TextStyle(color: Colors.red)),
                            Text("• At least 8 characters", style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text("• Uppercase & lowercase letters", style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text("• At least 1 digit", style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text("• At least 1 special character", style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // confirm password
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 30, left: 30, top: 10),
                    child: Container(
                      height: 50,
                      child: TextField(
                        controller: Password2,
                        onChanged: (value) {
                          setState(() {
                            isPasswordMatch = (value == Password1.text);
                          });
                        },
                        obscureText: true, // Hides the text for password fields
                        decoration: InputDecoration(
                          labelText: "Confirm Password", // Label text
                          hintText:
                              "Re-enter your password", // Hint text for better guidance
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded border
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                              20, 16, 16, 16), // Padding inside the text field
                        ),
                      ),
                    ),
                  ),
                  !isPasswordMatch
                      ? Padding(
                    padding: const EdgeInsets.only(right: 30, left: 30, top: 5),
                    child: Row(
                      children: [
                        Text(
                          "Passwords don't match",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                      : Container(),

                  // Already have account
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ));
                            },
                            child: Text(
                              "Already have an account?",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),

                  // submit
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 30, left: 30, top: 20),
                    child: Container(
                      height: 45,
                      width: double.infinity, // Make the container full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Border radius 10
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          String firstname = FirstName.text;
                          String lastname = LastName.text;
                          String email = Email.text;
                          String password1 = Password1.text;
                          String password2 = Password2.text;
                          if (firstname.isNotEmpty &&
                              lastname.isNotEmpty &&
                              email.isNotEmpty &&
                              password1.isNotEmpty &&
                              password2.isNotEmpty) {
                            if (password1 == password2) {
                              try {
                                UserCredential usercredential =
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                    email: email, password: password1);
                                User? user = usercredential.user;
                                await FirebaseFirestore.instance
                                    .collection("user")
                                    .doc(user?.uid)
                                    .set({
                                  'Email': email,
                                  'Password': password1,
                                  'First_name': firstname,
                                  'Last_name': lastname,
                                });
                                user?.sendEmailVerification();
                                Fluttertoast.showToast(
                                    msg:
                                    "Link send, A link has been send to your email");
                                await FirebaseAuth.instance.signOut();

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ));
                                setState(() {
                                  isLoading = false;
                                });
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  isLoading = false;
                                });
                                if (e.code == 'email-already-in-use') {
                                  Fluttertoast.showToast(
                                    toastLength: Toast.LENGTH_LONG,
                                    msg: "The email address is already in use by another account.",
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    toastLength: Toast.LENGTH_LONG,
                                    msg: e.message ?? "An unknown error occurred",
                                  );
                                  print(e);
                                }
                              }
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Password not matching");
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(
                                toastLength: Toast.LENGTH_LONG,
                                msg: "Fill the blanks");
                          }
                        },
                        child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

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
                              "Privacy Policy, ",
                              style: TextStyle(
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
                              "Terms & Conditions, ",
                              style: TextStyle(
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
                              "Refund Policy",
                              style: TextStyle(
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

class AndroidView extends StatefulWidget {
  final bool isStaff;

  const AndroidView({super.key, required this.isStaff});

  @override
  State<StatefulWidget> createState() => _AndroidView(isStaff: isStaff);
}

class _AndroidView extends State<AndroidView> {
  bool isStaff;
  _AndroidView({required this.isStaff});

  @override
  Widget build(BuildContext context) {
    Color StaffColorTrue = Color(0xFF4C9EEB);
    Color StaffColorFalse = Color(0xFFB0BEC5);
    Color StaffColor = isStaff? StaffColorTrue : StaffColorFalse;
    Color UserColorTrue = Color(0xFF4C9EEB);
    Color UserColorFalse = Color(0xFFB0BEC5);
    Color UserColor = isStaff? UserColorFalse : UserColorTrue;
    return Stack(
      children: [
        Container(
          color: !isStaff ? Color(0xfffffcc9) : Color(0xffbef0ff),
          height: 320,
          width: double.maxFinite,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      setState(() {
                        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                          // Swiped left
                          isStaff = true;  // Swipe left → Staff (left side)
                        } else if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                          // Swiped right
                          isStaff = false; // Swipe right → User (right side)
                        }
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 1,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Animated background
                          AnimatedAlign(
                            duration: Duration(milliseconds: 300),
                            alignment: isStaff ? Alignment.centerLeft : Alignment.centerRight,
                            curve: Curves.easeInOut,
                            child: Container(
                              width: (MediaQuery.of(context).size.width * 0.8) / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isStaff = true;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    child: Text(
                                      "Staff",
                                      style: TextStyle(
                                        color: isStaff ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isStaff = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    child: Text(
                                      "User",
                                      style: TextStyle(
                                        color: !isStaff ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              isStaff ? AndroidStaffPage(isStaff: isStaff,) : AndroidUserPage(isStaff: isStaff,)
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
