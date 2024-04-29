/// Removes leading and trailing whitespace from a string.
String rws(String str) => str.replaceAll(_reWs, ' ').trim();
final _reWs = RegExp(r'[\t\n\r ]+');

/// Rounds numbers <= 2^32 up to the nearest power of 2.
int pow2roundup(int x) {
  assert(x > 0);
  --x;
  x |= x >> 1;
  x |= x >> 2;
  x |= x >> 4;
  x |= x >> 8;
  x |= x >> 16;
  return x + 1;
}