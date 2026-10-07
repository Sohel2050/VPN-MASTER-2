import 'package:dio/dio.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/core/helpers/toast_notification/toast_notifications.dart';
import 'package:winsguard/core/network/interceptor/logger_interceptor.dart';

/// A Dio wrapper for making HTTP requests with centralized error handling and configuration.
class DioClient {
  final Dio _dio;

  /// Initializes the Dio instance with base options and interceptors.
  DioClient() : _dio = Dio(
    BaseOptions(
      contentType: "application/json; charset=UTF-8",
      responseType: ResponseType.json,
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
      // Defines which HTTP status codes should be considered successful.
      validateStatus: (status){
        if (status == null) return false;
        return (status >= 200 && status < 300);
      }
    ),
  ){
    // Adds a custom interceptor for logging network requests and responses.
    _dio.interceptors.addAll([
      LoggerInterceptor(),
    ]);
  }

  /// Performs a GET request.
  Future<Response<T>> get<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) async {
    return _handleRequest(() => _dio.get<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    ));
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    return _handleRequest(() => _dio.post<T>(
      url,
      data: data,
      options: options,
      queryParameters: queryParameters,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ));
  }

  /// Performs a PUT request.
  Future<Response<T>> put<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    return _handleRequest(() => _dio.put<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ));
  }

  /// Performs a PATCH request.
  Future<Response<T>> patch<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    return _handleRequest(() => _dio.patch<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ));
  }

  /// Performs a DELETE request.
  Future<Response<T>> delete<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return _handleRequest(() => _dio.delete<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ));
  }

  /// Performs a HEAD request.
  Future<Response<T>> head<T>(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return _handleRequest(() => _dio.head<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ));
  }

  /// A private helper to wrap Dio calls and handle exceptions.
  Future<Response<T>> _handleRequest<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      // Converts Dio-specific exceptions into a custom Failure type.
      throw dioExceptionToFailure(e);
    }
  }

  /// Maps a [DioException] to a corresponding [Failure] type.
  Failure dioExceptionToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        // Shows a toast notification for API errors.
        ToastNotifications.showApiErrorToast(
              e.response?.statusCode ?? 500, e.response?.data["message"]);
        return ApiFailure(
          e.response?.statusCode ?? 500,
          "${e.response?.data["message"]}",
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure("Request timeout, please try again.");
      case DioExceptionType.cancel:
        return const UnknownFailure("Request was cancelled.");
      case DioExceptionType.unknown:
      default:
        return const UnknownFailure("Something went wrong. Please check your internet connection.");
    }
  }
}
