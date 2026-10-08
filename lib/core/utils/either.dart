import 'equatable.dart';

/// `Left` holds a failure, `Right` the value. Pure Dart: no package.
sealed class Either<L, R> extends Equatable {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  /// Runs [onLeft] for a failure, [onRight] for a value.
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) =>
      switch (this) {
        Left(:final value) => onLeft(value),
        Right(:final value) => onRight(value),
      };

  /// Transforms the value of a `Right`; a `Left` passes through unchanged.
  Either<L, T> map<T>(T Function(R right) transform) => switch (this) {
    Left(:final value) => Left(value),
    Right(:final value) => Right(transform(value)),
  };

  /// The value of a `Right`, or [orElse] of the failure for a `Left`.
  R getOrElse(R Function(L left) orElse) => switch (this) {
    Left(:final value) => orElse(value),
    Right(:final value) => value,
  };
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  List<Object?> get props => [value];
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  List<Object?> get props => [value];
}

/// "No value" for `Either<Failure, Unit>`: a save, delete or sign-out that returns nothing.
final class Unit extends Equatable {
  const Unit._();

  @override
  List<Object?> get props => const [];
}

const unit = Unit._();
