import 'dart:convert';

import 'package:winsguard/features/network_info/domain/entities/network_info_entity.dart';

/// A data model for network information, used for parsing data from the API.
class NetworkInfoModel {
  /// The status of the network request (e.g., "success").
  final String? status;
  /// The country name associated with the IP address.
  final String? country;
  /// The country code (e.g., "US", "CA").
  final String? countryCode;
  /// The region or state code.
  final String? region;
  /// The full name of the region or state.
  final String? regionName;
  /// The city name.
  final String? city;
  /// The postal or zip code.
  final String? zip;
  /// The latitude coordinate.
  final double? lat;
  /// The longitude coordinate.
  final double? lon;
  /// The timezone of the location (e.g., "America/New_York").
  final String? timezone;
  /// The Internet Service Provider (ISP).
  final String? isp;
  /// The organization that owns the IP address.
  final String? org;
  /// The Autonomous System (AS) number and name.
  final String? networkInfoModelAs;
  /// The IP address that was queried.
  final String? query;

  /// Creates a [NetworkInfoModel].
  NetworkInfoModel({
    this.status,
    this.country,
    this.countryCode,
    this.region,
    this.regionName,
    this.city,
    this.zip,
    this.lat,
    this.lon,
    this.timezone,
    this.isp,
    this.org,
    this.networkInfoModelAs,
    this.query,
  });

  /// Creates a copy of the current model with updated values.
  NetworkInfoModel copyWith({
    String? status,
    String? country,
    String? countryCode,
    String? region,
    String? regionName,
    String? city,
    String? zip,
    double? lat,
    double? lon,
    String? timezone,
    String? isp,
    String? org,
    String? networkInfoModelAs,
    String? query,
  }) =>
      NetworkInfoModel(
        status: status ?? this.status,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        region: region ?? this.region,
        regionName: regionName ?? this.regionName,
        city: city ?? this.city,
        zip: zip ?? this.zip,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        timezone: timezone ?? this.timezone,
        isp: isp ?? this.isp,
        org: org ?? this.org,
        networkInfoModelAs: networkInfoModelAs ?? this.networkInfoModelAs,
        query: query ?? this.query,
      );

  /// Creates a [NetworkInfoModel] from a raw JSON string.
  factory NetworkInfoModel.fromRawJson(String str) => NetworkInfoModel.fromJson(json.decode(str));

  /// Converts the model to a raw JSON string.
  String toRawJson() => json.encode(toJson());

  /// Creates a [NetworkInfoModel] from a JSON map.
  factory NetworkInfoModel.fromJson(Map<String, dynamic> json) => NetworkInfoModel(
    status: json["status"],
    country: json["country"],
    countryCode: json["countryCode"],
    region: json["region"],
    regionName: json["regionName"],
    city: json["city"],
    zip: json["zip"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    timezone: json["timezone"],
    isp: json["isp"],
    org: json["org"],
    networkInfoModelAs: json["as"],
    query: json["query"],
  );

  /// Converts the model to a JSON map for serialization.
  Map<String, dynamic> toJson() => {
    "status": status,
    "country": country,
    "countryCode": countryCode,
    "region": region,
    "regionName": regionName,
    "city": city,
    "zip": zip,
    "lat": lat,
    "lon": lon,
    "timezone": timezone,
    "isp": isp,
    "org": org,
    "as": networkInfoModelAs,
    "query": query,
  };

  /// Converts the data model to a domain [NetworkInfoEntity].
  NetworkInfoEntity toEntity()=> NetworkInfoEntity(
    status: status,
    country: country,
    countryCode: countryCode,
    region: region,
    regionName: regionName,
    city: city,
    zip: zip,
    lat: lat,
    lon: lon,
    timezone: timezone,
    isp: isp,
    org: org,
    networkInfoModelAs: networkInfoModelAs,
    query: query
  );

}
