import 'package:equatable/equatable.dart';

/// An abstract class representing a failure in the application.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents a failure related to the local database.
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure([super.message = ' Local Database Failure']);
}

// Common failure types

/// Represents a failure that occurred on the server.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure']);
}

/// Represents a network-related failure, such as no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet Connection']);
}

/// Represents an unexpected or unknown failure.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown Failure']);
}

/// Represents a failure from an API call, typically including an HTTP status code.
class ApiFailure extends Failure {
  final int statusCode;

  const ApiFailure(this.statusCode, [String message = 'API Failure'])
      : super(message);

  @override
  List<Object> get props => [statusCode, message];
}
