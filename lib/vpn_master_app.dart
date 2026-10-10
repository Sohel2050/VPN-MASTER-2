import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'package:vpn_master/config/routes/app_routes.dart';
import 'package:vpn_master/core/theme/app_theme.dart';
import 'package:vpn_master/core/theme/theme_cubit.dart';

import 'config/bloc/app_bloc_providers.dart';


/// The root widget of the VPN Master application.
class VpnMasterApp extends StatelessWidget {
  /// Creates a [VpnMasterApp].
  const VpnMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initializes screen utilities to make the UI responsive across different screen sizes.
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      // A wrapper to enable toast notifications throughout the app.
      child: ToastificationWrapper(
        // Provides all BLoCs and Cubits to the entire widget tree.
        child: MultiBlocProvider(
          providers: AppBlocProviders.providers,
          // Rebuilds the app with the correct theme when the theme mode changes.
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              // The main app widget that sets up routing, themes, and other configurations.
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                routerConfig: AppRouter.routes,
              );
            },
          ),
        ),
      ),
    );
  }
}
