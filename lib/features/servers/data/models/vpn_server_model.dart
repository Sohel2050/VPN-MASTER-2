import 'dart:convert';

import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// A data model for a VPN server.
/// This class is used for data transfer and can be converted to a [VpnServerEntity].
class VpnServerModel {
  /// The hostname of the VPN server.
  String? hostname;
  /// The IP address of the VPN server.
  String? ip;
  /// The ping time to the server in milliseconds.
  String? ping;
  /// The speed of the server in bits per second.
  int? speed;
  /// The full name of the country where the server is located.
  String? countryLong;
  /// The short code of the country (e.g., US, UK).
  String? countryShort;
  /// The number of current VPN sessions on the server.
  int? numVpnSessions;
  /// The Base64 encoded OpenVPN configuration data.
  String? openVPNConfigDataBase64;

  /// Creates a [VpnServerModel].
  VpnServerModel({
    this.hostname,
    this.ip,
    this.ping,
    this.speed,
    this.countryLong,
    this.countryShort,
    this.numVpnSessions,
    this.openVPNConfigDataBase64,
  });

  /// Create from raw JSON string
  factory VpnServerModel.fromRawJson(String str) => VpnServerModel.fromJson(json.decode(str));

  /// Convert to raw JSON string
  String toRawJson() => json.encode(toJson());

  /// Create from JSON Map
  factory VpnServerModel.fromJson(Map<String, dynamic> json) => VpnServerModel(
    hostname: json['HostName']?.toString(),
    ip: json['IP']?.toString(),
    ping: json['Ping']?.toString(),
    speed: json['Speed'] is int ? json['Speed'] : int.tryParse('${json['Speed']}'),
    countryLong: json['CountryLong']?.toString(),
    countryShort: json['CountryShort']?.toString(),
    numVpnSessions: json['NumVpnSessions'] is int
        ? json['NumVpnSessions']
        : int.tryParse('${json['NumVpnSessions']}'),
    openVPNConfigDataBase64: json['OpenVPN_ConfigData_Base64']?.toString(),
  );

  /// Convert to JSON Map
  Map<String, dynamic> toJson() => {
    'HostName': hostname,
    'IP': ip,
    'Ping': ping,
    'Speed': speed,
    'CountryLong': countryLong,
    'CountryShort': countryShort,
    'NumVpnSessions': numVpnSessions,
    'OpenVPN_ConfigData_Base64': openVPNConfigDataBase64,
  };

  /// Converts the model to a [VpnServerEntity].
  VpnServerEntity toEntity()=> VpnServerEntity(
    hostname: hostname,
    ip: ip,
    ping: ping,
    speed: speed,
    countryLong: countryLong,
    countryShort: countryShort,
    numVpnSessions: numVpnSessions,
    openVPNConfigDataBase64: openVPNConfigDataBase64
  );

}
