import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/constants/api_urls.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/core/helpers/helpers.dart';
import 'package:winsguard/core/network/dio_client.dart';
import 'package:winsguard/features/servers/domain/entities/vpn_server_entity.dart';

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
      // Fetch server data as a plain text (CSV).
      Response response = await sl<DioClient>().get(
        ApiUrls.servers,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            "User-Agent": "Mozilla/5.0", // For bypass ISP blocking.
            "Accept": "text/plain"
          }
        )
      );

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
      return Left(UnknownFailure(error.toString()));
    }
  }

}
