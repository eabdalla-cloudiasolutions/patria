import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.badResponse:
        // ✅ Try to get message from API response body first
        final serverMessage = error.response?.data?['message'];
        if (serverMessage != null) return serverMessage.toString();
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error.';
      case 500:
        return 'Server error. Please try later.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}
