
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';
import 'package:winsguard/config/service_locator/service_locator.dart';
import 'package:winsguard/core/utils/enums/enums.dart';
import 'package:winsguard/features/speed_test/domain/usecases/get_ping_usecase.dart';
import 'package:winsguard/features/speed_test/presentation/bloc/speed_test_event.dart';

part 'speed_test_state.dart';

/// Handles the business logic for the internet speed test feature.
class SpeedTestBloc extends Bloc<SpeedTestEvent, SpeedTestState>{

  /// Initializes the BLoC and registers event handlers.
  SpeedTestBloc(): super(SpeedTestState.initial()){
    on<StartSpeedTest>(_onStartSpeedTest);
    on<DownloadSpeed>(_onDownloadSpeed);
    on<UploadSpeed>(_onUploadSpeed);
    on<GetPing>(_onGetPing);
  }


  /// Handles the [StartSpeedTest] event, initiating the entire speed test process.
  Future<void> _onStartSpeedTest(StartSpeedTest event, Emitter<SpeedTestState> emit) async {

      // Use a Completer to allow the BLoC event handler to await the async callbacks.
      final completer = Completer<void>();
      final speedTest = FlutterInternetSpeedTest();

      // Starts the speed test using the flutter_internet_speed_test_pro package.
      speedTest.startTesting(
        useFastApi: true,
        // Resets the state and sets the status to loading when the test starts.
        onStarted: () {
          emit(SpeedTestState.initial());
          emit(state.copyWith(status: Status.loading));
        },
        // Tracks the progress of both download and upload tests.
        onProgress: (percent, data) {
          if(percent > 0) emit(state.copyWith(status: Status.success));
          emit(state.copyWith(speed: data));
          // Differentiates between download and upload progress.
          if(state.downloadStatus == Status.success){
            add(UploadSpeed(speed: data));
          }else{
            add(DownloadSpeed(speed: data));
          }
        },
        // Marks the download test as complete.
        onDownloadComplete: (data) {
          emit(state.copyWith(downloadStatus: Status.success));
        },
        // Marks the upload test as complete.
        onUploadComplete: (data) {
          emit(state.copyWith(uploadStatus: Status.success));
        },
        // Fired when both tests are done. Updates the final speeds and triggers ping test.
        onCompleted: (download, upload) {
          emit(state.copyWith(
            downloadSpeed: download,
            uploadSpeed: upload,
          ));
          add(GetPing());
          completer.complete();
        },
        // Handles any errors during the test.
        onError: (errorMessage, speedTestError) {
          emit(state.copyWith(status: Status.error));
          completer.complete();
        },
        // Handles cancellation of the test.
        onCancel: () {
          emit(state.copyWith(status: Status.failure));
          completer.complete();
        },
      );

      // Ensures the BLoC event handler waits for the speed test to finish.
      await completer.future;
  }


  /// Tracks the live download speed.
  Future<void> _onDownloadSpeed(DownloadSpeed event, Emitter<SpeedTestState> emit) async {
    emit(state.copyWith(downloadSpeed: event.speed));
  }

  /// Tracks the live upload speed.
  Future<void> _onUploadSpeed(UploadSpeed event, Emitter<SpeedTestState> emit) async {
    emit(state.copyWith(uploadSpeed: event.speed));
  }


  /// Fetches the ping after the speed test is complete.
  Future<void> _onGetPing(GetPing event, Emitter<SpeedTestState> emit) async {
    emit(state.copyWith(status: Status.loading));
    // Calls the use case to get the ping.
    var result = await sl<GetPingUseCase>().call();
    // Handles success and error cases from the use case.
    result.fold(
        (error)=> emit(state.copyWith(status: Status.error, message: error.message)),
        (data)=> emit(state.copyWith(status: Status.success, ping: data))
    );
  }


}
