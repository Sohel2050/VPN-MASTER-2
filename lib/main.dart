import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/services/vpn/vpn_service.dart';
import 'package:winsguard/winsguard_app.dart';

import 'core/constants/local_database_keys.dart';
import 'core/services/monetization/monetization_service.dart' show MonetizationService;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keeps the native splash screen visible until the app is fully initialized.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Sets up the service locator for dependency injection.
  initServiceLocator();

  // Initializes core application services like monetization and VPN.
  await MonetizationService.initialize();
  await VpnService.instance.initialize();

  // Initializes Hive for local data storage.
  await Hive.initFlutter();
  // Create Local database.
  await Hive.openBox(LocalDatabaseKeys.database);

  // Runs the root widget of the application.
  runApp(const WinsguardApp());
}
