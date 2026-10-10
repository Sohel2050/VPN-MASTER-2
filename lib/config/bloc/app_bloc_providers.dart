
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn_master/core/theme/theme_cubit.dart';
import 'package:vpn_master/features/home/bloc/home_bloc.dart';
import 'package:vpn_master/features/network_info/presentation/bloc/network_info_bloc.dart';
import 'package:vpn_master/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';
import 'package:vpn_master/features/speed_test/presentation/bloc/speed_test_bloc.dart';

/// Provides a centralized list of all BLoC/Cubit providers for the app.
class AppBlocProviders {
  const AppBlocProviders._();

  /// The list of all [BlocProvider]s used in the application.
  static List<BlocProvider> get providers => [

    BlocProvider<ThemeCubit>(create: (context)=> ThemeCubit()..getThemeMode()),
    BlocProvider<OnboardingCubit>(create: (context)=> OnboardingCubit()..userAlreadyOnboarded()),
    BlocProvider<HomeBloc>(create: (context)=> HomeBloc()),
    BlocProvider<ServersBloc>(create: (context)=> ServersBloc()..add(GetConnectedServer())),
    BlocProvider<NetworkInfoBloc>(create: (context)=> NetworkInfoBloc()),
    BlocProvider<SpeedTestBloc>(create: (context)=> SpeedTestBloc())

  ];

}
