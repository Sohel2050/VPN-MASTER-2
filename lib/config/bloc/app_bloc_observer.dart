import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Observes BLoC and Cubit state changes and logs them for debugging.
class AppBlocObserver extends BlocObserver {

  // ANSI color codes for styling console output.
  static const String reset = '\x1B[0m';
  static const String green = '\x1B[32m';
  static const String blue = '\x1B[34m';
  static const String cyan = '\x1B[36m';
  static const String red = '\x1B[31m';
  static const String yellow = '\x1B[33m';

  /// Called when a BLoC is instantiated.
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('$green🟢 bloc Created: ${bloc.runtimeType}$reset', name: 'BLoC');
  }

  /// Called whenever a state change occurs.
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('$blue🔄 State Changed in ${bloc.runtimeType}: $change$reset', name: 'BLoC');
  }

  /// Called on a new transition in a BLoC.
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('$cyan🔀 Transition in ${bloc.runtimeType}: $transition$reset', name: 'BLoC');
  }

  /// Called whenever an error is thrown.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('$red❌ Error in ${bloc.runtimeType}: $error$reset',
        name: 'BLoC',
        error: error,
        stackTrace: stackTrace);
  }

  /// Called when a BLoC is closed.
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('$yellow🔴 bloc Closed: ${bloc.runtimeType}$reset', name: 'BLoC');
  }
}
