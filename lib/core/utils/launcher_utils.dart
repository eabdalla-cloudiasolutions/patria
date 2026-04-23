import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  static const String _supportWhatsApp = 'https://wa.me/201055651338';
  static const String _supportPhone = 'tel:+201055651338'; // 👈 add your number

  static Future<void> openWhatsAppSupport() async {
    final Uri whatsappUri = Uri.parse(_supportWhatsApp);
    final Uri fallbackUri =
        Uri.parse('https://web.whatsapp.com/send?phone=201055651338');

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch: $e');
      }
    }
  }

  // 👇 add this
  static Future<void> callSupport() async {
    final Uri phoneUri = Uri.parse(_supportPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        debugPrint('Could not launch phone dialer');
      }
    } catch (e) {
      debugPrint('Could not call support: $e');
    }
  }
}
