import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/previous_orders/presentation/manager/review_bloc.dart';
import 'package:erb/features/previous_orders/presentation/manager/review_event.dart';
import 'package:erb/features/previous_orders/presentation/manager/review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RateOrderScreen extends StatefulWidget {
  final String orderId;
  final String? productImage;
  final String? productName;
  final int initialRating;

  const RateOrderScreen({
    super.key,
    required this.orderId,
    this.productImage,
    this.productName,
    this.initialRating = 0,
  });

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  late int _rating;
  final TextEditingController _feedbackController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Food quality',
    'Service speed',
    'Cleanliness',
    'Driver friendliness',
    'Value for money',
  ];

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // Accept BuildContext parameter to use the correct context from inside BlocBuilder
  void _submitFeedback(BuildContext context) {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_rating'.tr())),
      );
      return;
    }

    context.read<ReviewBloc>().add(
          SubmitReviewEvent(
            orderId: widget.orderId,
            rating: _rating,
            comment: _feedbackController.text.trim(),
            tags: _selectedTags,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, null),
          ),
          title: Text(
            'rate_order'.tr(),
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocListener<ReviewBloc, ReviewState>(
            listener: (context, state) {
              if (state is ReviewSuccess) {
                Navigator.pop(context, _rating);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('thank_you_for_feedback'.tr())),
                );
              } else if (state is ReviewError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: BlocBuilder<ReviewBloc, ReviewState>(
              builder: (context, state) {
                final isSubmitting = state is ReviewSubmitting;

                return ListView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 24.h,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                  ),
                  children: [
                    // Product image and title
                    Column(
                      children: [
                        Container(
                          width: 88.w,
                          height: 91.h,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: widget.productImage != null
                                  ? NetworkImage(widget.productImage!)
                                  : const AssetImage(
                                          'assets/images/erbLogo.png')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'rate_your_order_from_erb'.tr(),
                          style: TextStyle(
                            color: const Color(0xFF28293D),
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.32,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Rating stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = index + 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              size: 32.sp,
                              color: const Color(0xFFFFB800),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24.h),

                    // Feedback section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'add_feedback'.tr(),
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.32,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _feedbackController,
                          maxLines: 4,
                          maxLength: 150,
                          decoration: InputDecoration(
                            hintText: 'write_feedback_hint'.tr(),
                            hintStyle: TextStyle(
                              color: const Color(0xFF8B8B8B),
                              fontSize: 13.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                  color: Color(0xFF8B8B8B), width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                  color: Color(0xFF8B8B8B), width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                  color: Color(0xFF6B5E4B), width: 1.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Tags
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: _availableTags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedTags.remove(tag);
                                  } else {
                                    _selectedTags.add(tag);
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6B5E4B)
                                      : const Color(0xFFE5E5E5),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6B5E4B)
                                        : const Color(0xFFCACBD4),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.28,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24.h),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _submitFeedback(
                                    context), // ✅ Pass correct context
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B5E4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                            child: isSubmitting
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'submit_feedback'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
