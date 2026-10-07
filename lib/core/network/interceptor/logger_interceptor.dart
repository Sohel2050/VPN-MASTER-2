import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A custom Dio interceptor that logs network requests, responses, and errors in a structured format.
class LoggerInterceptor extends Interceptor {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: false,
      printEmojis: true,
    ),
    output: DebugPrintOutput(),
  );

  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        final decoded = json.decode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  /// Intercepts outgoing requests to log their details before they are sent.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln("➡️ ${options.method} Request")
      ..writeln("🔗 URI: ${options.uri}")
      ..writeln("📍 Endpoint: ${options.path}")
      ..writeln("📦 Headers: ${options.headers}");

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln("❓ Query Params: ${options.queryParameters}");
    }

    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        final fields =
        formData.fields.map((e) => "${e.key}: ${e.value}").join(", ");
        final files = formData.files
            .map((f) => "${f.key}: ${f.value.filename}")
            .join(", ");
        buffer.writeln("📝 FormData Fields: {$fields}");
        if (formData.files.isNotEmpty) {
          buffer.writeln("📎 FormData Files: {$files}");
        }
      } else {
        buffer.writeln("📝 Body: ${_prettyJson(options.data)}");
      }
    }

    options.extra["requestLog"] = buffer.toString();
    options.extra["startTime"] = DateTime.now();
    handler.next(options);
  }

  /// Intercepts successful responses to log their details.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final reqLog = response.requestOptions.extra["requestLog"] ?? "";
    final startTime = response.requestOptions.extra["startTime"] as DateTime?;
    final duration =
    startTime != null ? DateTime.now().difference(startTime) : null;

    final resLog = StringBuffer()
      ..writeln("⬅️ Response")
      ..writeln(
          "STATUS: ${response.statusCode} ${response.statusMessage}  ⏱️ ${duration?.inMilliseconds}ms")
      ..writeln("HEADERS: ${response.headers}")
      ..writeln("BODY:\n${_prettyJson(response.data)}");

    logger.i("$reqLog\n$resLog");
    handler.next(response);
  }

  /// Intercepts errors to log their details.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final reqLog = err.requestOptions.extra["requestLog"] ?? "";
    final startTime = err.requestOptions.extra["startTime"] as DateTime?;
    final duration =
    startTime != null ? DateTime.now().difference(startTime) : null;

    final errorLog = StringBuffer()
      ..writeln("❌ ERROR  ⏱️ ${duration?.inMilliseconds}ms")
      ..writeln("TYPE: ${err.type}")
      ..writeln("MESSAGE: ${err.message}");

    if (err.response?.data != null) {
      errorLog.writeln("BODY:\n${_prettyJson(err.response?.data)}");
    }

    logger.e("$reqLog\n$errorLog");
    handler.next(err);
  }
}

/// A custom LogOutput that splits long log messages into smaller chunks
/// to prevent truncation by Flutter's default `debugPrint`.
class DebugPrintOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    const chunkSize = 800;
    for (var line in event.lines) {
      if (line.length <= chunkSize) {
        debugPrint(line);
      } else {
        for (var i = 0; i < line.length; i += chunkSize) {
          debugPrint(line.substring(
              i, i + chunkSize > line.length ? line.length : i + chunkSize));
        }
      }
    }
  }
}
