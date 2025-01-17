import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
          {
            "type": "service_account",
            "project_id": "carehub-af7ec",
            "private_key_id": "3a47dcc63309512401267e44be58a0297dd8c52a",
            "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDCfqktXEVPQZv2\nSbAP4KD6GYbYaYRw0XDWPa0iFyyoqpJ6QUan0WHuBbRFoXMo05Js/3n0jl0NOUOj\nJG3/jTmfAQzx17cRAGEi7i5fpKshCa4Pkv0Sl8vBEmmbnfSt/mDHHLHsfN1RtjL3\nnRMERyE6rPtAJWzsnJuJe/io/KjeIJMBpWcuCI4beplBvS/Vs8cYOkH5xNaSlUPy\nTcvOsbCM/UDk+7GZYePks/h22JQEmVRAHgAxssoEB7RQVPVfu8l9XOSjyZpghCmI\nkZuQ8fMtd8u1Qp3OhVxojPRb9gqglQLY6cL/HpMyt7KTMLrW93hs4+hyCYZLh9qA\nGgz+py15AgMBAAECggEADXLsOGCBw2v+QJ7ST5rBDuI+fo73U0TMSGg95VZUZnpb\nBByo6dhS7P5Ue58hIzDUFnjpAjXo7c3opSqS96GYmyvbrQp1VHXiAaQWLVNp6PAu\nKtIHcWZxNrHS/ymCPpjRMNuFWxy8Qhb2+cPRCZHwlInbGtGrsUXYBH7/0BGejLN1\nksyevyedA4ibTdwVpUDz6w6+yPL5T6Ea8GAr27yARFz2neBxozMarTSXTZabknJN\n+ssPnL3xZDRiTYVVEKNZWaoVIswzyEjRenjx1wCdCXY/m/CrgRX0thoBgJr1lnJo\nD7K6UVZZcnC1i1o9eP9zjrpDaMsS8PRedoJnQp8OQQKBgQDfouaapDIRfrpVxJcL\nDJa/8+IOLgc+LuNVKftKtzEg2ZiVJAw0jorUwGqOlN+ZeWhjV6mnREs9rHJJFLGm\nMT50nYOkVMClL3/smUdG6bZO7BwCl6W4rpTn8Z2QPMbMWuZka0Mzk3ROd227DGrk\n29SdytENFy4VOeMvenU//3vf2QKBgQDepCWYOhwSxPcf+PQtfobIPUo3OxUgXrNM\nfKWzh1xoRzckDw7lcUWIb+0i3T8d0aCgZ18u1s4kJsnpfoPMBuFu2/RguhCmap3r\nUWsbDNyYLR5u4Dhqf4JPbpOPalU8eET+4S9r15SWoE5U5saxbrScLEXx0hv0Wc5k\nDIAxpaDWoQKBgQDAdt/j4r+8UsZmngQn3DO5C1lXPsG5AH1hg/niuXosfVhVsmpW\nqP5OTzLldrZgzR3LsVwuuhXPBCRvRMIG94Z6sjzjJpWNFC4SH3A6VVUy4vzQNlbH\ndGhunYAu7D9jDDAP6EgzkQmdpibnva4ZPB/llPEJRRPB7MnayJcz9tpTMQKBgBWB\nEUiExFVjxOLHrv397JLGqLZw9Hdt7i+DEpYmitxflIndEnlC2Y52ERd++yusJbGY\nim8BvGNtg68T0zMPrxKAGDiHgDgysBIciRXRxjTElt3qtkhDDJkTexktEhKHI1Li\n+SuXZPivfyFgMOzOXo9/DzpuKtkNG4w6UN96ufBBAoGARJpqW6zMNgkUIBYKLqyK\nzcapzlQPKhrFS/qiPxdBn1V6mZtCDFr3Kl+hjtkIN+6kzxIx7Cl+mAzzBJoiZ7as\nua+C6HneKaR1X6E39xGt7tcBvFJcoCFMOnD++S4ER76DQ05ZPwxf8wt2qk0s7EkM\n1V/WrO90/H+GcIc25aQVgSM=\n-----END PRIVATE KEY-----\n",
            "client_email": "firebase-adminsdk-yqmms@carehub-af7ec.iam.gserviceaccount.com",
            "client_id": "103536856579389231767",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-yqmms%40carehub-af7ec.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          }
      ),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
