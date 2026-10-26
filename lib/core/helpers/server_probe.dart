import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:vpn_master/core/constants/local_database_keys.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Checks if a VPN server is really alive BEFORE the user taps connect.
///
/// - UDP and TCP servers: an OpenVPN "hard reset" packet is sent and the server must
///   answer like an OpenVPN server (VPN Gate configs do not use tls-auth, so a live
///   server always replies).
///
/// This proves the server port is alive. A server can still fail later (for example a
/// cipher problem), so servers that fail to connect are also hidden afterwards.
class ServerProbe {
  const ServerProbe._();

  /// A server that answered is trusted for 10 minutes (memory only).
  static const Duration _ttl = Duration(minutes: 10);
  static final Map<String, _Result> _cache = {};

  /// A server that did NOT answer is hidden for 24 hours (saved on the phone, so it
  /// also survives closing the app).
  static const Duration _deadTtl = Duration(hours: 24);
  static const String _deadKey = "deadServers";
  static Map<String, int>? _dead;

  static Map<String, int> _deadMap() {
    final cached = _dead;
    if (cached != null) return cached;
    var map = <String, int>{};
    try {
      final raw = Hive.box(LocalDatabaseKeys.database).get(_deadKey);
      if (raw != null) {
        map = Map<String, int>.from(raw as Map);
        final limit = DateTime.now().subtract(_deadTtl).millisecondsSinceEpoch;
        map.removeWhere((_, time) => time < limit);
      }
    } catch (_) {}
    return _dead = map;
  }

  static void _saveDead() {
    try {
      Hive.box(LocalDatabaseKeys.database).put(_deadKey, _deadMap());
    } catch (_) {}
  }

  /// true = alive, false = dead, null = not tested yet (or the result is too old).
  static bool? knownResult(String? ip) {
    if (ip == null) return null;
    final deadAt = _deadMap()[ip];
    if (deadAt != null) {
      final age = DateTime.now().millisecondsSinceEpoch - deadAt;
      if (age <= _deadTtl.inMilliseconds) return false;
      _deadMap().remove(ip);
    }
    final r = _cache[ip];
    if (r == null) return null;
    if (DateTime.now().difference(r.time) > _ttl) {
      _cache.remove(ip);
      return null;
    }
    return r.alive;
  }

  /// Forgets every test result (used by the manual Refresh button), so all servers
  /// are tested again from zero.
  static void reset() {
    _cache.clear();
    _deadMap().clear();
    _saveDead();
  }

  /// Quick test of ONE server right before connecting. Returns true when it answers.
  static Future<bool> verify(VpnServerEntity server) async {
    final ip = server.ip;
    final alive = await _probe(server);
    if (ip != null) {
      if (alive) {
        _deadMap().remove(ip);
        _cache[ip] = _Result(true, DateTime.now());
      } else {
        _cache.remove(ip);
        _deadMap()[ip] = DateTime.now().millisecondsSinceEpoch;
      }
      _saveDead();
    }
    return alive;
  }

  /// Servers that were not tested yet, best servers first.
  static List<VpnServerEntity> pending(List<VpnServerEntity> servers) =>
      servers.where((s) => knownResult(s.ip) == null).toList();

  /// Tests [batch] at the same time and remembers the results.
  static Future<void> probeBatch(List<VpnServerEntity> batch) async {
    final results = <String, bool>{};
    await Future.wait(batch.map((s) async {
      final ip = s.ip;
      if (ip == null) return;
      results[ip] = await _probe(s);
    }));
    // If not even one server of a big group answered, the phone is most likely offline
    // or blocks the test. Do not mark good servers as dead for 24 hours because of that.
    if (batch.length >= 5 && !results.values.any((alive) => alive)) return;
    final now = DateTime.now();
    var deadChanged = false;
    results.forEach((ip, alive) {
      if (alive) {
        _cache[ip] = _Result(true, now);
      } else {
        _deadMap()[ip] = now.millisecondsSinceEpoch;
        deadChanged = true;
      }
    });
    if (deadChanged) _saveDead();
  }

  static ({String host, int port, bool tcp})? _target(VpnServerEntity server) {
    final config = server.openVPNConfig;
    if (config == null) return null;
    String? host;
    int? port;
    var tcp = false;
    for (final raw in config.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.startsWith('proto ')) {
        tcp = line.contains('tcp');
      } else if (line.startsWith('remote ') && host == null) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          host = parts[1];
          port = int.tryParse(parts[2]);
        }
      }
    }
    if (host == null || port == null) return null;
    return (host: host, port: port, tcp: tcp);
  }

  static Future<bool> _probe(VpnServerEntity server) async {
    final target = _target(server);
    if (target == null) return false;
    return target.tcp
        ? _probeTcp(target.host, target.port)
        : _probeUdp(target.host, target.port);
  }

  /// OpenVPN "hard reset" packet: opcode, random session id, no acks, packet id 0.
  static Uint8List _hardReset() {
    final random = Random.secure();
    final packet = Uint8List(14);
    packet[0] = 0x38; // P_CONTROL_HARD_RESET_CLIENT_V2
    for (var i = 1; i <= 8; i++) {
      packet[i] = random.nextInt(256);
    }
    return packet;
  }

  /// A real OpenVPN server answers a hard reset with P_CONTROL_HARD_RESET_SERVER_V2 (8)
  /// (or _V1 = 2). Any other answer means it is not an OpenVPN server.
  static bool _isOpenVpnReply(int firstByte) {
    final opcode = firstByte >> 3;
    return opcode == 8 || opcode == 2;
  }

  /// TCP: the port must open AND the server must answer like OpenVPN (an open port
  /// alone proves nothing: it can be a web server or a blocked / hijacked port).
  static Future<bool> _probeTcp(String host, int port) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: const Duration(seconds: 3));
      final packet = _hardReset();
      // OpenVPN over TCP: every packet starts with a 2 byte length.
      final framed = Uint8List(packet.length + 2);
      framed[0] = (packet.length >> 8) & 0xff;
      framed[1] = packet.length & 0xff;
      framed.setRange(2, framed.length, packet);
      socket.add(framed);
      await socket.flush();
      final reply = await socket.first.timeout(const Duration(seconds: 4));
      return reply.length >= 3 && _isOpenVpnReply(reply[2]);
    } catch (_) {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  static Future<bool> _probeUdp(String host, int port) async {
    RawDatagramSocket? socket;
    Timer? resend;
    StreamSubscription<RawSocketEvent>? sub;
    try {
      final address = (await InternetAddress.lookup(host, type: InternetAddressType.IPv4)).first;
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final answered = Completer<bool>();
      sub = socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket?.receive();
          if (datagram != null && datagram.data.isNotEmpty && !answered.isCompleted) {
            answered.complete(_isOpenVpnReply(datagram.data[0]));
          }
        }
      });

      // OpenVPN P_CONTROL_HARD_RESET_CLIENT_V2: opcode, session id, no acks, packet id 0.
      final packet = _hardReset();
      socket.send(packet, address, port);
      // One more try after 1.5 seconds in case the first packet was lost.
      resend = Timer(const Duration(milliseconds: 1500), () => socket?.send(packet, address, port));

      return await answered.future.timeout(const Duration(seconds: 4), onTimeout: () => false);
    } catch (_) {
      return false;
    } finally {
      resend?.cancel();
      await sub?.cancel();
      socket?.close();
    }
  }
}

class _Result {
  final bool alive;
  final DateTime time;
  const _Result(this.alive, this.time);
}
