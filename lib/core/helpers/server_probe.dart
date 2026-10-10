import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Checks if a VPN server is really alive BEFORE the user taps connect.
///
/// - TCP servers: a TCP connection to the server's OpenVPN port must open.
/// - UDP servers: an OpenVPN "hard reset" packet is sent and the server must answer
///   (VPN Gate configs do not use tls-auth, so a live server always replies).
///
/// This proves the server port is alive. A server can still fail later (for example a
/// cipher problem), so servers that fail to connect are also hidden afterwards.
class ServerProbe {
  const ServerProbe._();

  static const Duration _ttl = Duration(minutes: 10);
  static final Map<String, _Result> _cache = {};

  /// true = alive, false = dead, null = not tested yet (or the result is too old).
  static bool? knownResult(String? ip) {
    if (ip == null) return null;
    final r = _cache[ip];
    if (r == null) return null;
    if (DateTime.now().difference(r.time) > _ttl) {
      _cache.remove(ip);
      return null;
    }
    return r.alive;
  }

  /// Servers that were not tested yet, best servers first.
  static List<VpnServerEntity> pending(List<VpnServerEntity> servers) =>
      servers.where((s) => knownResult(s.ip) == null).toList();

  /// Tests [batch] at the same time and remembers the results.
  static Future<void> probeBatch(List<VpnServerEntity> batch) async {
    await Future.wait(batch.map((s) async {
      final ip = s.ip;
      if (ip == null) return;
      final alive = await _probe(s);
      _cache[ip] = _Result(alive, DateTime.now());
    }));
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

  static Future<bool> _probeTcp(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
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
            answered.complete(true);
          }
        }
      });

      // OpenVPN P_CONTROL_HARD_RESET_CLIENT_V2: opcode, session id, no acks, packet id 0.
      final random = Random.secure();
      final packet = Uint8List(14);
      packet[0] = 0x38;
      for (var i = 1; i <= 8; i++) {
        packet[i] = random.nextInt(256);
      }
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
