import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  const Failure({required this.message});

  /// Message to describe the failure.
  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}
