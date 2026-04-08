import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  static const String _supportWhatsApp = 'https://wa.me/201055651338';

  static Future<void> openWhatsAppSupport() async {
    final Uri whatsappUri = Uri.parse(_supportWhatsApp);
    final Uri fallbackUri =
        Uri.parse('https://web.whatsapp.com/send?phone=201055651338');

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // WhatsApp not installed, open in browser instead
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch: $e');
      }
    }
  }
}
