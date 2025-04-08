import '../../Models/PaymentRecordModel.dart';

abstract class PaymentRecordService{
  Future<PaymentRecordModel?> getPaymentRecordByUID(String UID);
}