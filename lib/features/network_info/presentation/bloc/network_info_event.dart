import 'package:equatable/equatable.dart';

/// The base class for all events related to the network information feature.
sealed class NetworkInfoEvent extends Equatable{}

/// Dispatched to fetch the user's current network information.
class GetNetworkInfo extends NetworkInfoEvent{
  @override
  List<Object?> get props => [];
}
