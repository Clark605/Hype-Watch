// ── Error message helper ─────────────────────────────────────────────────────
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class ErrorMessageHelper {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _dioExceptionMessage(error);
    } else if (error is SocketException) {
      return 'No internet connection.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. Check your internet connection.';
    } else {
      return 'Something went wrong. Try again.';
    }
  }
}

String _dioExceptionMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Check your internet connection.';
    case DioExceptionType.connectionError:
      return 'No internet connection.';
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return 'Session expired. Please restart the app.';
      }
      if (statusCode == 404) return 'Data not found.';
      if (statusCode == 500) return 'Server error. Try again later.';
      return 'Server returned error $statusCode.';
    default:
      return 'Something went wrong. Try again.';
  }
}
