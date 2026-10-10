import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vpn_master/core/constants/text_constants.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';

/// Data read from the remote update_config.json file.
class AppUpdateInfo {
  final String minVersion;
  final String latestVersion;
  final String message;
  final String? playStoreUrl;
  final String? appStoreUrl;

  const AppUpdateInfo({
    required this.minVersion,
    required this.latestVersion,
    required this.message,
    this.playStoreUrl,
    this.appStoreUrl,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
        minVersion: (json['min_version'] ?? '0.0.0').toString(),
        latestVersion: (json['latest_version'] ?? '0.0.0').toString(),
        message: (json['update_message'] ??
                'A new version is available with bug fixes and improvements.')
            .toString(),
        playStoreUrl: json['play_store_url']?.toString(),
        appStoreUrl: json['app_store_url']?.toString(),
      );
}

/// Checks the remote config and asks the user to update.
///
/// - installed version < `min_version`    -> forced update (dialog cannot be closed)
/// - installed version < `latest_version` -> optional update (user can tap "Later")
///
/// If the config cannot be downloaded (offline, error) the app just continues.
class AppUpdateService {
  const AppUpdateService._();

  /// Raw JSON file hosted on GitHub.
  static const String configUrl =
      'https://raw.githubusercontent.com/Sohel2050/Vpn2-version-controller/main/update_config.json';

  static bool _checked = false;

  /// Runs the check once per app launch.
  static Future<void> check(BuildContext context) async {
    if (_checked) return;
    _checked = true;
    try {
      final info = await _fetch();
      if (info == null) return;
      final package = await PackageInfo.fromPlatform();
      if (!context.mounted) return;

      final current = package.version;
      if (compareVersions(current, info.minVersion) < 0) {
        await _showDialog(context, info, package.packageName, force: true);
      } else if (compareVersions(current, info.latestVersion) < 0) {
        await _showDialog(context, info, package.packageName, force: false);
      }
    } catch (e) {
      debugPrint('Update check skipped: $e');
    }
  }

  static Future<AppUpdateInfo?> _fetch() async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      responseType: ResponseType.plain,
      headers: {'Cache-Control': 'no-cache'},
    ));
    final response = await dio.get<String>(configUrl);
    final data = response.data;
    if (data == null || data.isEmpty) return null;
    return AppUpdateInfo.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  /// Returns a negative number if [a] < [b], 0 if equal, positive if [a] > [b].
  static int compareVersions(String a, String b) {
    List<int> parse(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final x = parse(a);
    final y = parse(b);
    final length = x.length > y.length ? x.length : y.length;
    for (var i = 0; i < length; i++) {
      final xi = i < x.length ? x[i] : 0;
      final yi = i < y.length ? y[i] : 0;
      if (xi != yi) return xi.compareTo(yi);
    }
    return 0;
  }

  /// Store link for this app. A link from the JSON is only used when it really
  /// belongs to this app's package id, so users are never sent to another app.
  static String _storeUrl(AppUpdateInfo info, String packageName) {
    final fallback = '${TextConstants.playStore}$packageName';
    if (Platform.isIOS) {
      final url = info.appStoreUrl;
      if (url != null && !url.contains('XXXXXXXXX')) return url;
      return fallback;
    }
    final url = info.playStoreUrl;
    if (url != null && url.contains(packageName)) return url;
    return fallback;
  }

  static Future<void> _showDialog(
    BuildContext context,
    AppUpdateInfo info,
    String packageName, {
    required bool force,
  }) {
    final storeUrl = _storeUrl(info, packageName);
    return showDialog<void>(
      context: context,
      barrierDismissible: !force,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return PopScope(
          // Back button is blocked on a forced update.
          canPop: !force,
          child: AlertDialog(
            backgroundColor: colors.secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.primary, width: 0.8),
            ),
            title: Text(
              force ? 'UPDATE REQUIRED' : 'UPDATE AVAILABLE',
              style: TextStyle(
                color: colors.primary,
                letterSpacing: 2,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              info.message,
              style: TextStyle(color: colors.textPrimary),
            ),
            actions: [
              if (!force)
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Later', style: TextStyle(color: colors.textSecondary)),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: const Color(0xFF0C0C0E),
                ),
                onPressed: () async {
                  try {
                    await Helpers.launchUri(uri: storeUrl);
                  } catch (e) {
                    debugPrint('Could not open store: $e');
                  }
                },
                child: const Text('Update now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
