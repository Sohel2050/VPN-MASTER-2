import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vpn_master/core/constants/api_urls.dart';
import 'package:vpn_master/core/helpers/blocked_countries.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Loads your own (private) VPS servers.
///
/// 1. Online file (ApiUrls.ownServers) is the source of truth. If it loads and is
///    valid JSON (even { "servers": [] }), that list is final.
/// 2. Only if GitHub cannot be reached (no internet, 404, error), the bundled
///    assets/config/own_servers.json is used as an emergency fallback.
///
/// File format:
/// { "servers": [ { "name": "Singapore 1", "country": "Singapore", "country_short": "SG",
///   "ip": "203.0.113.10", "username": "", "password": "", "ovpn_base64": "..." } ] }
/// Use "ovpn" (the plain text of the .ovpn file) instead of "ovpn_base64" if you prefer.
///
/// WireGuard server: add "protocol": "wireguard" and the client config (wg-quick text)
/// as "wg_config" (plain text) or "wg_base64" (Base64). "ovpn" is not needed then.
class OwnServersSource {
  const OwnServersSource._();

  /// Returns the list of private servers (empty when none are configured).
  static Future<List<VpnServerEntity>> load() async {
    // 1. Online file is the source of truth. If it was fetched successfully and
    //    is valid JSON (even { "servers": [] }), that list is final.
    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        responseType: ResponseType.plain,
      )).get(ApiUrls.ownServers);
      final online = _parse(response.data?.toString());
      if (online != null) return online;
    } catch (_) {
      // No internet / 404 / server error -> fall back to the bundled file.
    }

    // 2. Emergency fallback: bundled file (only when GitHub could not be reached).
    try {
      return _parse(await rootBundle.loadString('assets/config/own_servers.json')) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Returns null when [raw] is not valid (so the caller can fall back),
  /// or a list (possibly empty) when it is valid.
  static List<VpnServerEntity>? _parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final data = json.decode(raw);
      final dynamic rawList = data is Map ? data['servers'] : data;
      if (rawList is! List) return null;
      final list = rawList;
      final result = <VpnServerEntity>[];
      for (final item in list) {
        if (item is! Map) continue;
        // Servers in blocked countries (see BlockedCountries) are never shown.
        if (BlockedCountries.isBlocked(
            code: item['country_short']?.toString(), name: item['country']?.toString())) {
          continue;
        }
        final protocol = VpnProtocol.parse(item['protocol']?.toString());
        final isWireGuard = protocol == VpnProtocol.wireguard;
        final base64Config = item['ovpn_base64']?.toString() ??
            (item['ovpn'] != null ? base64Encode(utf8.encode(item['ovpn'].toString())) : null);
        final wgBase64 = item['wg_base64']?.toString() ??
            (item['wg_config'] != null ? base64Encode(utf8.encode(item['wg_config'].toString())) : null);
        // A server needs the config that matches its protocol.
        if (isWireGuard) {
          if (wgBase64 == null || wgBase64.isEmpty) continue;
        } else {
          if (base64Config == null || base64Config.isEmpty) continue;
        }
        result.add(VpnServerEntity(
          hostname: item['name']?.toString(),
          ip: item['ip']?.toString() ?? item['name']?.toString(),
          ping: item['ping']?.toString() ?? '0',
          speed: int.tryParse('${item['speed_bps'] ?? 0}') ?? 0,
          countryLong: item['country']?.toString(),
          countryShort: item['country_short']?.toString(),
          numVpnSessions: 0,
          openVPNConfigDataBase64: isWireGuard ? null : base64Config,
          wireguardConfigBase64: isWireGuard ? wgBase64 : null,
          protocol: protocol,
          username: item['username']?.toString(),
          password: item['password']?.toString(),
          isOwn: true,
        ));
      }
      return result;
    } catch (_) {
      return null;
    }
  }
}
