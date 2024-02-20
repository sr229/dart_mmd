library dart_mmd;

import 'dart:typed_data';

import 'package:dart_mmd/pmx.dart';

/// Parses a Polygon Model eXtended file from a buffer.
/// 
/// The [buffer] parameter is the buffer to parse.
/// The [callback] parameter is the callback function to call when the parsing is complete.
/// It takes an [Error] object as the first parameter (or `null` if no error occurred) and the parsed model data as the second parameter.
class PMXParser {
  static PMX parse(
      ByteBuffer buffer, Function(Error err, dynamic data) callback) {
    var model = PMX(buffer, callback);

    callback(Error(), model.value);

    return model;
  }
}
