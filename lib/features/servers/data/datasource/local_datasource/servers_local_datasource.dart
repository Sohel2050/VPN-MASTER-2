import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:vpn_master/core/constants/local_database_keys.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/features/servers/data/models/vpn_server_model.dart';
import 'package:vpn_master/features/servers/domain/entities/vpn_server_entity.dart';

/// Abstract definition for the local data source of the servers.
sealed class ServersLocalDatasource {
  /// Fetches the currently connected server from local storage.
  Future<Either<Failure, VpnServerEntity?>> getConnectedServer();
  /// Saves the currently connected server to local storage.
  Future<Either<Failure, bool>> saveConnectedServer({required VpnServerEntity connectedServer});
}

/// Implementation of the [ServersLocalDatasource].
class ServersLocalDatasourceImpl implements ServersLocalDatasource{

  @override
  Future<Either<Failure, VpnServerEntity?>> getConnectedServer() async {
    try{
      // Open the Hive box for the local database.
      final box = Hive.box(LocalDatabaseKeys.database);
      // Get the raw server data from the box.
      final rawData = box.get(LocalDatabaseKeys.connectedServer);
      if(rawData == null) return const Right(null);
      // Cast the raw data to the expected Map type.
      final Map<String, dynamic> data = Map<String,dynamic>.from(rawData);
      // Convert the JSON map to a VpnServerEntity.
      VpnServerEntity connectedServer = VpnServerModel.fromJson(data).toEntity();
      // Return the server entity on success.
      return Right(connectedServer);

    }catch(error, stackTrace){
      // Log any errors that occur.
      log(
          "Servers Local DataSource: ",
          error: error,
          stackTrace: stackTrace
      );
      // Return a failure if an error occurs.
      return Left(UnknownFailure(error.toString()));
    }

  }

  @override
  Future<Either<Failure, bool>> saveConnectedServer({required VpnServerEntity connectedServer}) async {
    try{
      // Open the Hive box for the local database.
      final box = Hive.box(LocalDatabaseKeys.database);
      // Save the server's JSON representation to the box.
      box.put(LocalDatabaseKeys.connectedServer, connectedServer.toJson());
      // Return true on success.
      return const Right(true);

    }catch(error, stackTrace){
      // Log any errors that occur.
      log(
          "Servers Local DataSource: ",
          error: error,
          stackTrace: stackTrace
      );
      // Return a failure if an error occurs.
      return Left(UnknownFailure(error.toString()));

    }
  }

}
