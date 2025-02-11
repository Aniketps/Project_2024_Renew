import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "carehub-af7ec",
        "private_key_id": "a2fff9ced4087978cd7c9ba0aa46f9f6bcbb5ee5",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDTq71tE3QxyQWK\nPUWzStz702IKIn+HoqsLD0Cza/xSYr4KPCBIThabJHGX4Oc4yAh3I3RGedCx4oUc\n+CsxjQpRvNm4hgAw7nyLU9MBZJJH7c9/kYxveWVrZk9mcbzxW/BDpFK0bJOfbb/x\nqsJ0aqit5+/Qh3RM/IV5O8+MB/T9e8u1uef47wYmHysVviJYhfDGnG/oiuJQHk9X\nZETzVTB5Q8JXmQPwx2xjKqtEmEVLCfd6yVfMbiJkSftEdlpwW/gXMvy4s0ULz9tg\nDrlgJy5VGRSXtYBWetOWdymd8FpocRa7INgV+RKVsZKf7zp7s+wZHQ9fsrW+CmPD\nZZMCmhOJAgMBAAECggEAALzcahJTXplig07qMgaHWs+rtmN/Ocq2RBGEynX3I8Cz\n2bHIHrBk/Eabfb8bLIkSnHsGEfklN3rVt2+MU6h3730pbhmgy7WHv22RR/Pg3aQl\ndmlHCcbCH3vJuDlFF7tCt7L4KyhQuGbHxeYa4OXT74KQ2lN1Mzp9wESA2UOtgH+p\nwBXAFGmoeWAEXG6f+aaDuoRVINSCcGKHiwM7fECEgwRRQl+Rj6uN9oHdp3q3Z13D\nRx6yZeSJuWKdjtl99OYyAeM9uDT+rlOkRGzq81fxupbT9JVqmuszUo0/4R/zOq4E\nMJGHNnYmIOXSfJW5UdFbPHHwPbBAypX6P1WddVCuXQKBgQD00DHbjRH18xAmtAMq\nO5YnrpakCbH/8md0JUQIrNTWgtb1k6BS2tg9uuEMWS5fs3XcKQtXLymWVuT7e+0W\nxrzlloD8wPcKmm+lX9FIUbHVNkwNiulP5WvGQV7qpU43JHc9UDSBBCs6z/d5eIT7\nLZ8Jz50Havq1ZuQc6lh/tBhXjQKBgQDdV9kec3E5QbtZbfskooFW7Y1WwXWs99qd\nUfIZjKOL5B+36T4opVrn+vLcdGJ2c28loYf/xEkt5rinGIVfPjtWB1/4jd0K6s2o\n5ZnzJS2hvtGlvIbdOSUyaIit4WHDqy8jYtVsSDj2Eu2ApesOCcxZB6WOBkix+XOb\n9MHX5Cie7QKBgQDi3yW1LxCb+vrWwy/DraDDeXpE3m9EoCHbcsWPvIspl+sZfguv\nfPu0iUERrnvZWHg65RaLXzuNBU4C+J+I4fggU8+JbFIEU4ZvnVJXUM4apszoJ/l7\nf0LXYbFShorrczHFclSV04U0ZZIT0ep605Z1Ax+kxjE8dvOjEFGfVwjP6QKBgCBw\nkJSi7LQsiw23Tbh3zKb11+IgJmP8S2EFMotGDm4hN/jXSVHhsioPoGpo8ElV77M/\nMlRs6yC8ENIEiP+FemLIX+totz2zXgLj66U0DLUI52b383gWuPnjUizRvGdV/mmc\nQZVGHHsMGRzitElxbC6cLUpcZ2kWGzh/La27daydAoGBAJT2p6hXoKsbzJZPKBtq\nr+/dOHN3Oj9QIk/YXh1Z9biOXx/Xd9R9LWHYfGhehUWKsZe5wFvIp3o2/h+vvhBP\npq7gqQqX1t3uR8REpGtPwR1a/8zicChCe9QgbRMUlqjC/a9l5GUpq7guEScmAIw6\nSIeT49tXslf09wEXJQfnrsiV\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-yqmms@carehub-af7ec.iam.gserviceaccount.com",
        "client_id": "103536856579389231767",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-yqmms%40carehub-af7ec.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
