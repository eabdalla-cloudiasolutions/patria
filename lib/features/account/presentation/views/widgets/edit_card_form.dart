// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class EditCardForm extends StatelessWidget {
//   final TextEditingController cardNumberController;
//   final TextEditingController cardHolderController;
//   final TextEditingController expiryController;
//   final TextEditingController cvvController;

//   const EditCardForm({
//     super.key,
//     required this.cardNumberController,
//     required this.cardHolderController,
//     required this.expiryController,
//     required this.cvvController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildField(
//           context,
//           'card_number'.tr(),
//           'card_number_placeholder'.tr(),
//           cardNumberController,
//           keyboardType: TextInputType.number,
//         ),
//         SizedBox(height: 16.h),
//         _buildField(
//           context,
//           'cardholder_name'.tr(),
//           'cardholder_name_hint'.tr(),
//           cardHolderController,
//           textCapitalization: TextCapitalization.characters,
//         ),
//         SizedBox(height: 16.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildField(
//                 context,
//                 'expiry_date'.tr(),
//                 'expiry_date_hint'.tr(),
//                 expiryController,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildField(
//                 context,
//                 'cvv'.tr(),
//                 'cvv_hint'.tr(),
//                 cvvController,
//                 keyboardType: TextInputType.number,
//                 obscureText: true,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildField(
//     BuildContext context,
//     String label,
//     String hint,
//     TextEditingController controller, {
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//     TextCapitalization textCapitalization = TextCapitalization.none,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 12.sp,
//             fontFamily: 'Montserrat',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 10.h),
//         SizedBox(
//           height: 50.h,
//           child: TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             obscureText: obscureText,
//             textCapitalization: textCapitalization,
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontFamily: 'Montserrat',
//               fontWeight: FontWeight.w400,
//               color: Colors.black,
//             ),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 color: Color(0xFF8B8B8B),
//                 fontSize: 16.sp,
//                 fontFamily: 'Montserrat',
//                 fontWeight: FontWeight.w400,
//               ),
//               contentPadding:
//                   EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//                 borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//                 borderSide: const BorderSide(color: Color(0xFF3C4119)),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
