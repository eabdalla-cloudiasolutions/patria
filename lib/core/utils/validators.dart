import 'package:easy_localization/easy_localization.dart';

class Validators {
  static final RegExp _egyptPhoneRegExp = RegExp(r'^01[0125][0-9]{8}$');

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'please_enter_phone'.tr();
    }
    if (!_egyptPhoneRegExp.hasMatch(trimmed)) {
      return 'invalid_phone_number'.tr();
    }
    return null;
  }

  /// Same format check as [phone], but empty input is allowed (field optional).
  static String? optionalPhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (!_egyptPhoneRegExp.hasMatch(trimmed)) {
      return 'invalid_phone_number'.tr();
    }
    return null;
  }
}
