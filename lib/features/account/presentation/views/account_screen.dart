import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/utils/launcher_utils.dart';
import 'package:patria/features/account/presentation/views/personal_information_screen.dart';
import 'package:patria/features/account/presentation/views/saved_addresses_screen.dart';
import 'package:patria/features/account/presentation/views/widgets/account_section.dart';
import 'package:patria/features/account/presentation/views/widgets/language_bottom_sheet.dart';
import 'package:patria/features/account/presentation/views/widgets/privacy_screen.dart';
import 'package:patria/features/account/presentation/views/widgets/terms_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'widgets/account_menu_item.dart';
import 'widgets/points_card.dart';

class AccountScreen extends StatefulWidget {
  final PersistentTabController controller;

  const AccountScreen({super.key, required this.controller});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';
  String _appVersion = '';
  String _userName = '';
  bool _isLoggedIn = false; // ✅ added

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadUserName();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = info.version);
    }
  }

  Future<void> _loadUserName() async {
    final token = await _userService.getUserToken();
    final userName = await _userService.getUserName();

    if (mounted) {
      setState(() {
        _isLoggedIn = token.isNotEmpty;
        _userName = userName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.controller.jumpToTab(0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20.w,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'nav_account'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.36,
                      ),
                    ),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
              SizedBox(height: 24.h),

              // User info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3C4119),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_sharp,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        _userName.isEmpty ? 'Loading...' : _userName,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 1.06.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ✅ Points card — only show when logged in
              // if (_isLoggedIn) ...[
              PointsCard(isLoggedIn: _isLoggedIn),
              SizedBox(height: 24.h),
              // ],

              // General section
              AccountSection(
                title: 'general'.tr(),
                items: [
                  AccountMenuItem(
                    title: 'personal_info'.tr(),
                    icon: Icons.person_outline,
                    onTap: () => PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const PersonalInformationScreen(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                  ),
                  AccountMenuItem(
                    title: 'delivery_addresses'.tr(),
                    icon: Icons.location_on_outlined,
                    onTap: () => PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const SavedAddressesScreen(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                  ),
                  AccountMenuItem(
                    title: 'language'.tr(),
                    icon: Icons.language,
                    onTap: () {
                      final currentLang = context.locale.languageCode;
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        useSafeArea: true,
                        builder: (_) => LanguageBottomSheet(
                          currentLanguage: currentLang,
                          onLanguageSelected: (lang) {
                            setState(() => _selectedLanguage = lang);
                            context.setLocale(Locale(lang));
                          },
                        ),
                      );
                    },
                  ),
                  AccountMenuItem(
                    title: 'notifications'.tr(),
                    icon: Icons.notifications_outlined,
                    isLast: true,
                    onTap: () => setState(
                      () => _notificationsEnabled = !_notificationsEnabled,
                    ),
                    trailing: GestureDetector(
                      onTap: () => setState(
                        () => _notificationsEnabled = !_notificationsEnabled,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 48.w,
                        height: 26.h,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _notificationsEnabled
                              ? const Color(0xFF3C4119)
                              : const Color(0xFFCACBD4),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          alignment: _notificationsEnabled
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Support section
              AccountSection(
                title: 'support'.tr(),
                items: [
                  AccountMenuItem(
                    title: 'help_center'.tr(),
                    icon: Icons.help_outline,
                    onTap: () => LauncherUtils.openWhatsAppSupport(),
                  ),
                  AccountMenuItem(
                    title: 'terms_conditions'.tr(),
                    icon: Icons.description_outlined,
                    onTap: () => PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const TermsScreen(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                  ),
                  AccountMenuItem(
                    title: 'privacy_policy'.tr(),
                    icon: Icons.privacy_tip_outlined,
                    isLast: true,
                    onTap: () => PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const PrivacyScreen(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                  ),
                ],
              ),

              // Logout section
              AccountSection(
                title: '',
                items: [
                  AccountMenuItem(
                    title: 'logout'.tr(),
                    icon: Icons.logout,
                    isLast: true,
                    onTap: () async {
                      await _userService.logout();
                      if (mounted) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamedAndRemoveUntil(
                          Routes.splashScreen,
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Version
              Center(
                child: Text(
                  'app_version'.tr(args: [_appVersion]),
                  style: const TextStyle(
                    color: Color(0xFFCACBD4),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.28,
                  ),
                ),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}
