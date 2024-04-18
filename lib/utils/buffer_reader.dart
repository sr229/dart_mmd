library dart_mmd;

import 'dart:typed_data';

import 'package:utf_convert/utf_convert.dart';

/// BufferReader is a specialised class for reading from a PMX/VMD buffer.
/// This is originally ported from a TypeScript version of the library.
///
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts
class BufferReader {
  var _posStack = [0];
  late final ByteBuffer _buffer;

  /// Create a new BufferReader from a ByteBuffer.
  /// [buffer] is the buffer to read from.
  /// [pos] is the initial position to start reading from.
  BufferReader(ByteBuffer buffer, [int pos = 0]) {
    _buffer = buffer;
    _posStack = [0];

    if (pos != 0) _posStack[0] = pos;
  }

  /// Push a new position onto the stack.
  /// [pos] is the position to push.
  void pushStack(int pos) {
    _posStack.insert(0, pos);
  }

  /// Pop a position from the stack.
  void popStack() {
    var result = _posStack.removeAt(0);
    
    if (_posStack.isEmpty) {
      _posStack[0] = result;
    }
  }

  /// Get the current position.
  int stackPos() {
    return _posStack[0];
  }

  /// Move the current position ahead by [size].
  int stackAhead(int size) {
    var result = _posStack[0];
    _posStack[0] += size;
    return result;
  }

  /// Read a byte from the buffer.
  int readByte() {
    // read a byte from the buffer
    return ByteData.view(_buffer).getUint8(stackAhead(1));
  }

  /// Read a short from the buffer.
  int readShort() {
    return ByteData.view(_buffer).getInt16(stackAhead(2), Endian.little);
  }

  /// Read an integer from the buffer.
  int readInt() {
    // in the original code this is readUInt32LE. Let's use the Dart equivalent.
    return ByteData.view(_buffer).getInt32(stackAhead(4), Endian.little);
  }

  /// Read a float from the buffer.
  double readFloat() {
    return ByteData.view(_buffer).getFloat32(stackAhead(4), Endian.little);
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
  String readTextBuffer(String encoding) {
    var length = readInt();

    // length can go larger than the byte array, make sure to clamp it
    if (length > _buffer.lengthInBytes) {
      length = _buffer.lengthInBytes - stackPos();
    }

    var decoded = encoding != 'utf-8'
        ? decodeUtf16le(_buffer.asUint8List(), stackPos(), length)
        : decodeUtf8(_buffer.asUint8List(), stackPos(), length);

    _posStack[0] += length;

    return decoded;
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
