import 'package:easy_localization/easy_localization.dart';

class Validators {
  // Egyptian mobile, local format: 01[0125]XXXXXXXX
  static final RegExp _egyptPhoneRegExp = RegExp(r'^01[0125][0-9]{8}$');

  // Gulf (GCC) mobile numbers. The local formats are ambiguous between
  // countries (e.g. Saudi and UAE both use 05XXXXXXXX) and OTPs go out over
  // WhatsApp, so the country code is required, with an optional "+" or "00".
  static final RegExp _gulfPhoneRegExp = RegExp(
    r'^(?:\+|00)?(?:'
    r'9665[0-9]{8}' // Saudi Arabia
    r'|9715[0-9]{8}' // UAE
    r'|965[569][0-9]{7}' // Kuwait
    r'|974[3567][0-9]{7}' // Qatar
    r'|973[36][0-9]{7}' // Bahrain
    r'|968[79][0-9]{7}' // Oman
    r')$',
  );

  static bool _isValidPhone(String value) =>
      _egyptPhoneRegExp.hasMatch(value) || _gulfPhoneRegExp.hasMatch(value);

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'please_enter_phone'.tr();
    }
    if (!_isValidPhone(trimmed)) {
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
    if (!_isValidPhone(trimmed)) {
      return 'invalid_phone_number'.tr();
    }
    return null;
  }

  /// Rejects empty input and input that's nothing but whitespace.
  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'please_enter_name'.tr();
    }
    return null;
  }
}
