import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vpn_master/core/constants/api_urls.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Loads your own (private) VPS servers.
///
/// 1. Tries the online file (ApiUrls.ownServers) so you can add servers without
///    updating the app.
/// 2. If that fails, uses assets/config/own_servers.json inside the app.
///
/// File format:
/// { "servers": [ { "name": "Singapore 1", "country": "Singapore", "country_short": "SG",
///   "ip": "203.0.113.10", "username": "", "password": "", "ovpn_base64": "..." } ] }
/// Use "ovpn" (the plain text of the .ovpn file) instead of "ovpn_base64" if you prefer.
class OwnServersSource {
  const OwnServersSource._();

  /// Returns the list of private servers (empty when none are configured).
  static Future<List<VpnServerEntity>> load() async {
    String? raw;
    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        responseType: ResponseType.plain,
      )).get(ApiUrls.ownServers);
      raw = response.data?.toString();
    } catch (_) {}

    var servers = _parse(raw);
    if (servers.isEmpty) {
      try {
        servers = _parse(await rootBundle.loadString('assets/config/own_servers.json'));
      } catch (_) {}
    }
    return servers;
  }

  static List<VpnServerEntity> _parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final data = json.decode(raw);
      final list = (data is Map ? data['servers'] : data) as List? ?? [];
      final result = <VpnServerEntity>[];
      for (final item in list) {
        if (item is! Map) continue;
        final base64Config = item['ovpn_base64']?.toString() ??
            (item['ovpn'] != null ? base64Encode(utf8.encode(item['ovpn'].toString())) : null);
        if (base64Config == null || base64Config.isEmpty) continue;
        result.add(VpnServerEntity(
          hostname: item['name']?.toString(),
          ip: item['ip']?.toString() ?? item['name']?.toString(),
          ping: item['ping']?.toString() ?? '0',
          speed: int.tryParse('${item['speed_bps'] ?? 0}') ?? 0,
          countryLong: item['country']?.toString(),
          countryShort: item['country_short']?.toString(),
          numVpnSessions: 0,
          openVPNConfigDataBase64: base64Config,
          username: item['username']?.toString(),
          password: item['password']?.toString(),
          isOwn: true,
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }
}
