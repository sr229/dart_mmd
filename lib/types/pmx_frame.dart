library dart_mmd;

import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a PMX frame.
///
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L526
class PMXFrame {
    /// The name of the frame.
    late String name;

    /// The English name of the frame.
    late String englishName;

    /// The flag of the frame.
    late int flag;

    /// The inner count of the frame.
    late int innerCount;

    /// The inner data of the frame.
    late List<dynamic> innerData;

    /// The value of the frame.
    late Map<String, dynamic> value;

  /// Constructs a PMXFrame object by reading data from the provided [reader].
  /// The [encoding] parameter specifies the character encoding used for reading text buffers.
  /// The [boneSize] parameter specifies the size of the bone index.
  /// The [morphSize] parameter specifies the size of the morph index.
  PMXFrame(BufferReader reader, String encoding, int boneSize, int morphSize) {
    // 4 + n : TextBuf	| Frame name
    name = value['name'] = reader.readTextBuffer(encoding).toString();
    // 4 + n : TextBuf	| English frame name
    englishName = value['english_name'] = reader.readTextBuffer(encoding).toString();
    // 1  : byte	| Special frame flag - 0: Normal frame 1: Special frame
    flag = value['flag'] = reader.readByte();
    innerCount = value['inner_count'] = reader.readInt();
    for (var i = 0; i < innerCount; i++) {
      var inner = {};

      // 1 : byte	| Element target 0: Bone 1: Morph
      inner['type'] = reader.readByte();
      if (inner['type'] == 0) {
        //n  : Morph Index Size  | Morph Index
        inner['morph_idx'] = reader.readSizedIdx(boneSize);
      } else {
        //n  : Bone Index Size  | Bone Index
        inner['bone_idx'] = reader.readSizedIdx(morphSize);
      }
      innerData.add(inner);
    }
    value['inner_data'] = innerData;
  }
}
