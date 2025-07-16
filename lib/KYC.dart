import 'dart:io';

import 'package:carehub/services/convertToTranslate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 150,
              color: Globle.theme,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppBar(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Center(
                        child: Text("KYC".trKey,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
                      ),
                    ),
                    backgroundColor: Globle.theme,
                    automaticallyImplyLeading: false,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, top: 10),
                      child: DropdownButton<Locale>(
                        dropdownColor: Colors.blue,
                        value: context.locale,
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.language, color: Colors.white),
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('hi'),
                            child: Text('हिंदी'),
                          ),
                          DropdownMenuItem(
                            value: Locale('mr'),
                            child: Text('मराठी'),
                          ),
                          DropdownMenuItem(
                            value: Locale('fr'),
                            child: Text('Français'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ru'),
                            child: Text('Русский'),
                          ),
                          DropdownMenuItem(
                            value: Locale('bn'),
                            child: Text('বাংলা'),
                          ),
                          DropdownMenuItem(
                            value: Locale('pt'),
                            child: Text('Português'),
                          ),
                          DropdownMenuItem(
                            value: Locale('es'),
                            child: Text('Español'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ur'),
                            child: Text('اردو'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ja'),
                            child: Text('日本語'),
                          ),
                          DropdownMenuItem(
                            value: Locale('te'),
                            child: Text('తెలుగు'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ar'),
                            child: Text('العربية'),
                          ),
                          DropdownMenuItem(
                            value: Locale('de'),
                            child: Text('Deutsch'),
                          ),
                          DropdownMenuItem(
                            value: Locale('vi'),
                            child: Text('Tiếng Việt'),
                          ),
                          DropdownMenuItem(
                            value: Locale('id'),
                            child: Text('Bahasa Indonesia'),
                          ),
                          DropdownMenuItem(
                            value: Locale('zh'),
                            child: Text('中文'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ta'),
                            child: Text('தமிழ்'),
                          ),
                          DropdownMenuItem(
                            value: Locale('tr'),
                            child: Text('Türkçe'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ko'),
                            child: Text('한국어'),
                          ),
                          DropdownMenuItem(
                            value: Locale('it'),
                            child: Text('Italiano'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ml'),
                            child: Text('മലയാളം'),
                          ),
                          DropdownMenuItem(
                            value: Locale('th'),
                            child: Text('ไทย'),
                          ),
                          DropdownMenuItem(
                            value: Locale('pl'),
                            child: Text('Polski'),
                          ),
                        ],
                        onChanged: (Locale? locale) {
                          if (locale != null) {
                            context.setLocale(locale);
                          }
                        },
                      ),
                    ),
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
                      Text(
                        "personal_info".trKey,
                        style: const TextStyle(fontSize: 20, color: Colors.black),
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
                            hintText: "full_name".trKey,
                            labelText: "full_name".trKey,
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
                            hintText: "phone_number".trKey,
                            labelText: "phone_number".trKey,
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
                        child: Text(
                          "gov_id_guidelines".trKey,
                          style: const TextStyle(
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
                                  if (fileSize <= 604800) {
                                    setState(() {
                                      AadharCard = file;
                                    });
                                  } else {
                                    // Show warning to user
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('File too large. Please select a file less than 500 KB.'.trKey),
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
                                  child: Center(child: Text("select_id".trKey))),
                            ),
                            Text(
                              AadharCard == null
                                  ? "not_selected".trKey
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
                        child: Text(
                          "passport_photo_guidelines".trKey,
                          style: const TextStyle(
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
        
                                  if (fileSize <= 604800) { // 200 KB = 204800 bytes
                                    setState(() {
                                      PassportSizePhoto = file;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('File too large. Please select a file size less than 500 KB.'.trKey),
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
                                  child: Center(child: Text("select_photo".trKey))),
                            ),
                            Text(
                              PassportSizePhoto == null
                                  ? "not_selected".trKey
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
                        child: Text(
                            "video_guidelines".trKey,
                          style: const TextStyle(
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
        
                                  if (bytes <= 15 * 1024 * 1024) { // 15MB = 15 * 1024 * 1024 bytes
                                    setState(() {
                                      SelfVideo = file;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Please select a video smaller than 15MB.".trKey),
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
                                  child: Center(child: Text("select_video".trKey))),
                            ),
                            Text(
                              SelfVideo == null
                                  ? "not_selected".trKey
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
                            Text(
                              "profession_verification".trKey,
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              "profession_note".trKey,
                              style: const TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            // Text(
                            //   checkprofession(),
                            //   style: const TextStyle(
                            //       fontSize: 12, fontStyle: FontStyle.italic),
                            // )
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
        
                                  if (bytes <= 500 * 1024) { // 200KB = 200 * 1024 bytes
                                    setState(() {
                                      ProfessionVerDoc = file;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Please select a document smaller than 500KB.".trKey),
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
                                  child: Center(child: Text("select_doc".trKey))),
                            ),
                            Text(
                              ProfessionVerDoc == null
                                  ? "not_selected".trKey
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
                                      "VerifiedNumber" : PhoneNumber.text,
                                      "kycDate": DateTime.now().toIso8601String()
                                    });
                                    await FirebaseFirestore.instance
                                        .collection("user")
                                        .doc(user?.uid)
                                        .update({
                                      'Verified': "pending",
                                      "UPI" : "",
                                      "VerifiedName" : FullName.text,
                                      "VerifiedNumber" : PhoneNumber.text,
                                      "kycDate": DateTime.now().toIso8601String()
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
                                        msg: "Fill All Details".trKey);
                                  }
                                },
                                child: Text("submit".trKey))
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
      ),
    );
  }
}
