import 'dart:io';

import 'package:dart_mmd_parser/format/pmx.dart';
import 'package:test/test.dart';

void main() {
  test('parse pmx', () {
    var fileBuffer = File("./dataset/test.pmx").readAsBytesSync().buffer;
    var model = PMX(fileBuffer, (e, d) {
      try {
        expect(e, isNull);
        expect(d, isNotNull);
        expect(d is PMX, isTrue);
      } catch (e) {
        rethrow;
      }
    });
    expect(model, isNotNull);
  });
}
