import 'package:easy_localization/easy_localization.dart';

extension TranslateHelper on String {
  String get trKey {
    final key = toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(':', '')
        .replaceAll('&', 'and');

    final translated = key.tr();

    return translated == key ? this : translated;
  }
}
