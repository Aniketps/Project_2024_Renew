import 'package:carehub/Models/PaymentRecordModel.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentRecordRepoImpl implements PaymentRecordRepo {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<PaymentRecordModel> getPaymentRecordByUID(String UID) async {

    QuerySnapshot paymentRecords =
    await _firebaseFirestore.collection("Payment Records")
        .where("staffUID", isEqualTo: UID)
        .orderBy("expire", descending: true)
        .get();

    if (paymentRecords.docs.isNotEmpty) {
      var doc = paymentRecords.docs.first;

      String _staffUID = doc["staffUID"];
      String _plan = doc["plan"];
      String _duration = doc["duration"];

      // Convert Timestamp to DateTime
      DateTime _expire = (doc["expire"] as Timestamp).toDate();
      DateTime _start = (doc["start"] as Timestamp).toDate();

      return PaymentRecordModel(
        _staffUID,
        _plan,
        _duration,
        _expire,
        _start,
      );
    } else {
      print("No payment records found for UID: $UID");
      throw Exception("No payment record found");
    }
  }
}
