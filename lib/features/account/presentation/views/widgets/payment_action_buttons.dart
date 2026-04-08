// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class PaymentActionButtons extends StatelessWidget {
//   final bool isDefault;
//   final VoidCallback onSetDefault;
//   final VoidCallback onDelete;
//   // final VoidCallback onEdit;

//   const PaymentActionButtons({
//     super.key,
//     required this.isDefault,
//     required this.onSetDefault,
//     required this.onDelete,
//     // required this.onEdit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         if (!isDefault) ...[
//           Expanded(
//             child: GestureDetector(
//               onTap: onSetDefault,
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 8.h),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF5F0EA),
//                   borderRadius: BorderRadius.circular(5.r),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.star_outline,
//                         size: 16, color: Color(0xFF6B5E4B)),
//                     SizedBox(width: 6.w),
//                     Text(
//                       'set_as_default'.tr(),
//                       style: TextStyle(
//                         color: Color(0xFF6B5E4B),
//                         fontSize: 12.sp,
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 14.w),
//         ],

//         // Edit button
//         // GestureDetector(
//         //   onTap: onEdit,
//         //   child: Container(
//         //     padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
//         //     decoration: ShapeDecoration(
//         //       shape: RoundedRectangleBorder(
//         //         side: const BorderSide(color: Color(0xFF6B5E4B)),
//         //         borderRadius: BorderRadius.circular(5.r),
//         //       ),
//         //     ),
//         //     child: Text(
//         //       'edit'.tr(),
//         //       style: TextStyle(
//         //         color: Color(0xFF6B5E4B),
//         //         fontSize: 12.sp,
//         //         fontFamily: 'Montserrat',
//         //         fontWeight: FontWeight.w600,
//         //       ),
//         //     ),
//         //   ),
//         // ),
//         // SizedBox(width: 14.w),

//         // Delete button
//         GestureDetector(
//           onTap: onDelete,
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFF0F0),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: const Icon(
//               Icons.delete_outline,
//               size: 16,
//               color: Color(0xFFE53935),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
