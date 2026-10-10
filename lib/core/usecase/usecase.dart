import 'package:dartz/dartz.dart';
import 'package:vpn_master/core/error/failure.dart';

/// An abstract class representing a use case, which enforces a standard
/// contract for executing a piece of business logic.
///
/// [Types] represents the success output of the use case.
/// [Params] represents the input parameters required to execute it.
abstract class UseCase<Types, Params> {
  /// Executes the use case with the given parameters.
  ///
  /// Returns a [Future] that completes with an [Either], holding either a
  /// [Failure] on the left or the successful [Types] data on the right.
  Future<Either<Failure, Types>> call({Params params});
}
