import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final dynamic data = error.response?.data;

    // ✅ Safely extract message if data is a Map
    if (data is Map<String, dynamic>) {
      final serverMessage = data['message'];
      if (serverMessage != null && serverMessage is String) {
        return serverMessage;
      }
    }

    // ✅ If data is a String (HTML, plain text, etc.) – return a generic message
    if (data is String) {
      // Optionally log the raw response for debugging
      print('Raw error response: $data');
      return _handleStatusCode(statusCode);
    }

    // Fallback
    return _handleStatusCode(statusCode);
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
      case 502: // ✅ Explicit handling for 502
        return 'Bad gateway. The server received an invalid response.';
      case 503:
        return 'Service unavailable. Please try later.';
      default:
        return 'Unexpected error occurred (Code: $statusCode).';
    }
  }
}
