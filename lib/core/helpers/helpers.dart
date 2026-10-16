
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn_master/core/helpers/toast_notification/toast_notifications.dart';
import 'package:vpn_master/core/helpers/blocked_countries.dart';
import 'package:vpn_master/features/servers/data/models/vpn_server_model.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

class Helpers{
  const Helpers._();


  static String speedFromBitsPerSecond(int bitsPerSecond, {int decimals = 1,}) {
    if (bitsPerSecond <= 0) return "0 Mbps";

    const suffixes = ["bps", "Kbps", "Mbps", "Gbps", "Tbps"];
    const double base = 1000;

    final int index =
    (log(bitsPerSecond) / log(base)).floor().clamp(0, suffixes.length - 1);

    final double value = bitsPerSecond / pow(base, index);

    return "${value.toStringAsFixed(decimals)} ${suffixes[index]}";
  }


  static void sortServerList(List<VpnServerEntity> data){
    data.sort((serverA, serverB) {
      int speedCompare = (serverB.speed ?? 0).compareTo(serverA.speed ?? 0);
      if (speedCompare != 0) {
        return speedCompare;
      }
      final aPing = int.tryParse(serverA.ping ?? '0') ?? 0;
      final bPing = int.tryParse(serverB.ping ?? '0') ?? 0;
      int pingCompare = aPing.compareTo(bPing);
      if (pingCompare != 0) {
        return pingCompare;
      }
      return (serverA.numVpnSessions ?? 0).compareTo(serverB.numVpnSessions ?? 0);
    });
  }


  /// Calculate Network Score
  static String calculateNetworkScorePercentage({
    required double download,
    required double upload,
    required String unit, // "kbps" or "Mbps"
  }) {
    // Convert kbps → Mbps if needed
    double downloadMbps = unit.toLowerCase() == 'kbps' ? download / 1000 : download;
    double uploadMbps = unit.toLowerCase() == 'kbps' ? upload / 1000 : upload;

    // Define max expected speeds (for scaling to 100%)
    const double maxDownload = 100; // Mbps
    const double maxUpload = 50;    // Mbps

    // Weighted score: download 70%, upload 30%
    double score = (downloadMbps / maxDownload * 70) + (uploadMbps / maxUpload * 30);

    // Clamp to 0–100%
    if (score > 100) score = 100;
    if (score < 0) score = 0;

    return "${score.toStringAsFixed(2)}%";
  }




  /// Get Network Quality
  static String getNetworkQuality({
    required double download,
    required double upload,
    required String unit, // "kbps" or "Mbps"
  }) {
    // Convert to Mbps if unit is kbps
    double downloadMbps = unit.toLowerCase() == "kbps" ? download / 1000 : download;
    double uploadMbps = unit.toLowerCase() == "kbps" ? upload / 1000 : upload;

    // Determine quality
    if (downloadMbps >= 50 && uploadMbps >= 10) {
      return "Excellent";
    } else if (downloadMbps >= 20 && uploadMbps >= 5) {
      return "Good";
    } else if (downloadMbps >= 5 && uploadMbps >= 1) {
      return "Average";
    } else {
      return "Poor";
    }
  }




  /// Parses VPNGate CSV raw text into a list of models
  static List<VpnServerModel> csvToVpnServerModels(String rawText) {
    // Keep only the CSV lines: drop the "*vpn_servers" line and the trailing "*",
    // and remove the leading "#" of the header line.
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty && !line.startsWith('*'))
        .map((line) => line.startsWith('#') ? line.substring(1) : line)
        .toList();
    if (lines.length < 2) return [];

    final list = csv.decode(lines.join('\n'));
    if (list.length < 2) return [];

    final headers = list.first.map((e) => e.toString()).toList();

    return list
        .skip(1)
        .where((row) => row.length == headers.length)
        .map((row) => Map.fromIterables(headers, row))
        .map(VpnServerModel.fromJson)
        .where((server) => (server.openVPNConfigDataBase64 ?? '').isNotEmpty)
        // Servers in blocked countries (see BlockedCountries) are never shown.
        .where((server) => !BlockedCountries.isBlocked(
            code: server.countryShort, name: server.countryLong))
        .toList();
  }


  /// Opens [uri] in the browser / Play Store. Never throws.
  static Future<void> launchUri({required String uri}) async {
    final parsed = Uri.parse(uri);
    // Try the external app first, then the default mode (the device may have no Play Store).
    for (final mode in [LaunchMode.externalApplication, LaunchMode.platformDefault]) {
      try {
        if (await launchUrl(parsed, mode: mode)) return;
      } catch (_) {}
    }
    // Never fail silently: tell the user the tap was received.
    ToastNotifications.showErrorToast(
      title: "Cannot open link",
      message: "No app on this device can open this link.",
    );
  }

}
