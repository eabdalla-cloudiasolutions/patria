// ✅ lib/core/network/interceptors/error_interceptor.dart
import 'package:dio/dio.dart';
import 'package:patria/core/notifications/notification_navigation.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';

import '../api_error_handler.dart';

class ErrorInterceptor extends Interceptor {
  // Any of these server `code` values mean the session is no longer
  // usable and the user should be logged out automatically.
  static const _autoLogoutCodes = {'TOKEN_EXPIRED', 'ACCOUNT_DELETED'};

  // Guards against piling up multiple logout/navigation attempts if
  // several in-flight requests all come back with one of the codes
  // above at once (e.g. a screen that fires a few API calls in parallel).
  static bool _isLoggingOutFromApiError = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Use your ApiErrorHandler here!
    final message = ApiErrorHandler.handle(err);

    // Optionally log it
    // debugPrint('❌ API Error: $message');

    // ✅ Auto-logout on an expired/deleted session — same behavior as the
    // manual "Logout" button (clear the stored session, then reset the
    // nav stack to the splash screen), just triggered from any API call
    // instead of a user tap. Matched on the server's `code` field
    // (rather than just the 401 status) so it only fires for these
    // specific cases, not every generic "unauthorized" response.
    final data = err.response?.data;
    if (data is Map<String, dynamic> &&
        _autoLogoutCodes.contains(data['code'])) {
      _logOutFromApiError();
    }

    handler.next(err); // still propagate so repos can catch
  }

  Future<void> _logOutFromApiError() async {
    if (_isLoggingOutFromApiError) return;
    _isLoggingOutFromApiError = true;
    try {
      await UserService().logout();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.splashScreen,
        (route) => false,
      );
    } finally {
      _isLoggingOutFromApiError = false;
    }
  }
}
