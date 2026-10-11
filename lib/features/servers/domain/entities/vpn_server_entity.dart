import 'dart:convert';

/// Represents the core data for a VPN server.
class VpnServerEntity {
  /// The hostname of the VPN server.
  final String? hostname;
  /// The IP address of the VPN server.
  final String? ip;
  /// The ping time to the server in milliseconds.
  final String? ping;
  /// The speed of the server in bits per second.
  final int? speed;
  /// The full name of the country where the server is located.
  final String? countryLong;
  /// The short code of the country (e.g., US, UK).
  final String? countryShort;
  /// The number of current VPN sessions on the server.
  final int? numVpnSessions;
  /// The Base64 encoded OpenVPN configuration data.
  final String? openVPNConfigDataBase64;
  /// Username for servers that need a login (your own VPS). Empty for public servers.
  final String? username;
  /// Password for servers that need a login (your own VPS).
  final String? password;
  /// True for your own private servers (shown in the "My Servers" tab).
  final bool isOwn;

  /// Creates a [VpnServerEntity].
  const VpnServerEntity({
    this.hostname,
    this.ip,
    this.ping,
    this.speed,
    this.countryLong,
    this.countryShort,
    this.numVpnSessions,
    this.openVPNConfigDataBase64,
    this.username,
    this.password,
    this.isOwn = false,
  });

  /// Converts the entity to a JSON map for serialization.
  Map<String, dynamic> toJson() => {
    'HostName': hostname,
    'IP': ip,
    'Ping': ping,
    'Speed': speed,
    'CountryLong': countryLong,
    'CountryShort': countryShort,
    'NumVpnSessions': numVpnSessions,
    'OpenVPN_ConfigData_Base64': openVPNConfigDataBase64,
    'Username': username,
    'Password': password,
    'IsOwn': isOwn,
  };

  /// Decodes the Base64 OpenVPN config and applies necessary compatibility fixes.
  String? get openVPNConfig {
    if (openVPNConfigDataBase64 == null || openVPNConfigDataBase64!.isEmpty) {
      return null;
    }
    try {
      final data = Base64Decoder().convert(openVPNConfigDataBase64!);
      String config = Utf8Decoder().convert(data);
      if (config.contains('cipher AES-128-CBC') && !config.contains('data-ciphers')) {
        config = config.replaceAll('cipher AES-128-CBC', '''cipher AES-128-CBC
        data-ciphers 'AES-128-CBC'
        data-ciphers-fallback 'AES-128-CBC\'''');
      }
      if (config.contains('cipher AES-256-CBC') && !config.contains('data-ciphers')) {
        config = config.replaceAll('cipher AES-256-CBC', '''cipher AES-256-CBC
        data-ciphers 'AES-256-CBC'
        data-ciphers-fallback 'AES-256-CBC\'''');
      }
      return config;
    } catch (_) {
      return null;
    }
  }

}
