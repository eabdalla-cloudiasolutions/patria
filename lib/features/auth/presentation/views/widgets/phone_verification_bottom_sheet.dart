import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/auth/presentation/views/widgets/otp_verification_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneVerificationBottomSheet extends StatefulWidget {
  const PhoneVerificationBottomSheet({super.key});

  @override
  State<PhoneVerificationBottomSheet> createState() =>
      _PhoneVerificationBottomSheetState();
}

class _PhoneVerificationBottomSheetState
    extends State<PhoneVerificationBottomSheet> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Color(0xFFFAFAF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'welcome_to_erb'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  height: 1.07,
                  letterSpacing: 0.40,
                ),
              ),

              SizedBox(height: 6.h),

              // Subtitle
              Text(
                'enter_phone_for_otp'.tr(),
                style: TextStyle(
                  color: Color(0xFF515151),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.40,
                  letterSpacing: 0.32,
                ),
              ),

              const SizedBox(height: 24),

              // Phone label
              Text(
                'phone_number'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 10.h),

              // Phone field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: Color(0xFF8B8B8B),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: '+20 1XX XXX XXXX',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF8B8B8B),
                    size: 24,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      width: 1.w,
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      width: 1.w,
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 32.h),

              // Send OTP button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => OtpVerificationBottomSheet(
                      phoneNumber: '+20 1XX XXX XXXX', // pass the actual number
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5E4B),
                  minimumSize: Size(double.infinity, 56.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: Text(
                  'send_otp'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
