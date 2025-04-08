import 'package:carehub/Models/PaymentRecordModel.dart';

abstract class PaymentRecordRepo{
  Future<PaymentRecordModel> getPaymentRecordByUID(String UID);
}