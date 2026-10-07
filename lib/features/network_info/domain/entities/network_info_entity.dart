/// Represents the data structure for network information.
class NetworkInfoEntity {
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

  /// Creates a [NetworkInfoEntity].
  NetworkInfoEntity({
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
    this.query
  });
}
