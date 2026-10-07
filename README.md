## Winsguard VPN Flutter App

This Flutter Android application provides secure VPN access using **OpenVPN** protocol and public VPN servers from **VPNGate**. It is designed for Android devices, with dynamic server selection, user-friendly controls, and privacy-focused features.

---

### VPN Protocol
- **Protocol:** OpenVPN
- Provides strong encryption and secure tunneling between your device and VPN servers.

### VPN Service Provider
- **Provider:** [VPNGate](https://www.vpngate.net/en/)
- Free public VPN servers maintained by the University of Tsukuba.
- Servers are volunteer-operated; performance, speed, and stability may vary.

---

### VPN Connection Flow

1. User opens the app.
2. App fetches a list of servers dynamically from the VPNGate CSV API.
3. Servers are parsed and filtered for OpenVPN compatibility.
4. **Auto-selection:**
    - The app selects the top server based on **composite score** (speed + load) and lowest ping.
5. **User consent & permission:**
    - Android shows a system VPN dialog requesting permission to create a VPN connection.
    - The app displays a pre-connection explanation screen for transparency.
6. VPN tunnel is established using the decoded `.ovpn` configuration from the server.
7. User can **manually select a server** from the list if desired.
8. Disconnect terminates the VPN session immediately.

---

### Security & Privacy Features

- **Encryption:**
    - AES-128-CBC or AES-256-CBC (depends on server)
    - TLSv1.2+ for secure session setup
    - SHA1 or SHA256 for authentication (server-dependent)
- **End-to-end encryption:** All traffic between device and server is encrypted; the app does **not log user activity**.
- **Kill-switch / DNS leak protection:**
    - Ensures that all device traffic goes through the VPN tunnel (if enabled).
    - Prevents accidental exposure if the VPN disconnects unexpectedly.
- **Privacy:**
    - No user traffic logs kept by the app.
    - Connection to volunteer servers is at user discretion; the app is not responsible for server logs.
    - Ad networks (AdMob, Meta, Unity, AppLovin) may collect anonymized usage data only.

---

### Key Classes & Files

| Feature | File / Class |
|---------|-------------|
| VPN connection logic | `lib/core/services/vpn/vpn_service.dart` |
| Server CSV fetch & parsing | `lib/features/server/` |
| Home screen & server selection UI | `lib/ui/screens/home/` |
| State management (BLoC) | `lib/features/home/bloc/home_bloc.dart` |

---

### Notes

- All servers are **dynamic** via VPNGate — no static configurations or user-added servers.
- Auto-selection considers **speed, load, and ping** to provide the best experience.
- Users **must accept the Android VPN permission dialog** before any VPN connection occurs.

---

### References

- [VPNGate Public API](http://www.vpngate.net/api/iphone/)
- [OpenVPN Protocol](https://openvpn.net/)
- [Google Play VPN Policy](https://support.google.com/googleplay/android-developer/answer/12564964)

---
# VPN-MASTER-2
