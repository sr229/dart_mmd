library dart_mmd;

import '../../utils/buffer_reader.dart';

/// Represents a Polygon Model eXtended face.
/// 
/// Source: https://gist.github.com/felixjones/f8a06bd48f9da9a4539f
class PMXFace {
  List<int> value = [];

  /// Constructs a PMXFace object.
  ///
  /// The [reader] parameter is used to read the values from the buffer.
  /// The [vertexSize] parameter determines the size of each vertex value.
  /// Throws an [Exception] if the [vertexSize] is invalid.
  PMXFace(BufferReader reader, int vertexSize) {
    // n: Vertex Index Size | Reference Index of Vertex
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
