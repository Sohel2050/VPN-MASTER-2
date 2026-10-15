/// Countries whose servers are hidden from the app (never shown, never selected).
///
/// To hide another country, add its 2-letter code (upper case) to [codes] and its
/// English name (lower case) to [names]. Check with your own legal adviser which
/// countries you must block.
class BlockedCountries {
  const BlockedCountries._();

  /// ISO 3166-1 alpha-2 codes (for example "RU").
  static const Set<String> codes = {'RU', 'AE'};

  /// English country names in lower case (VPN Gate writes "Russian Federation").
  static const Set<String> names = {
    'russian federation',
    'russia',
    'united arab emirates',
  };

  /// True when a server in this country must be hidden.
  static bool isBlocked({String? code, String? name}) {
    final c = (code ?? '').trim().toUpperCase();
    final n = (name ?? '').trim().toLowerCase();
    return codes.contains(c) || names.contains(n);
  }
}
