import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/core/widgets/delete_overlay.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/features/account/presentation/views/widgets/delete_button.dart';
import 'package:patria/features/auth/data/apis/auth_api.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final UserService _userService = UserService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

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

    final token = await _userService.getUserToken();
    final userEmail = await _userService.getUserEmail();
    final loggedIn = token.isNotEmpty && userEmail.isNotEmpty;

    if (loggedIn) {
      final userName = await _userService.getUserName();
      final userPhone = await _userService.getUserPhone();

      _nameController.text = userName;
      _emailController.text = userEmail;
      _phoneController.text = userPhone;

      try {
        final profile = await AuthApi().getUserProfile();

        // Load date of birth
        final dobStr = profile['dateOfBirth'] as String?;
        if (dobStr != null && dobStr.isNotEmpty) {
          final dateTime = DateTime.parse(dobStr);
          _selectedDate = dateTime;
        }

        // ✅ Load preferences
        final preferences = profile['preferences'] as Map<String, dynamic>?;
        if (preferences != null) {
          _pushNotifications = preferences['notifications'] ?? false;
          _subscribeNewsletter = preferences['newsletter'] ?? false;
        }
      } catch (e) {
        // ignore: failed to fetch profile, keep defaults
      }
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

    final phoneError = Validators.phone(_phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError, style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFC90000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? formattedDate;
      if (_selectedDate != null) {
        formattedDate =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      }

      // ✅ Save preferences along with profile
      await AuthApi().updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: formattedDate,
        pushNotifications: _pushNotifications,
        newsletter: _subscribeNewsletter,
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
            content: Text(
              'changes_saved'.tr(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF3C4119),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.h),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final message = e is DioException
            ? ApiErrorHandler.handle(e)
            : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Color(0xFFC90000),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.h),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await _userService.logout();
      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Routes.splashScreen, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFFC90000),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.h),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final maxDateOfBirth = DateTime(now.year - 13, now.month, now.day);
    final initialDate = _selectedDate ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(maxDateOfBirth)
          ? maxDateOfBirth
          : initialDate,
      firstDate: DateTime(1900),
      lastDate: maxDateOfBirth,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF3C4119)),
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
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(Routes.splashScreen).then((_) => _loadUserData());
      },
    );
  }

  Widget _buildLoggedInContent() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
            text: 'delete_account'.tr(),
            onPressed: () {
              ConfirmationBottomSheet.show(
                context: context,
                title: 'delete_account_title'.tr(),
                subtitle: 'delete_account_subtitle'.tr(),
                confirmText: 'delete_account_confirm'.tr(),
                cancelText: 'cancel'.tr(),
                onConfirm: _deleteAccount,
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
        _StyledFormField(
          label: 'full_name'.tr(),
          controller: _nameController,
          hint: '',
          enabled: true,
        ),
        SizedBox(height: 14.h),
        _StyledFormField(
          label: 'email'.tr(),
          controller: _emailController,
          hint: '',
          enabled: false,
        ),
        SizedBox(height: 14.h),
        _StyledFormField(
          label: 'phone_number'.tr(),
          controller: _phoneController,
          hint: '',
          keyboardType: TextInputType.phone,
          enabled: true,
          validator: Validators.phone,
        ),
        SizedBox(height: 14.h),
        _buildDateField(),
      ],
    );
  }

  Widget _buildDateField() {
    final hasDate = _selectedDate != null;
    final formatted = hasDate
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/'
              '${_selectedDate!.month.toString().padLeft(2, '0')}/'
              '${_selectedDate!.year}'
        : 'select_date'.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'date_of_birth'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatted,
                  style: TextStyle(
                    color: const Color(
                      0xFF8B8B8B,
                    ), // ✅ always grey — matches text field
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xFF3C4119),
                ),
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
            side: const BorderSide(color: Color(0xFF3C4119)),
            activeColor: const Color(0xFF3C4119),
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
          backgroundColor: const Color(0xFF3C4119),
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

// ========== Focus‑aware Styled Form Field ==========
class _StyledFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;

  const _StyledFormField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.validator,
  });

  @override
  State<_StyledFormField> createState() => _StyledFormFieldState();
}

class _StyledFormFieldState extends State<_StyledFormField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _focusNode.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.enabled && _focusNode.hasFocus;
    final Color textColor = isFocused
        ? Colors.black
        : (widget.enabled ? const Color(0xFF8B8B8B) : const Color(0xFF8B8B8B));
    final Color hintColor = isFocused
        ? const Color(0xFF3C4119).withOpacity(0.7)
        : const Color(0xFF8B8B8B);
    final Color fillColor = widget.enabled
        ? Colors.white
        : const Color(0xFFE5E5E5);
    final Color borderColor = isFocused
        ? const Color(0xFF3C4119)
        : (widget.enabled ? const Color(0xFFE5E5E5) : const Color(0xFFCACBD4));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.enabled ? _focusNode : null,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          inputFormatters: [EmojiInputFormatter()],
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hint.isEmpty ? null : widget.hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 14.h,
            ),
            filled: true,
            fillColor: fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF3C4119)),
            ),
          ),
        ),
      ],
    );
  }
}
