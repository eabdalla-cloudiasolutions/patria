import 'package:flutter/services.dart';

/// Blocks emoji characters from being entered into a text field.
class EmojiInputFormatter extends TextInputFormatter {
  static final RegExp _emojiRegExp = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}'
    r'\u{1F1E6}-\u{1F1FF}\u{FE0F}\u{200D}]',
    unicode: true,
  );

  /// Strips emoji from [text]. Useful for controllers on widgets that don't
  /// expose an `inputFormatters` parameter (e.g. third-party text fields).
  static String stripEmoji(String text) => text.replaceAll(_emojiRegExp, '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!_emojiRegExp.hasMatch(newValue.text)) {
      return newValue;
    }
    final filteredText = newValue.text.replaceAll(_emojiRegExp, '');
    final offsetDiff = newValue.text.length - filteredText.length;
    return TextEditingValue(
      text: filteredText,
      selection: newValue.selection.copyWith(
        baseOffset: (newValue.selection.baseOffset - offsetDiff).clamp(
          0,
          filteredText.length,
        ),
        extentOffset: (newValue.selection.extentOffset - offsetDiff).clamp(
          0,
          filteredText.length,
        ),
      ),
    );
  }
}
