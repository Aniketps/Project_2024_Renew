import 'package:carehub/services/PaymentServices/PaymentRecordService.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordRepo.dart';
import 'package:carehub/services/PaymentServices/PaymentRecordRepoImpl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Import intl package

import '../../Models/PaymentRecordModel.dart';

class PaymentRecordImpl implements PaymentRecordService {
  PaymentRecordRepo paymentRecordRepo = PaymentRecordRepoImpl();

  @override
  Future<PaymentRecordModel?> getPaymentRecordByUID(String UID) async {
    // Fetch the payment record using the repository
    PaymentRecordModel paymentRecordModel = await paymentRecordRepo.getPaymentRecordByUID(UID);
    DateTime now = DateTime.now();
    DateTime expire;
    print("Date : ${paymentRecordModel.expire}");

    // Parse the expire date string to DateTime
    try {
      expire = paymentRecordModel.expire;
    } catch (e) {
      print("Error parsing expiration date: $e");
      return null;
    }

    // Compare expiration date with current date
    if (expire.isAfter(now)) {
      return paymentRecordModel;
    } else {
      return null;
    }
  }
}
