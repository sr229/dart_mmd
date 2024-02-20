import 'dart:io';
import 'package:dart_mmd/dart_mmd.dart';
import 'package:test/test.dart';

void main() {
  test('Test parsing file and reading metadata', () {
    var file = (File("./test/dataset/yyb_miku.pmx").readAsBytesSync()).buffer;
    PMXParser.parse(file, (err, data) => {
      expect(data, isNotNull)
    });
  });
}
