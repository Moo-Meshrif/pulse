import 'package:pulse/core/error/failures.dart';

/// The [Failure] a call throws, or null when it succeeds.
Future<Failure?> failureOf(Future<Object?> call) async {
  try {
    await call;
  } on Failure catch (failure) {
    return failure;
  }
  return null;
}
