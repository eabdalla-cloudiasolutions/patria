import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:erb/core/widgets/delete_overlay.dart';
import 'package:erb/core/widgets/empty_state_widget.dart';
import 'package:erb/features/account/presentation/views/widgets/delete_button.dart';
import 'package:erb/features/auth/data/apis/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final UserService _userService = UserService();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // State variables
  DateTime? _selectedDate;
  bool _subscribeNewsletter = false;
  bool _pushNotifications = false;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning from login screen
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    // ✅ Reliable guest detection: check token + email
    final token = await _userService.getUserToken();
    final userEmail = await _userService.getUserEmail();
    final loggedIn = token.isNotEmpty && userEmail.isNotEmpty;

    if (loggedIn) {
      final userName = await _userService.getUserName();
      final userPhone = await _userService.getUserPhone();

      _nameController.text = userName;
      _emailController.text = userEmail;
      _phoneController.text = userPhone;
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!_isLoggedIn) return;

    setState(() => _isLoading = true);

    try {
      String? formattedDate;
      if (_selectedDate != null) {
        formattedDate =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      }

      await AuthApi().updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: formattedDate,
      );

      final userId = await _userService.getUserId();
      final userRole = await _userService.getUserRole();
      final userToken = await _userService.getUserToken();

      await _userService.saveUser(
        id: userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: userRole,
        token: userToken,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('changes_saved'.tr()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6B5E4B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'personal_info'.tr(),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isLoggedIn
              ? _buildLoggedInContent()
              : _buildGuestEmptyState(),
    );
  }

  Widget _buildGuestEmptyState() {
    return EmptyStateWidget(
      imagePath: 'assets/images/Empty User.png',
      title: 'sign_in_required'.tr(),
      subtitle: 'please_sign_in_to_view_personal_info'.tr(),
      buttonText: 'sign_in'.tr(),
      imagePadding: EdgeInsets.all(16),
      onButtonPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pushNamed(Routes.splashScreen)
            .then((_) => _loadUserData());
      },
    );
  }

  Widget _buildLoggedInContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          _buildFields(),
          SizedBox(height: 35.h),
          _buildCheckboxes(),
          SizedBox(height: 32.h),
          _buildSaveButton(),
          SizedBox(height: 20.h),
          DeleteButton(
            text: 'Delete Account',
            onPressed: () {
              ConfirmationBottomSheet.show(
                context: context,
                title: "Are you sure you want to delete your account?",
                subtitle:
                    "This action is irreversible and you won't be able to recover your account.",
                confirmText: "Delete account",
                cancelText: "Cancel",
                onConfirm: () {
                  // Handle account deletion
                },
                isDangerous: true,
              );
            },
          ),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'full_name'.tr(),
          controller: _nameController,
        ),
        SizedBox(height: 14.h),
        _buildTextField(
          label: 'email'.tr(),
          controller: _emailController,
          enabled: false,
        ),
        SizedBox(height: 14.h),
        _buildTextField(
          label: 'phone_number'.tr(),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 14.h),
        _buildDateField(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            color: enabled ? Colors.black : const Color(0xFF8B8B8B),
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFE5E5E5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    enabled ? const Color(0xFFE5E5E5) : const Color(0xFFCACBD4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFCACBD4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF6B5E4B)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final formatted = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/'
            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
            '${_selectedDate!.year}'
        : 'select_date'.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('date_of_birth'.tr()),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatted,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 20, color: Color(0xFF6B5E4B)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      children: [
        _buildCheckboxTile(
          title: 'subscribe_newsletter'.tr(),
          subtitle: 'subscribe_newsletter_sub'.tr(),
          value: _subscribeNewsletter,
          onChanged: (v) => setState(() => _subscribeNewsletter = v!),
        ),
        SizedBox(height: 14.h),
        _buildCheckboxTile(
          title: 'push_notifications'.tr(),
          subtitle: 'push_notifications_sub'.tr(),
          value: _pushNotifications,
          onChanged: (v) => setState(() => _pushNotifications = v!),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          height: 20.h,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
            side: const BorderSide(color: Color(0xFF6B5E4B)),
            activeColor: const Color(0xFF6B5E4B),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.26,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF8B8B8B),
                  fontSize: 11.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.22,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading || !_isLoggedIn ? null : _saveUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B5E4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'save_changes'.tr(),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 12.sp,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
