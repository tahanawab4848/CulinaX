import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/core/theme.dart';

void main() {
  test('App theme palette is defined', () {
    expect(C.g500, isNotNull);
    expect(C.dark2, isNotNull);
  });
}
