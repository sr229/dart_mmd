import 'dart:typed_data';
import 'package:dart_mmd_parser/utils/buffer_reader.dart';
import 'package:test/test.dart';

void main() {
  group('BufferReader readTextBuffer', () {
    test('should handle length exceeding buffer size', () {
      // Create a small buffer with a large length value
      var data = ByteData(100);

      // Write a very large length value (e.g., 10000000) that exceeds buffer
      data.setInt32(0, 10000000, Endian.little);

      // Add some dummy data
      for (int i = 4; i < 100; i++) {
        data.setUint8(i, 0x41); // 'A' character
      }

      var reader = BufferReader(data.buffer, 0);

      // Should not throw RangeError
      expect(() => reader.readTextBuffer('utf-8'), returnsNormally);
    });

    test('should handle UTF-16LE near end of buffer', () {
      var data = ByteData(50);

      // Request 100 bytes but only 46 remain after reading length
      data.setInt32(0, 100, Endian.little);

      // Fill with some UTF-16LE compatible data
      for (int i = 4; i < 50; i++) {
        data.setUint8(i, i % 2 == 0 ? 0x41 : 0x00); // UTF-16LE 'A's
      }

      var reader = BufferReader(data.buffer, 0);

      // Should not throw RangeError
      expect(() => reader.readTextBuffer('utf-16le'), returnsNormally);
    });

    test('should handle reading near end of large buffer', () {
      // Simulate the issue scenario with a ~2MB buffer
      var data = ByteData(2000100);

      // Position near the end (like in the error logs)
      var nearEndPos = 1999996;
      data.setInt32(nearEndPos, 1000,
          Endian.little); // Request 1000 bytes but only 100 remain

      var reader = BufferReader(data.buffer, nearEndPos);

      // Should not throw RangeError
      expect(() => reader.readTextBuffer('utf-16le'), returnsNormally);
    });

    test('should clamp length to remaining bytes', () {
      var data = ByteData(20);

      // Request 100 bytes but only 16 remain after reading the length int (4 bytes)
      data.setInt32(0, 100, Endian.little);

      // Fill remaining with valid UTF-8 data
      for (int i = 4; i < 20; i++) {
        data.setUint8(i, 0x41); // 'A' character
      }

      var reader = BufferReader(data.buffer, 0);
      var result = reader.readTextBuffer('utf-8');

      // Should read only the remaining 16 bytes
      expect(result.length, lessThanOrEqualTo(16));
    });
  });
}
