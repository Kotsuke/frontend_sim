import 'package:flutter_test/flutter_test.dart';

int updateRating(int current, bool isLike) {
  return isLike ? current + 1 : current - 1;
}

void main() {
  group('Rating Service Test', () {
    test('Like menambah rating', () {
      expect(updateRating(10, true), 11);
    });

    test('Dislike mengurangi rating', () {
      expect(updateRating(10, false), 9);
    });
  });
}
