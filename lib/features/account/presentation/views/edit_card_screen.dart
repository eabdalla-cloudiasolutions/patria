// import 'package:erb/features/account/presentation/views/widgets/edit_card_form.dart';
// import 'package:erb/features/account/presentation/views/widgets/edit_card_preview.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class EditCardScreen extends StatefulWidget {
//   final Map<String, dynamic> card;

//   const EditCardScreen({
//     super.key,
//     required this.card,
//   });

//   @override
//   State<EditCardScreen> createState() => _EditCardScreenState();
// }

// class _EditCardScreenState extends State<EditCardScreen> {
//   late TextEditingController _cardNumberController;
//   late TextEditingController _cardHolderController;
//   late TextEditingController _expiryController;
//   late TextEditingController _cvvController;

//   @override
//   void initState() {
//     super.initState();
//     _cardNumberController =
//         TextEditingController(text: widget.card['cardNumber'] ?? '');
//     _cardHolderController =
//         TextEditingController(text: widget.card['cardHolder'] ?? '');
//     _expiryController =
//         TextEditingController(text: widget.card['expiry'] ?? '');
//     _cvvController = TextEditingController(text: widget.card['cvv'] ?? '');
//   }

//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _cardHolderController.dispose();
//     _expiryController.dispose();
//     _cvvController.dispose();
//     super.dispose();
//   }

//   void _deleteCard() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         title: Text(
//           'delete_card'.tr(),
//           style: const TextStyle(
//             fontFamily: 'Montserrat',
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//         ),
//         content: Text(
//           'delete_card_message'.tr(),
//           style: TextStyle(
//             fontFamily: 'Montserrat',
//             fontWeight: FontWeight.w400,
//             fontSize: 14.sp,
//             color: Color(0xFF515151),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'cancel'.tr(),
//               style: const TextStyle(
//                 color: Color(0xFF6B5E4B),
//                 fontFamily: 'Montserrat',
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context, {'deleted': true});
//             },
//             child: Text(
//               'delete'.tr(),
//               style: const TextStyle(
//                 color: Color(0xFFC90000),
//                 fontFamily: 'Montserrat',
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _saveChanges() {
//     final updatedCard = {
//       ...widget.card,
//       'cardNumber': _cardNumberController.text,
//       'cardHolder': _cardHolderController.text,
//       'expiry': _expiryController.text,
//       'cvv': _cvvController.text,
//     };
//     Navigator.pop(context, {'updated': updatedCard});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF7F7F7),
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         title: Text(
//           'edit_card'.tr(),
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18.sp,
//             fontFamily: 'Montserrat',
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.36,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 16.w),
//             child: GestureDetector(
//               onTap: _deleteCard,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF0F0),
//                   borderRadius: BorderRadius.circular(5.r),
//                 ),
//                 child: Text(
//                   'delete'.tr(),
//                   style: TextStyle(
//                     color: Color(0xFFC90000),
//                     fontSize: 12.sp,
//                     fontFamily: 'Montserrat',
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 16.h),
//                   ValueListenableBuilder(
//                     valueListenable: _cardNumberController,
//                     builder: (_, __, ___) => ValueListenableBuilder(
//                       valueListenable: _cardHolderController,
//                       builder: (_, __, ___) => EditCardPreview(
//                         cardNumber: _cardNumberController.text.isEmpty
//                             ? 'card_number_placeholder'.tr()
//                             : _cardNumberController.text,
//                         cardHolder: _cardHolderController.text.isEmpty
//                             ? 'cardholder_placeholder'.tr()
//                             : _cardHolderController.text.toUpperCase(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   EditCardForm(
//                     cardNumberController: _cardNumberController,
//                     cardHolderController: _cardHolderController,
//                     expiryController: _expiryController,
//                     cvvController: _cvvController,
//                   ),
//                   SizedBox(height: 32.h),
//                 ],
//               ),
//             ),
//           ),

//           // Save button pinned at bottom
//           Container(
//             padding: EdgeInsets.only(
//                 left: 20.w, right: 20.w, bottom: 32.h, top: 16.h),
//             color: const Color(0xFFF7F7F7),
//             child: SizedBox(
//               width: double.infinity,
//               height: 56.h,
//               child: ElevatedButton(
//                 onPressed: _saveChanges,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6B5E4B),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//                 child: Text(
//                   'save_changes'.tr(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp,
//                     fontFamily: 'Montserrat',
//                     fontWeight: FontWeight.w600,
//                     height: 1.50,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
