library dart_mmd;

import 'dart:typed_data';

import 'package:dart_mmd/pmx.dart';

class PMXParser {
  static PMX parse(
      ByteBuffer buffer, Function(Error err, dynamic data) callback) {
    var model = new PMX(buffer, callback);

    if (callback != null) {
      callback(Error(), model.value);
    }
    return model;
  }
}
