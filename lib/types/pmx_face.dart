library dart_mmd;

import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a PMX face.
/// 
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
class PMXFace {
  late final List<int> value;

  /// Constructs a PMXFace object.
  ///
  /// The [reader] parameter is used to read the values from the buffer.
  /// The [vertexSize] parameter determines the size of each vertex value.
  /// Throws an [Exception] if the [vertexSize] is invalid.
  PMXFace(BufferReader reader, int vertexSize) {
    switch (vertexSize) {
      case 1:
        value = reader.readByteArray(3);
        break;
      case 2:
        value = reader.readShortArray(3);
        break;
      case 4:
        value = reader.readIntArray(3);
        break;
      default:
        throw Exception('Invalid vertex size: $vertexSize');
    }
  }
}
