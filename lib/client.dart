import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ClientNotificationPage.dart';

class ActualUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ActualUser();
}

class _ActualUser extends State<ActualUser> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  var userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      setState(() {
        userData = documentSnapshot.data();
        isLoading = false;

        // Pre-fill the fields with user data
        if (userData != null) {
          _emailController.text = userData['Email'] ?? '';
          _addressController.text = userData['Address'] ?? '';
          _phoneController.text = userData['Phone'] ?? '';
          _serviceController.text = userData['Service'] ?? '';
        }
      });
    }
  }

  Future<void> _registerUser() async {
    String email = _emailController.text;
    String address = _addressController.text;
    String phone = _phoneController.text;
    String service = _serviceController.text;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
        'Email': email,
        'Address': address,
        'Phone': phone,
        'Service': service,
      });

      // Clear fields after registration
      _emailController.clear();
      _addressController.clear();
      _phoneController.clear();
      _serviceController.clear();

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Information updated successfully!")),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.green,
      ),
      body: isLoading || userData == null
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Container(
          height: screenHeight * 0.85,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile photo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(80),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 1),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/images/shweta.jpeg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  // Full name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${userData['First_name']} ${userData['Last_name']}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),

                  // Notifications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientNotificationPage(),
                            ),
                          );
                        },
                        child: Icon(Icons.notifications),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Input fields for email, address, phone, and services
                  _buildTextFieldWithIcon(_emailController, 'Email', Icons.edit),
                  SizedBox(height: 20),
                  _buildTextFieldWithIcon(_addressController, 'Address', Icons.edit),
                  SizedBox(height: 20),
                  _buildTextFieldWithIcon(_phoneController, 'Phone Number', Icons.edit),
                  SizedBox(height: 20),
                  _buildTextFieldWithIcon(_serviceController, 'Services Taken', Icons.edit),
                  SizedBox(height: 40),

                  // Save button


                  // Logout button
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text("Logout"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon(TextEditingController controller, String label, IconData icon) {
    return Row(
      children: [

        // SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),


        ),
        Icon(icon, color: Colors.grey),
      ],
    );
  }
}
