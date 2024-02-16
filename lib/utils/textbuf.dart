library dart_mmd;

/// Represents a text buffer with a specified length and value.
class TextBuf {
  late String value;
  late int length;

  /// Creates a new instance of the [TextBuf] class with the specified length and value.
  TextBuf(int len, String value) {
    length = len;
    value = value;
  }
}
