library dart_mmd;

import 'dart:convert';

import 'dart:typed_data';

import 'package:dart_mmd/utils/util.dart';

class BinaryReader {
  /// The UTF-8 decoder used to decode binary data into strings.
  static const utf8Decoder = Utf8Decoder();

  /// The offset in the buffer.
  int _offset = 0;

  final ByteData _byteData;

  /// Internal buffer accumulating bytes.
  ///
  /// Will grow as necessary
  final Uint8List _buffer;

  BinaryReader(this._buffer)
      : _byteData = ByteData.view(_buffer.buffer, _buffer.offsetInBytes);

  /// returns the current offset
  int get offset => _offset;

  /// sets the current offset
  ///
  /// throws [RangeError] if the offset is out of bounds
  set offset(int val) {
    if (_buffer.length < val || val < 0) {
      throw RangeError('Not enough bytes available.');
    }
    _offset = val;
  }

  /// read a single byte
  int readByte() {
    _reserveBytes(1);
    _offset += 1;
    return _byteData.getUint8(_offset - 1);
  }

  /// read a single-precision floating-point number
  double readSingle() {
    _reserveBytes(4);
    _offset += 4;
    return _byteData.getFloat32(_offset - 4);
  }

  /// read a signed byte
  int readSByte() {
    _reserveBytes(1);
    _offset += 1;
    return _byteData.getInt8(_offset - 1);
  }

  /// returns the remaining bytes in the buffer
  int get peek => _buffer.length - _offset;

  DateTime readDateTime() => DateTime.fromMillisecondsSinceEpoch(readInt64());

  double readFloat32() {
    _reserveBytes(4);
    _offset += 4;
    return _byteData.getFloat32(_offset - 4);
  }

  double readFloat64() {
    _reserveBytes(8);
    _offset += 8;
    return _byteData.getFloat64(_offset - 8);
  }

  int readInt16() {
    _reserveBytes(2);
    _offset += 2;
    return _byteData.getInt16(_offset - 2);
  }

  int readInt32() {
    _reserveBytes(4);
    _offset += 4;
    return _byteData.getInt32(_offset - 4);
  }

  int readInt64() {
    _reserveBytes(8);
    _offset += 8;
    return _byteData.getInt64(_offset - 8);
  }

  int readInt8() {
    _reserveBytes(1);
    _offset += 1;
    return _byteData.getInt8(_offset - 1);
  }

  Float32List readListFloat32({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Float32List.view(_buffer_null, 0, 0);
    align(4);
    _reserveBytes(_l * 4);
    _offset += _l * 4;
    return Float32List.view(_buffer.buffer, _offset - _l * 4, _l);
  }

  Float64List readListFloat64({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Float64List.view(_buffer_null, 0, 0);
    align(8);
    _reserveBytes(_l * 8);
    _offset += _l * 8;
    return Float64List.view(_buffer.buffer, _offset - _l * 8, _l);
  }

  Int16List readListInt16({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Int16List.view(_buffer_null, 0, 0);
    align(2);
    _reserveBytes(_l * 2);
    _offset += _l * 2;
    return Int16List.view(_buffer.buffer, _offset - _l * 2, _l);
  }

  Int32List readListInt32({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Int32List.view(_buffer_null, 0, 0);
    align(4);
    _reserveBytes(_l * 4);
    _offset += _l * 4;
    return Int32List.view(_buffer.buffer, _offset - _l * 4, _l);
  }

  Int64List readListInt64({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Int64List.view(_buffer_null, 0, 0);
    align(8);
    _reserveBytes(_l * 8);
    _offset += _l * 8;
    return Int64List.view(_buffer.buffer, _offset - _l * 8, _l);
  }

  Int8List readListInt8({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Int8List.view(_buffer_null, 0, 0);
    align(1);
    _reserveBytes(_l * 1);
    _offset += _l * 1;
    return Int8List.view(_buffer.buffer, _offset - _l * 1, _l);
  }

  Uint16List readListUint16({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Uint16List.view(_buffer_null, 0, 0);
    align(2);
    _reserveBytes(_l * 2);
    _offset += _l * 2;
    return Uint16List.view(_buffer.buffer, _offset - _l * 2, _l);
  }

  Uint32List readListUint32({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Uint32List.view(_buffer_null, 0, 0);
    align(4);
    _reserveBytes(_l * 4);
    _offset += _l * 4;
    return Uint32List.view(_buffer.buffer, _offset - _l * 4, _l);
  }

  Uint64List readListUint64({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Uint64List.view(_buffer_null, 0, 0);
    align(8);
    _reserveBytes(_l * 8);
    _offset += _l * 8;
    return Uint64List.view(_buffer.buffer, _offset - _l * 8, _l);
  }

  Uint8List readListUint8({int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    if (_l == 0) return Uint8List.view(_buffer_null, 0, 0);
    align(1);
    _reserveBytes(_l * 1);
    _offset += _l * 1;
    return Uint8List.view(_buffer.buffer, _offset - _l * 1, _l);
  }

  static final _buffer_null = Uint8List.fromList(const []).buffer;

  /// Функция чтения списка объектов, где на каждый объект вызывается функция
  /// переданная в первом аргументе
  List<T> readList<T>(T Function(int i, BinaryReader reader) func,
      {int csz = 0, int? size}) {
    final _l = readSize(csz: csz, size: size);
    return List<T>.generate(_l, (i) => func(i, this));
  }

  String readString(
          {int csz = 0, int? size, Converter<List<int>, String>? decoder}) =>
      (decoder ?? utf8Decoder).convert(readListUint8(size: size, csz: csz));

  String readString1({int? size, Converter<List<int>, String>? decoder}) =>
      readString(size: size, decoder: decoder, csz: 1);
  String readString2({int? size, Converter<List<int>, String>? decoder}) =>
      readString(size: size, decoder: decoder, csz: 2);
  String readString3({int? size, Converter<List<int>, String>? decoder}) =>
      readString(size: size, decoder: decoder, csz: 3);
  String readString4({int? size, Converter<List<int>, String>? decoder}) =>
      readString(size: size, decoder: decoder, csz: 4);

  String readStringW({int csz = 0, int? size}) =>
      String.fromCharCodes(readListUint16(size: size, csz: csz));

  String readStringW1({int? size}) => readStringW(size: size, csz: 1);
  String readStringW2({int? size}) => readStringW(size: size, csz: 2);
  String readStringW3({int? size}) => readStringW(size: size, csz: 3);
  String readStringW4({int? size}) => readStringW(size: size, csz: 4);

  int readUint16() {
    _reserveBytes(2);
    _offset += 2;
    return _byteData.getUint16(_offset - 2);
  }

  int readUint32() {
    _reserveBytes(4);
    _offset += 4;
    return _byteData.getUint32(_offset - 4);
  }

  int readUint64() {
    _reserveBytes(8);
    _offset += 8;
    return _byteData.getUint64(_offset - 8);
  }

  int readUint8() {
    _reserveBytes(1);
    _offset += 1;
    return _byteData.getUint8(_offset - 1);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void skip(int bytes) {
    _reserveBytes(bytes);
    _offset += bytes;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int readSize({int csz = 0, int? size}) {
    if (size != null) {
      return size;
    }
    switch (csz) {
      case 0:
        final b1 = readUint8();
        if (b1 & 0x80 == 0) {
          return b1;
        }
        final b2 = readUint8();
        if (b2 & 0x80 == 0) {
          return (b2 << 7) | (b1 & 0x7f);
        }
        final b3 = readUint8();
        if (b3 & 0x80 == 0) {
          return (b3 << 14) | ((b2 & 0x7f) << 7) | (b1 & 0x7f);
        }
        final b4 = readUint8();
        return (b4 << 21) |
            ((b3 & 0x7f) << 14) |
            ((b2 & 0x7f) << 7) |
            (b1 & 0x7f);
      case 1:
        return readUint8();
      case 2:
        return readUint16();
      case 3:
        return readUint32();
      case 4:
        return readUint64();
      default:
        throw ArgumentError('CSZ incorrect');
    }
  }

  /// Aligns the current offset to the nearest multiple of [bytes].
  ///
  /// The [bytes] value must be a power of 2.
  ///
  /// If the current offset is already aligned to the nearest multiple of
  /// [bytes], this method does nothing. Otherwise, it skips the necessary
  /// number of bytes to align the offset.
  void align(int bytes) {
    assert(
        bytes == pow2roundup(bytes), 'Указано не кратное степени 2 значение');
    final n = bytes - (_offset & (bytes - 1));
    if (n == bytes) {
      return;
    }
    skip(n);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void _reserveBytes(int byteCount) {
    if (byteCount == 0) return;
    final required = _offset + byteCount;
    if (_buffer.length < required) {
      throw RangeError('Not enough bytes available.');
    }
  }
}
