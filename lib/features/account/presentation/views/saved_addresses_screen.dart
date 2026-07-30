import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/widgets/delete_overlay.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/features/account/data/apis/addresses_api.dart';
import 'package:patria/features/account/data/models/address_model.dart';
import 'package:patria/features/account/presentation/manager/saved_address/addresses_bloc.dart';
import 'package:patria/features/account/presentation/manager/saved_address/addresses_event.dart';
import 'package:patria/features/account/presentation/manager/saved_address/addresses_state.dart';
import 'package:patria/features/checkout/presentation/views/new_address_screen.dart';
import 'package:shimmer/shimmer.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
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

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return const Color(0xFF059B5A);
      case 'work':
        return const Color(0xFF3574FF);
      default:
        return const Color(0xFF3C4119);
    }
  }

  Color _getLabelBgColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return const Color(0xFFEDF8F0);
      case 'work':
        return const Color(0xFFEDF4FB);
      default:
        return const Color(0xFFE5E8D3);
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
            'saved_addresses'.tr(),
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
          imagePath: 'assets/images/Empty Address.png',
          title: 'no_addresses'.tr(),
          subtitle: 'please_sign_in_to_view_addresses'.tr(),
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
      create: (_) => AddressesBloc()..add(LoadAddresses()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            'saved_addresses'.tr(),
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
        body: BlocBuilder<AddressesBloc, AddressesState>(
          builder: (context, state) {
            if (state is AddressesLoading) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ListView.separated(
                  itemCount: 2,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (state is AddressesError) {
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
                          context.read<AddressesBloc>().add(LoadAddresses()),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is AddressesLoaded && state.addresses.isEmpty) {
              return EmptyStateWidget(
                imagePath: 'assets/images/Group.png',
                title: 'no_addresses'.tr(),
                subtitle: 'add_delivery_address'.tr(),
                buttonText: 'add_new_address'.tr(),
                onButtonPressed: () async {
                  // ✅ Open NewAddressScreen first
                  await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const NewAddressScreen()),
                  );
                  if (context.mounted) {
                    context.read<AddressesBloc>().add(LoadAddresses());
                  }
                },
              );
            }

            if (state is AddressesLoaded) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.addresses.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (_, index) {
                          final address = state.addresses[index];
                          return _buildAddressCard(
                            context,
                            address,
                            index,
                            state.addresses,
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

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    int index,
    List<AddressModel> allAddresses,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressInfo(address),
          SizedBox(height: 14.h),
          Divider(color: const Color(0xFFCACBD4), height: 1.h),
          SizedBox(height: 14.h),
          _buildActionButtons(context, address, index, allAddresses),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(AddressModel address) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F2ED),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: Color(0xFF3C4119),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag(
                label: address.label,
                color: _getLabelColor(address.label),
                bgColor: _getLabelBgColor(address.label),
              ),
              if (address.isDefault) ...[
                SizedBox(width: 6.w),
                _buildTag(
                  label: 'address_default'.tr(),
                  color: const Color(0xFFF9A825),
                  bgColor: const Color(0xFFFFF8E6),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            address.street,
            style: TextStyle(
              color: const Color(0xFF28293D),
              fontSize: 13.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.26,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   address.city,
          //   style: TextStyle(
          //     color: const Color(0xFF515151),
          //     fontSize: 12.sp,
          //     fontFamily: 'Montserrat',
          //     fontWeight: FontWeight.w400,
          //     letterSpacing: 0.24,
          //   ),
          // ),
          SizedBox(height: 2.h),
          Text(
            address.zone,
            style: TextStyle(
              color: const Color(0xFF8B8B8B),
              fontSize: 10.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AddressModel address,
    int index,
    List<AddressModel> allAddresses,
  ) {
    return Row(
      children: [
        if (!address.isDefault) ...[
          Expanded(
            child: GestureDetector(
              onTap: () async {
                try {
                  await AddressesApi().setDefaultAddress(address.id);
                  if (context.mounted) {
                    context.read<AddressesBloc>().add(LoadAddresses());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'address_set_as_default'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF3C4119),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFC90000),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8D3),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_outline,
                      size: 16,
                      color: Color(0xFF3C4119),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'set_as_default'.tr(),
                      style: TextStyle(
                        color: const Color(0xFF3C4119),
                        fontSize: 12.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
        ],

        // Edit button
        GestureDetector(
          onTap: () async {
            final result = await Navigator.of(context, rootNavigator: true)
                .pushNamed(
                  Routes.editAddress,
                  arguments: {'address': address.toJson()},
                );
            if (result != null) {
              context.read<AddressesBloc>().add(LoadAddresses());
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFF3C4119)),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              'edit'.tr(),
              style: TextStyle(
                color: const Color(0xFF3C4119),
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),

        // Delete button
        GestureDetector(
          onTap: () async {
            await ConfirmationBottomSheet.show(
              context: context,
              title: "delete_address_message".tr(),
              subtitle: "delete_address_subtitle".tr(),
              confirmText: "delete_address".tr(),
              cancelText: "cancel".tr(),
              onConfirm: () async {
                try {
                  await AddressesApi().deleteAddress(address.id);
                  if (context.mounted) {
                    context.read<AddressesBloc>().add(LoadAddresses());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'address_deleted_successfully'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF3C4119),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFC90000),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    );
                  }
                }
              },
              isDangerous: true,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC90000),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Image.asset(
              "assets/images/trash-option.png",
              height: 16,
              width: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.20,
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
          // ✅ Open NewAddressScreen first (map screen)
          await Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (_) => const NewAddressScreen()));
          if (context.mounted) {
            context.read<AddressesBloc>().add(LoadAddresses());
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
          'add_new_address'.tr(),
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
