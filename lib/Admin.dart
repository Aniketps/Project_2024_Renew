import 'package:carehub/StaffVerifcation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool _isPasswordVisible = false;
  String hi = "Hi";
  String CodeName = "";
  bool isLoading = false;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep Tech-Themed Background
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1518343265568-51eec52d40da?q=80&w=2012&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // Tech-themed background
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black, // Fallback color if the image fails
              ),
            ),
          ),

          // ** Centered Login Form **
          Center(
            child: Container(
              width: screenWidth * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ** Developer Icon **
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centers everything
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chevron_left, // Displays the < > icon
                        size: 40,
                        color: Color.fromARGB(205, 0, 1, 52),
                      ),
                      const SizedBox(width: 8), // Adjust space between < and HI
                      Text(
                        hi + CodeName,
                        style: const TextStyle(
                          fontFamily: 'Georgia', // ✅ Using Georgia Font
                          fontSize: 14, // ✅ Size as per your requirement
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(205, 0, 1, 52),
                        ),
                      ),
                      const SizedBox(width: 8), // Adjust space between HI and >
                      const Icon(
                        Icons.chevron_right, // Another < > icon
                        size: 40,
                        color: Color.fromARGB(205, 0, 1, 52),
                      ),
                    ],
                  ),

                  // ** Title **
                  Text(
                    "Welcome, Dev",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(205, 0, 1, 52),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ** Username Field **
                  _buildTextField(Icons.person, "Username"),
                  const SizedBox(height: 16),

                  // ** Password Field **
                  _buildPasswordField(),
                  const SizedBox(height: 24),

                  // ** Login Button with Smooth Animation **
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);

                      try {
                        var querySnapshot = await FirebaseFirestore.instance
                            .collection("Admin")
                            .where("CodeName",
                                isEqualTo: userNameController.text.trim())
                            .get();

                        if (querySnapshot.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Incorrect Username")));
                        } else {
                          var data = querySnapshot.docs.first.data();
                          if (data["Password"] ==
                              passwordController.text.trim()) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StaffVerification(
                                        loggedAdmin:
                                            userNameController.text.trim(),
                                      )),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Incorrect Password")));
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")));
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ** Username Input Field **
  Widget _buildTextField(IconData icon, String hint) {
    return TextField(
      onChanged: (value) {
        setState(() {
          CodeName = ", $value";
        });
      },
      controller: userNameController,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ** Password Input Field with Visibility Toggle **
  Widget _buildPasswordField() {
    return TextField(
      onChanged: (value) {},
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
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
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
