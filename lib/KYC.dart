import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class KYC extends StatefulWidget {
  final String Skill;
  const KYC({super.key, required this.Skill});
  @override
  State<StatefulWidget> createState() => _KYC(Skill: Skill);
}

class _KYC extends State<KYC> {
  final String Skill;
  _KYC({required this.Skill});
  File? PassportSizePhoto, AadharCard, SelfVideo, ProfessionVerDoc;
  Map<String, String> professionRequirements = {
    "Chef":
        "1. Culinary Arts Degree/Certification\n2. Food Safety Certificate\n3. Experience Letter",
    "Personal Care Assistant":
        "1. Medical Education Certificate\n2. Background Check\n3. First Aid/CPR Certification",
    "Driver":
        "1. Valid Driver’s License\n2. Background Check\n3. Insurance Proof\n4. Driving Record",
    "Home/Security Guard":
        "1. ID Card\n2. Background Check\n3. Security Training/Certification",
    "Elderly/Elder Companion":
        "1. Background Check\n2. Health and Wellness Certification\n3. First Aid/CPR",
    "Babysitter":
        "1. Background Check\n2. CPR/First Aid Certification\n3. Experience Letters",
    "Cleaner":
        "1. ID Card\n2. Proof of Residence\n3. Employment History\n4. References",
    "Housekeeper":
        "1. ID Card\n2. References\n3. Employment History\n4. Background Check",
    "Paramedics":
        "1. Medical Education Certificate (Paramedic Training)\n2. CPR/First Aid Certification\n3. Licensure",
    "Occupational Therapists":
        "1. Medical Education Certificate (Occupational Therapy Degree)\n2. Licensure\n3. Background Check",
    "Physiotherapists":
        "1. Medical Education Certificate (Physiotherapy Degree)\n2. Licensure\n3. Background Check",
    "Home Health Aids":
        "1. Medical Education Certificate\n2. First Aid/CPR Certification\n3. Background Check",
    "Certified Nursing Assistant":
        "1. Medical Education Certificate (CNA Certification)\n2. CPR/First Aid Certification\n3. Background Check",
    "Licensed Practical Nurses":
        "1. Medical Education Certificate (LPN Degree)\n2. Licensure\n3. Background Check",
    "Registered Nurses":
        "1. Medical Education Certificate (RN Degree)\n2. Licensure\n3. Background Check\n4. CPR Certification"
  };
  bool loading = false;

  String checkprofession() {
    for (var entry in professionRequirements.entries) {
      if (entry.key.toLowerCase() == "Chef".toLowerCase()) {
        return entry.value;
      }
    }
    return "";
  }
  TextEditingController PhoneNumber = TextEditingController();
  TextEditingController FullName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 150,
            color: Globle.theme,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Center(
                      child: Text("KYC",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
                    ),
                  ),
                  backgroundColor: Globle.theme,
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Container(
              height: MediaQuery.sizeOf(context).height * 1,
              width: MediaQuery.sizeOf(context).width * 1,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Personal Information",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    // Full name
                    SizedBox(
                      height: 50,
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: TextField(
                        controller: FullName,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 15, right: 15),
                          hintText: "Full Name",
                          labelText: "Full Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Phone number
                    SizedBox(
                      height: 50,
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: TextField(
                        controller: PhoneNumber,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 15, right: 15),
                          hintText: "Phone Number",
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: const Divider()),
                    // Aadhar guidelines
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: const Text(
                        "Guidelines for Uploading Your Aadhar Card:\n\n"
                        "1. The Aadhar card image should be clear and easily readable.\n"
                        "2. Ensure there is no glare, blur, or shadows that obscure the details.\n"
                        "3. Do not crop or edit the image. The entire Aadhar card must be visible.\n"
                        "4. Make sure that all personal information (name, Aadhar number, etc.) is visible.\n"
                        "5. Capture a photo of both sides of the Aadhar card, merge them into one image, and upload.",
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Aadhar picker
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedImage != null) {
                                final file = File(pickedImage.path);
                                final int fileSize = file.lengthSync(); // size in bytes

                                // 200 KB = 200 * 1024 = 204800 bytes
                                if (fileSize <= 304800) {
                                  setState(() {
                                    AadharCard = file;
                                  });
                                } else {
                                  // Show warning to user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('File too large. Please select a file less than 200 KB.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 1,
                                        spreadRadius: 0.7,
                                      )
                                    ]),
                                child: const Center(child: Text("Select Aadhar"))),
                          ),
                          Text(
                            AadharCard == null
                                ? "Not Selected"
                                : (AadharCard!.path.split('/').last.length > 10
                                    ? '${AadharCard!.path
                                            .split('/')
                                            .last
                                            .substring(0, 13)}...' // Truncate and add ellipsis
                                    : AadharCard!.path.split('/').last),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: const Divider()),
                    // Photo Guidelines
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: const Text(
                        "Guidelines for Uploading Your Passport Size Photo:\n\n"
                        "1. Ensure the photo is clear, with no blur or pixelation.\n"
                        "2. The photo should be recent (taken within the last 6 months).\n"
                        "3. The background should be plain and light-colored (preferably white or light blue).\n"
                        "4. The face should be fully visible, without any accessories (like sunglasses or hats), and should be in focus.\n"
                        "5. The photo should be in the correct orientation (not upside down).\n"
                        "6. Ensure the photo is in passport size (2x2 inches) and only upload in JPG, JPEG, or PNG format.\n"
                        "7. Do not crop or edit the photo, and make sure the full face is visible.",
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Photo picker
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedImage != null) {
                                final file = File(pickedImage.path);
                                final int fileSize = file.lengthSync(); // Size in bytes

                                if (fileSize <= 204800) { // 200 KB = 204800 bytes
                                  setState(() {
                                    PassportSizePhoto = file;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('File too large. Please select a file size less than 200 KB.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 1,
                                        spreadRadius: 0.7,
                                      )
                                    ]),
                                child: const Center(child: Text("Select Photo"))),
                          ),
                          Text(
                            PassportSizePhoto == null
                                ? "Not Selected"
                                : (PassportSizePhoto!.path
                                            .split('/')
                                            .last
                                            .length >
                                        10
                                    ? '${PassportSizePhoto!.path
                                            .split('/')
                                            .last
                                            .substring(0, 13)}...' // Truncate and add ellipsis
                                    : PassportSizePhoto!.path.split('/').last),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: const Divider()),
                    // Video Guidelines
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: const Text(
                        "Guidelines for Uploading Your Staff Verification Video:\n\n"
                        "1. The video should be between 10 to 15 seconds long.\n"
                        "2. Record the video in a well-lit, quiet environment with no background noise.\n"
                        "3. Speak clearly and confidently while stating the following lines in any one below language:\n"
                        "   - 'English : Hi, My name is [Your Full Name], and my date of birth is [Your date of Birth]. I am currently living in [Name of place your right now].'\n"
                        "   - 'हिंदी : नमस्ते, मेरा नाम [आपका पूरा नाम] है, और मेरी जन्मतिथि [आपकी जन्मतिथि] है। मैं वर्तमान में [आपकी वर्तमान जगह का नाम] में रह रहा हूँ।'\n"
                        "   - 'मराठी : हाय, माझे नाव [तुमचे पूर्ण नाव] आहे आणि माझी जन्मतारीख [तुमची जन्मतारीख] आहे. मी सध्या [आपल्या जागेचे नाव सध्या] येथे राहत आहे.'\n"
                        "4. Ensure your face is fully visible and in focus throughout the video.\n"
                        "5. Do not edit or alter the video. It should be an authentic recording.\n"
                        "6. The video should be in MP4 or AVI format.\n"
                        "7. Ensure that no other person appears in the video during the recording.\n"
                        "8. Upload the video directly from your device once it is ready.",
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Video picker
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
                              if (pickedVideo != null) {
                                final file = File(pickedVideo.path);
                                final bytes = await file.length();

                                if (bytes <= 5 * 1024 * 1024) { // 5MB = 5 * 1024 * 1024 bytes
                                  setState(() {
                                    SelfVideo = file;
                                  });
                                } else {
                                  // Show alert if file is too large
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select a video smaller than 5MB."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 1,
                                        spreadRadius: 0.7,
                                      )
                                    ]),
                                child: const Center(child: Text("Select Video"))),
                          ),
                          Text(
                            SelfVideo == null
                                ? "Not Selected"
                                : (SelfVideo!.path.split('/').last.length > 10
                                    ? '${SelfVideo!.path
                                            .split('/')
                                            .last
                                            .substring(0, 13)}...' // Truncate and add ellipsis
                                    : SelfVideo!.path.split('/').last),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: const Divider()),

                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Profession Verification",
                            style: TextStyle(fontSize: 20),
                          ),
                          const Text(
                            "Please provide at least one of the following documents to verify your Chef profession.",
                            style: TextStyle(
                                fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                          Text(
                            checkprofession(),
                            style: const TextStyle(
                                fontSize: 12, fontStyle: FontStyle.italic),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedImage != null) {
                                final file = File(pickedImage.path);
                                final bytes = await file.length();

                                if (bytes <= 200 * 1024) { // 200KB = 200 * 1024 bytes
                                  setState(() {
                                    ProfessionVerDoc = file;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select a document smaller than 200KB."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 1,
                                        spreadRadius: 0.7,
                                      )
                                    ]),
                                child: const Center(child: Text("Select Document"))),
                          ),
                          Text(
                            ProfessionVerDoc == null
                                ? "Not Selected"
                                : (ProfessionVerDoc!.path
                                            .split('/')
                                            .last
                                            .length >
                                        10
                                    ? '${ProfessionVerDoc!.path
                                            .split('/')
                                            .last
                                            .substring(0, 13)}...' // Truncate and add ellipsis
                                    : ProfessionVerDoc!.path.split('/').last),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                if (PassportSizePhoto != null &&
                                    AadharCard != null &&
                                    SelfVideo != null &&
                                    ProfessionVerDoc != null) {
                                  User? user =
                                      FirebaseAuth.instance.currentUser;

                                  FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(
                                          "VerificationDoc/PassportPhoto/${user?.uid}")
                                      .putFile(PassportSizePhoto!);

                                  FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(
                                      "VerificationDoc/AadharCard/${user?.uid}")
                                      .putFile(AadharCard!);

                                  FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(
                                      "VerificationDoc/SelfVideo/${user?.uid}")
                                      .putFile(SelfVideo!);

                                  FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(
                                      "VerificationDoc/ProfessionalDoc/${user?.uid}")
                                      .putFile(ProfessionVerDoc!);




                                  await FirebaseFirestore.instance
                                      .collection(Skill.toLowerCase())
                                      .doc(user?.uid)
                                      .update({
                                    'Verified': "pending",
                                    "UPI" : "",
                                    "VerifiedName" : FullName.text,
                                    "VerifiedNumber" : PhoneNumber.text
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("user")
                                      .doc(user?.uid)
                                      .update({
                                    'Verified': "pending",
                                    "UPI" : "",
                                    "VerifiedName" : FullName.text,
                                    "VerifiedNumber" : PhoneNumber.text
                                  });
                                  Fluttertoast.showToast(msg: "Request Send");
                                  setState(() {
                                    loading = false;
                                  });
                                 Navigator.pop(context);
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Fill All Details");
                                }
                              },
                              child: const Text("Submit"))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
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
