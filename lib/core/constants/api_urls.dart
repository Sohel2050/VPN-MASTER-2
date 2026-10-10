class ApiUrls {
  // Private constructor to prevent instantiation
  ApiUrls._();

  /// Development Base Url
  //static const String _baseURL = "http://13.232.166.226:3031";
  /// Staging Base Url
  //static const String _baseURL = "http://192.168.20.244:9090";
  /// Production Base Url
  static const String _baseURL = "https://dummyjson.com";


  /// Vpn Servers Endpoints
  //static const String servers = "https://www.vpngate.net/api/iphone";
  static const String servers = "http://www.vpngate.net/api/iphone";
  static const String serversSecure = "https://www.vpngate.net/api/iphone";

  /// Network Info Endpoints
  static const String networkInfo = "http://ip-api.com/json";

  /// Speed Test Endpoints
  static const String ping = "https://www.google.com/generate_204";


  // Public getter to access the base URL
  static String get baseURL => _baseURL;

  // Pass without access token
  static List<String> basicAuthUrls = [];

}