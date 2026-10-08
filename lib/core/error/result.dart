import '../utils/either.dart';
import 'failures.dart';

typedef Result<T> = Either<Failure, T>;
