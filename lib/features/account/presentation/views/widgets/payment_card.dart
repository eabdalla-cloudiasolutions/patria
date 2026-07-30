import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> method;
  final int index;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const PaymentCard({
    super.key,
    required this.method,
    required this.index,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ), // 👈 reduced from 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r), // slightly smaller radius
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero, // already zero
        dense: true, // 👈 ADD THIS – reduces ListTile's internal height
        leading: const Icon(
          Icons.credit_card,
          size: 22, // optionally smaller icon
          color: Color(0xFF3C4119),
        ),
        title: Text(
          method['cardNumber'],
          style: TextStyle(
            color: Colors.black,
            fontSize: 13.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.26,
          ),
        ),
        subtitle: Text(
          method['expires'],
          style: TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 10.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.20,
          ),
        ),
        trailing: GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xfffc90000),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
