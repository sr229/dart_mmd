library dart_mmd;

import 'dart:typed_data';

/// BufferReader is a specialised class for reading from a PMX/VMD buffer.
/// This is originally ported from a TypeScript version of the library.
///
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts
class BufferReader {
  List<int> posStack = [0];
  late ByteBuffer binaryData;

  /// Create a new BufferReader from a ByteBuffer.
  /// [buffer] is the buffer to read from.
  /// [pos] is the initial position to start reading from.
  BufferReader(ByteBuffer buffer, [int pos = 0]) {
    binaryData = buffer;
    posStack.insert(0, pos);
  }

  /// Push a new position onto the stack.
  /// [pos] is the position to push.
  void pushPos(int pos) {
    posStack.insert(0, pos);
  }

  /// Pop a position from the stack.
  int popPos() {
    return posStack.removeAt(0);
  }

  /// Get the current position.
  int pos() {
    return posStack[0];
  }

  /// Move the current position ahead by [size].
  int ahead(int size) {
    var result = posStack[0];
    posStack[0] += size;
    return result;
  }

  /// Read a byte from the buffer.
  int readByte() {
    return ByteData.view(binaryData).getInt8(ahead(1));
  }

  /// Read a short from the buffer.
  int readShort() {
    return ByteData.view(binaryData).getInt16(ahead(2), Endian.little);
  }

  /// Read an integer from the buffer.
  int readInt() {
    return ByteData.view(binaryData).getInt32(ahead(4), Endian.little);
  }

  /// Read a float from the buffer.
  double readFloat() {
    return ByteData.view(binaryData).getFloat32(ahead(4), Endian.little);
  }

  /// Reads a float array from the buffer.
  ///
  /// The [len] parameter specifies the length of the array to read.
  /// Returns a [Float32List] containing the read float array.
  Float32List readFloatArray(int len) {
    var arr = Float32List(len);
    for (var i = 0; i < len; i++) {
      arr[i] = readFloat();
    }
    return arr;
  }

  /// Reads a 2-element Float32List from the buffer.
  /// Returns the Float32List containing the read values.
  Float32List readFloat2() {
    return readFloatArray(2);
  }

  /// Reads a Float32List of length 3 from the buffer.
  Float32List readFloat3() {
    return readFloatArray(3);
  }

  /// Reads a Float32List of length 4 from the buffer.
  Float32List readFloat4() {
    return readFloatArray(4);
  }

  /// Reads a text buffer from the input stream using the specified encoding.
  ///
  /// The [encoding] parameter specifies the character encoding to use when decoding the text buffer.
  ///
  readTextBuffer(String encoding) {
    var length = readInt();
    // handle UTF-16 LE encoding (PMX uses UTF-16 LE)
    var buffer = encoding != 'utf-16le' ? binaryData.asUint8List(pos(), length) : binaryData.asUint16List(pos(), length);
    for (var i = 0; i < length; i++) {
      buffer[i] = readByte();
    }
    return buffer;
  }

  /// Reads a byte array of the specified length from the buffer.
  ///
  /// The [length] parameter specifies the number of bytes to read.
  /// Returns a [Uint8List] containing the read bytes.
  Uint8List readByteArray(int length) {
    var buffer = Uint8List(length);
    for (var i = 0; i < length; i++) {
      buffer[i] = readByte();
    }
    return buffer;
  }

  /// Reads an array of 16-bit integers from the buffer.
  ///
  /// The [length] parameter specifies the number of elements to read.
  /// Returns a list of integers with the specified length.
  List<int> readShortArray(int length) {
    var arr = List<int>.filled(length, 0);
    for (var i = 0; i < length; i++) {
      arr[i] = readShort();
    }
    return arr;
  }

  /// Reads an array of 32-bit integers from the buffer.
  ///
  /// The [length] parameter specifies the number of elements to read.
  /// Returns a list of integers with the specified length.
  List<int> readIntArray(int length) {
    var arr = List<int>.filled(length, 0);
    for (var i = 0; i < length; i++) {
      arr[i] = readInt();
    }
    return arr;
  }

  /// Reads an index value of the specified [size] from the buffer.
  ///
  /// The [size] parameter specifies the size of the index value in bytes.
  /// The [signed] parameter indicates whether the index value is signed or not.
  /// Returns the read index value. If [signed] is true and the read value is the maximum value for the specified size, -1 is returned.
  int readSizedIdx(int size, {bool signed = true}) {
    var result = -1;
    switch (size) {
      case 1:
        result = readByte();
        if (signed && result == 0xff) result = -1;
        break;
      case 2:
        result = readShort();
        if (signed && result == 0xffff) result = -1;
        break;
      case 4:
        result = readInt();
        if (signed && result == 0xffffffff) result = -1;
        break;
      default:
        throw Exception('Invalid index size: $size');
    }
    return result;
  }
}
