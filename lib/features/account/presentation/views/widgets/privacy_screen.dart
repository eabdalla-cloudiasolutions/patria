import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'privacy_title'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.36,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: _buildFormattedText('privacy_content'.tr()),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(SizedBox(height: 8.h));
        continue;
      }

      final isTitle = RegExp(r'^\d+\.\d+\s').hasMatch(line);
      final isMainTitle = RegExp(r'^\d+\.\s').hasMatch(line) && !isTitle;

      if (isTitle || isMainTitle) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 4.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3C4119),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: const Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
