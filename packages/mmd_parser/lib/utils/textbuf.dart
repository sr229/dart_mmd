library dart_mmd;

@Deprecated("Dart already supports this functionality with the 'String' class. This class is no longer used.")
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
