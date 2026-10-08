import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/either.dart';

void main() {
  const Either<String, int> right = Right(2);
  const Either<String, int> left = Left('boom');

  test('fold runs the matching side', () {
    expect(right.fold((l) => 'L$l', (r) => 'R$r'), 'R2');
    expect(left.fold((l) => 'L$l', (r) => 'R$r'), 'Lboom');
  });

  test('map changes a Right and leaves a Left alone', () {
    expect(right.map((r) => r * 10), const Right<String, int>(20));
    expect(left.map((r) => r * 10), const Left<String, int>('boom'));
  });

  test('getOrElse gives the value or the fallback', () {
    expect(right.getOrElse((_) => -1), 2);
    expect(left.getOrElse((l) => l.length), 4);
  });

  test('isLeft / isRight', () {
    expect(right.isRight, isTrue);
    expect(left.isLeft, isTrue);
  });

  test('value equality; Left and Right of the same value differ', () {
    expect(const Right<String, int>(1), const Right<String, int>(1));
    expect(const Left<int, int>(1), isNot(const Right<int, int>(1)));
  });

  test('unit is a single value', () {
    expect(unit, same(unit));
  });
}
