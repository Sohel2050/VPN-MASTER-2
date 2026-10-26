import 'package:dio/dio.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/network/interceptor/logger_interceptor.dart';

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
  /// The messages tell the real reason so problems are easy to understand.
  Failure dioExceptionToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 500;
        return ApiFailure(code, "Server responded with error $code. Please try again later.");
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure("Request timed out. The server is slow or blocked on your network.");
      case DioExceptionType.badCertificate:
        return const NetworkFailure("Secure connection failed (bad certificate).");
      case DioExceptionType.connectionError:
        return NetworkFailure("Could not reach the server (${_short(e.error)}). Check your internet connection.");
      case DioExceptionType.cancel:
        return const UnknownFailure("Request was cancelled.");
      default:
        return UnknownFailure("Something went wrong (${_short(e.error)}).");
    }
  }

  String _short(Object? error) {
    final text = (error ?? "unknown").toString().replaceAll("\n", " ");
    return text.length > 80 ? "${text.substring(0, 80)}..." : text;
  }
}
