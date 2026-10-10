import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vpn_master/config/service_locator/service_locator.dart';
import 'package:vpn_master/core/constants/api_urls.dart';
import 'package:vpn_master/core/error/failure.dart';
import 'package:vpn_master/core/network/dio_client.dart';

/// Abstract definition for the remote data source of the speed test.
sealed class SpeedTestRemoteDatasource {
  /// Fetches the ping time from the server.
  Future<Either<Failure, int>> getPing();
}

/// Implementation of the [SpeedTestRemoteDatasource].
class SpeedTestRemoteDatasourceImpl implements SpeedTestRemoteDatasource{

  @override
  Future<Either<Failure, int>> getPing() async {
    try{

      // Start a stopwatch to measure the duration of the request.
      final stopwatch = Stopwatch()..start();
      // Make a HEAD request to the server to measure latency.
      await sl<DioClient>().head(
        ApiUrls.ping,
        options: Options(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
          followRedirects: false,
        )
      );
      stopwatch.stop();
      // Return the elapsed time in milliseconds as the ping.
      return Right(stopwatch.elapsedMilliseconds);

    }catch(error, stackTrace){

      // Log any errors that occur during the ping test.
      log(
          "Speed Test Remote DataSource: ",
          error: error,
          stackTrace: stackTrace
      );
      // Return a failure if an error occurs.
      return Left(UnknownFailure(error.toString()));

    }
  }

}
