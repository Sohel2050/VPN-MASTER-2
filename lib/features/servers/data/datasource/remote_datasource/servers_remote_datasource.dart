import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/constants/api_urls.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/network/dio_client.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Abstract definition for the remote data source of the servers.
sealed class ServersRemoteDatasource {
  /// Fetches the list of available VPN servers from the remote source.
  Future<Either<Failure, List<VpnServerEntity>>> getVpnServers();
}

/// Implementation of the [ServersRemoteDatasource].
class ServersRemoteDatasourceImpl implements ServersRemoteDatasource{

  @override
  Future<Either<Failure, List<VpnServerEntity>>> getVpnServers() async {
    try{
      // Fetch server data as plain text (CSV). If one address is blocked or fails,
      // the other one is tried before giving up.
      Response? response;
      Object? lastError;
      for (final url in [ApiUrls.serversSecure, ApiUrls.servers]) {
        try {
          response = await sl<DioClient>().get(
            url,
            options: Options(
              responseType: ResponseType.plain,
              headers: {
                "User-Agent": "Mozilla/5.0", // For bypass ISP blocking.
                "Accept": "text/plain"
              }
            )
          );
          if ((response.data as String).contains("HostName")) break;
          response = null;
        } catch (e) {
          lastError = e;
          response = null;
        }
      }
      if (response == null) {
        throw lastError ?? const UnknownFailure("The VPN server list was empty. Please try again later.");
      }

      // Parse the CSV data into a list of VpnServerModel.
      final vpnServerModels = Helpers.csvToVpnServerModels(response.data as String);

      // Convert the data models to domain entities.
      final vpnServerEntities = vpnServerModels.map((vpnServerModel) => vpnServerModel.toEntity()).toList();

      // Return the list of entities on success.
      return Right(vpnServerEntities);
    }catch(error, stackTrace){
      // Log any errors that occur during the process.
      log(
          "Servers Remote DataSource: ",
          error: error,
          stackTrace: stackTrace
      );
      // Return a failure if an error occurs.
      if (error is Failure) return Left(error);
      return Left(UnknownFailure("Could not load servers: ${error.toString()}"));
    }
  }

}
