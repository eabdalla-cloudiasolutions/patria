import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/widgets/delete_overlay.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/features/account/data/apis/payment_api.dart';
import 'package:patria/features/account/presentation/manager/payments_card/payment_bloc.dart';
import 'package:patria/features/account/presentation/manager/payments_card/payment_event.dart';
import 'package:patria/features/account/presentation/manager/payments_card/payment_state.dart';
import 'package:patria/features/account/presentation/views/add_payment_bottom_sheet.dart';
import 'package:patria/features/account/presentation/views/widgets/payment_card.dart';
import 'package:shimmer/shimmer.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final UserService _userService = UserService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _userService.getUserToken();
    final userEmail = await _userService.getUserEmail();
    final loggedIn = token.isNotEmpty && userEmail.isNotEmpty;

    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            'payment_methods'.tr(),
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
        body: EmptyStateWidget(
          imagePath: 'assets/images/Empty Card.png',
          title: 'no_payment_methods'.tr(),
          subtitle: 'please_sign_in_to_view_payment_methods'.tr(),
          buttonText: 'sign_in'.tr(),
          onButtonPressed: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(Routes.splashScreen).then((_) => _checkLoginStatus());
          },
        ),
      );
    }

    return BlocProvider(
      create: (_) => PaymentBloc()..add(LoadPaymentMethods()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            'payment_methods'.tr(),
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
        body: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ListView.separated(
                  itemCount: 2,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (state is PaymentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFCACBD4),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: const Color(0xFF8B8B8B),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PaymentBloc>().add(LoadPaymentMethods()),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is PaymentLoaded && state.methods.isEmpty) {
              return EmptyStateWidget(
                imagePath: 'assets/images/Empty Card.png',
                title: 'no_payment_methods'.tr(),
                subtitle: 'add_payment_method'.tr(),
                buttonText: 'add_new_payment'.tr(),
                onButtonPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddPaymentBottomSheet(),
                  );
                  if (result != null) {
                    context.read<PaymentBloc>().add(LoadPaymentMethods());
                  }
                },
              );
            }

            if (state is PaymentLoaded) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.methods.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (_, index) {
                          final method = state.methods[index];
                          final cardLast4 = method.last4;
                          final cardType = method.cardType;

                          return PaymentCard(
                            method: {
                              'id': method.id,
                              'cardNumber': '••••${method.last4}',
                              'expires':
                                  '${'expires_prefix'.tr()} ${method.expiryMonth}/${method.expiryYear}',
                              'cardholderName': method.cardholderName,
                              'cardType': method.cardType,
                              'isDefault': method.isDefault,
                              'icon': Icons.credit_card,
                            },
                            index: index,
                            onSetDefault: () async {
                              try {
                                await PaymentApi().setDefaultCard(method.id);
                                if (context.mounted) {
                                  context.read<PaymentBloc>().add(
                                    LoadPaymentMethods(),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFC90000),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior
                                          .floating, // ✅ removes safe area space
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h, // ✅ reduce height
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            onDelete: () async {
                              await ConfirmationBottomSheet.show(
                                context: context,
                                title: 'delete_payment_card_title'.tr(),
                                subtitle: 'delete_payment_card_subtitle'.tr(),
                                confirmText: 'delete_card'.tr(),
                                cancelText: 'cancel'.tr(),
                                onConfirm: () async {
                                  try {
                                    await PaymentApi().deleteCard(method.id);
                                    if (context.mounted) {
                                      context.read<PaymentBloc>().add(
                                        LoadPaymentMethods(),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'card_deleted_successfully'.tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: const Color(
                                            0xFF3C4119,
                                          ),
                                          behavior: SnackBarBehavior
                                              .floating, // ✅ removes safe area space

                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 16.h, // ✅ reduce height
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFFC90000,
                                          ),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior
                                              .floating, // ✅ removes safe area space
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 16.h, // ✅ reduce height
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                isDangerous: true,
                                isDismissible: true,
                                enableDrag: true,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildAddNewButton(context),
                    SizedBox(height: 32.h),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddPaymentBottomSheet(),
          );
          if (result != null) {
            context.read<PaymentBloc>().add(LoadPaymentMethods());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3C4119),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white, size: 18),
        label: Text(
          'add_new_payment'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
