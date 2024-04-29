library dart_mmd;

class PMXEntryElement {
  int? type;
  int? index;

  @override
  String toString() {
    return "$type, $index";
  }
}

class PMXEntry {
  String? name;
  String? nameEn;
  List<PMXEntryElement>? elements;

  @override
  String toString() {
    return "$name";
  }
}
