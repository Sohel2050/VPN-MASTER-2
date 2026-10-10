
import 'package:get_it/get_it.dart';
import 'package:vpn_master/core/network/dio_client.dart';
import 'package:vpn_master/features/network_info/data/datasource/remote_datasource/network_info_remote_datasource.dart';
import 'package:vpn_master/features/network_info/data/repositories/network_info_repositories_impl.dart';
import 'package:vpn_master/features/network_info/domain/repositories/network_info_repositories.dart';
import 'package:vpn_master/features/network_info/domain/usecases/get_network_info_usecase.dart';
import 'package:vpn_master/features/onboarding/data/datasource/local_datasource/onboarding_local_datasource.dart';
import 'package:vpn_master/features/onboarding/data/repositories/onboarding_repositories_impl.dart';
import 'package:vpn_master/features/onboarding/domain/repositories/onboarding_repositories.dart';
import 'package:vpn_master/features/onboarding/domain/usecases/already_onboarded_usecase.dart';
import 'package:vpn_master/features/onboarding/domain/usecases/user_onboarded_usecase.dart';
import 'package:vpn_master/features/servers/data/datasource/local_datasource/servers_local_datasource.dart';
import 'package:vpn_master/features/servers/data/datasource/remote_datasource/servers_remote_datasource.dart';
import 'package:vpn_master/features/servers/data/repositories/servers_repositories_impl.dart';
import 'package:vpn_master/features/servers/domain/repositories/servers_repositories.dart';
import 'package:vpn_master/features/servers/domain/usecases/get_connected_server_usecase.dart';
import 'package:vpn_master/features/servers/domain/usecases/get_vpn_servers_usecase.dart';
import 'package:vpn_master/features/servers/domain/usecases/save_connected_server_usecase.dart';
import 'package:vpn_master/features/speed_test/data/datasource/remote_datasource/speed_test_remote_datasource.dart';
import 'package:vpn_master/features/speed_test/data/repositories/speed_test_repositories_impl.dart';
import 'package:vpn_master/features/speed_test/domain/repositoires/speed_test_repositories.dart';
import 'package:vpn_master/features/speed_test/domain/usecases/get_ping_usecase.dart';

final sl = GetIt.instance;

void initServiceLocator(){

  sl.registerSingleton<DioClient>(DioClient());

  /// Remote DataSource
  sl.registerLazySingleton<NetworkInfoRemoteDatasource>(()=> NetworkInfoRemoteDatasourceImpl());
  sl.registerLazySingleton<ServersRemoteDatasource>(()=> ServersRemoteDatasourceImpl());
  sl.registerLazySingleton<SpeedTestRemoteDatasource>(()=> SpeedTestRemoteDatasourceImpl());


  /// Local DataSource
  sl.registerSingleton<OnboardingLocalDatasource>(OnboardingLocalDatasourceImpl());
  sl.registerSingleton<ServersLocalDatasource>(ServersLocalDatasourceImpl());


  /// Repositories
  sl.registerLazySingleton<OnboardingRepositories>(()=> OnboardingRepositoriesImpl());
  sl.registerLazySingleton<NetworkInfoRepositories>(()=> NetworkInfoRepositoriesImpl());
  sl.registerLazySingleton<ServersRepositories>(()=> ServersRepositoriesImpl());
  sl.registerLazySingleton<SpeedTestRepositories>(()=> SpeedTestRepositoriesImpl());


  /// UseCase
  /// Onboarding UseCases
  sl.registerLazySingleton<AlreadyOnboardedUseCase>(()=> AlreadyOnboardedUseCase());
  sl.registerLazySingleton<UserOnboardedUseCase>(()=> UserOnboardedUseCase());

  /// Servers UseCases
  sl.registerLazySingleton<GetVpnServersUseCase>(()=> GetVpnServersUseCase());
  sl.registerLazySingleton<GetConnectedServerUseCase>(()=> GetConnectedServerUseCase());
  sl.registerLazySingleton<SaveConnectedServerUseCase>(()=> SaveConnectedServerUseCase());


  /// Network Info UseCases
  sl.registerLazySingleton<GetNetworkInfoUseCase>(()=> GetNetworkInfoUseCase());

  /// Speed Test UseCases
  sl.registerLazySingleton<GetPingUseCase>(()=> GetPingUseCase());

}