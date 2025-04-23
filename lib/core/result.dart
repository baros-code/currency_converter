import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Result<TValue extends Object, TError extends Failure> extends Equatable {
  /// Prefer [Result.success] or [Result.failure] instead of this constructor.

  /// Indicates if the result is successful or not.
  final bool isSuccessful;

  /// Value object to be used when [isSuccessful] is true.
  final TValue? value;

  /// Error object to be used when [isSuccessful] is false.
  final TError? error;

  @protected
  const Result.internal({
    this.value,
    this.error,
  })  : assert(
          TValue == Object || value != null || error != null,
          'Either value or error should be provided or value to be omitted!',
        ),
        assert(
          value == null || error == null,
          'Both value and error cannot be provided!',
        ),
        isSuccessful = (TValue == Object && error == null) || value != null;

  factory Result.success({TValue? value}) => Result.internal(value: value);

  factory Result.failure(TError? error) => Result.internal(error: error);

  @override
  List<Object?> get props => [isSuccessful, value, error];
}

class Failure extends Equatable {
  const Failure({required this.message});

  /// Message to describe the failure.
  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}
