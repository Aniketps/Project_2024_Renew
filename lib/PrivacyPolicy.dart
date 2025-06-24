import 'dart:io';

import 'package:carehub/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _acceptPolicy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("IsAgree", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void _rejectPolicy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("IsAgree", false);

    exit(0); // This will close the app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  const Text(
                    "Terms of Service",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color : Colors.white),
                  ),
                  const SizedBox(height: 8),

                  // Last Updated
                  const Text(
                    "Last updated: 26th January 2025",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Description
                  const Text(
                    '''This application is operated by CareNest. Throughout the application, the terms "we", "us", and "our" refer to CareNest. CareNest offers this application, including all information, tools, and services available from this site to you, the user, conditioned upon your acceptance of all terms, conditions, policies, and notices stated here.''',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    '''By using this application, you agree to our Terms of Service and Privacy Policy. If you do not agree with any part of the policy, you may choose to reject it.''',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Guidelines Section
                  const Text(
                    "Usage Guidelines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _buildGuidelineItem(
                      "Respect privacy and data security policies."),
                  _buildGuidelineItem(
                      "Use the application for legal and intended purposes."),
                  _buildGuidelineItem(
                      "Ensure your actions align with our terms and conditions."),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Links to External Policies
                  _buildPolicyLink("View our Terms and Conditions",
                      "https://carenest.ancientcoders.in/Terms_Conditions.html"),
                  _buildPolicyLink("View our Privacy Policy",
                      "https://carenest.ancientcoders.in/Privacy_Policy.html"),
                  _buildPolicyLink("View our Refund Policy",
                      "https://carenest.ancientcoders.in/Refund_Policy.html"),
                ],
              ),
            ),
          ),

          // Accept & Reject Buttons (Stays at Bottom)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _rejectPolicy,
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                ),
                ElevatedButton.icon(
                  onPressed: _acceptPolicy,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Accept"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method for Guidelines Item
  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  // Method for Clickable Policy Links
  Widget _buildPolicyLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _launchURL(url),
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
