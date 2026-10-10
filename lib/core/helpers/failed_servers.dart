import 'package:hive/hive.dart';
import 'package:vpn_master/core/constants/local_database_keys.dart';

/// Remembers servers that failed to connect, so they are hidden from the list.
/// Free servers come and go, so a failed server is forgotten after 24 hours.
class FailedServers {
  const FailedServers._();

  static const String _key = "failedServers";
  static const Duration _ttl = Duration(hours: 24);

  static Map<String, int> _read() {
    try {
      final raw = Hive.box(LocalDatabaseKeys.database).get(_key);
      if (raw == null) return {};
      final map = Map<String, int>.from(raw as Map);
      final limit = DateTime.now().subtract(_ttl).millisecondsSinceEpoch;
      map.removeWhere((_, time) => time < limit);
      return map;
    } catch (_) {
      return {};
    }
  }

  /// True when [ip] failed recently.
  static bool isFailed(String? ip) {
    if (ip == null || ip.isEmpty) return false;
    return _read().containsKey(ip);
  }

  /// Marks [ip] as failed.
  static void add(String? ip) {
    if (ip == null || ip.isEmpty) return;
    try {
      final map = _read();
      map[ip] = DateTime.now().millisecondsSinceEpoch;
      Hive.box(LocalDatabaseKeys.database).put(_key, map);
    } catch (_) {}
  }
}
