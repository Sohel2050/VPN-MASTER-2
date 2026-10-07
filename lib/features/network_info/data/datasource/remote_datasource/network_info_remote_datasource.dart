import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/constants/api_urls.dart';
import 'package:winsguard/core/error/failure.dart';
import 'package:winsguard/core/network/dio_client.dart';
import 'package:winsguard/features/network_info/data/models/network_info_model.dart';
import 'package:winsguard/features/network_info/domain/entities/network_info_entity.dart';

/// Abstract definition for the remote data source of the network information feature.
sealed class NetworkInfoRemoteDatasource {
  /// Fetches the user's current network information.
  Future<Either<Failure, NetworkInfoEntity>> getNetworkInfo();
}

/// Implementation of the [NetworkInfoRemoteDatasource].
class NetworkInfoRemoteDatasourceImpl implements NetworkInfoRemoteDatasource {

  @override
  Future<Either<Failure, NetworkInfoEntity>> getNetworkInfo() async {
    try{
      // Fetch network info from the remote API.
      Response response = await sl<DioClient>().get(ApiUrls.networkInfo);
      // Parse the JSON response into a model and convert it to an entity.
      NetworkInfoEntity networkInfoEntity = NetworkInfoModel.fromJson(response.data).toEntity();
      return Right(networkInfoEntity);
    }catch(error, stackTrace){
      // Log the error if the request fails.
      log(
          "Network Info Remote DataSource: ",
          error: error,
          stackTrace: stackTrace
      );
      // Return a failure with the error message.
      return Left(UnknownFailure(error.toString()));
    }
  }

}
