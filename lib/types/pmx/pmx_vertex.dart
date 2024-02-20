library dart_mmd;

import 'dart:typed_data';
import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a Polygon Model eXtended (PMX) vertex.
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L124
///
/// This class contains various properties that define the attributes of a vertex in a PMX model.
/// The properties include the vertex position, normal, UV coordinates, bone weights, and more.
class PMXVertex {
  /// The length of the vertex.
  late final int length;

  /// The position of the vertex.
  late final Float32List pos;

  /// The normal vector of the vertex.
  late final Float32List norm;

  /// The UV coordinates of the vertex.
  late final Float32List uv;

  /// The additional UV coordinates of the vertex.
  late final Float32List uvAppend;

  /// The type of the vertex.
  late final int type;

  /// The bones affecting the vertex.
  List<dynamic> bones = [];

  /// The weights of the vertex.
  late final List<double> weights;

  /// The SDEF data of the vertex.
  late final List<dynamic> sdef;

  /// The edge flag of the vertex.
  late final double edge;

  /// K/V data for the vertex. Used internally.
  Map<String, dynamic> value = {};

  /// Constructs a PMXVertex object from the given [reader], [uvAppend], and [boneSize].
  ///
  /// The [reader] is used to read the vertex data from a buffer.
  /// The [uvAppend] specifies the number of additional UV coordinates for the vertex.
  /// The [boneSize] specifies the size of the bone data for the vertex.
  PMXVertex(BufferReader reader, int uvAppend, int boneSize) {
    pos = value['pos'] = reader.readFloat3();
    norm = value['norm'] = reader.readFloat3();
    uv = value['uv'] = reader.readFloat2();

    if (uvAppend == 1) {
      for (var i = 0; i < uvAppend; i++) {
        // the TypeScript version of this just appends from number[], so I'm assuming it's the same here
        // readFloat4 is Float32List, which is List<double>, exactly like the original.
        this.uvAppend.add(reader.readFloat4() as double);
      }

      value['uv_append'] = this.uvAppend;
    }

    type = value['type'] = reader.readByte();

    // copy-pasted from the TypeScript reference, so I'm assuming it's the same here
    // comments were also carried over and translated, with some reviews from the PMX specification for correctness
    switch (type) {
      case 0: // BDEF1
        // n: Bone index size | Single bone with weight 1.0 (reference index)
        bones.add(reader.readSizedIdx(boneSize));
        value['bones'] = bones;
        break;
      case 1: // BDEF2
        //  n : Bone index size | Reference index of bone 1
        //  n : Bone index size | Reference index of bone 2
        for (var i = 0; i < 2; i++) {
          bones.add(reader.readSizedIdx(boneSize));
        }

        weights.add(reader.readFloat());
        value['bones'] = bones;
        value['weight'] = weights;
        break;
      case 2: // BDEF4
        //  n : Bone index size | Reference index of bone 1
        //  n : Bone index size | Reference index of bone 2
        //  n : Bone index size | Reference index of bone 3
        //  n : Bone index size | Reference index of bone 4
        for (var i = 0; i < 4; i++) {
          bones.add(reader.readSizedIdx(boneSize));
        }

        value['bones'] = bones;
        //  4 : float              | Weight value of bone 1
        //  4 : float              | Weight value of bone 2
        //  4 : float              | Weight value of bone 3
        //  4 : float              | Weight value of bone 4 (No guarantee of total weight being 1.0)
        for (var i = 0; i < 4; i++) {
          weights.add(reader.readFloat());
        }

        value['weight'] = weights;
        break;
      case 3: // SDEF
        //  n : Bone index size | Reference index of bone 1
        //  n : Bone index size | Reference index of bone 2
        for (var i = 0; i < 2; i++) {
          bones.add(reader.readSizedIdx(boneSize));
        }

        value['bones'] = bones;

        //  4 : float           | Weight value of bone 1
        weights.add(reader.readFloat());
        value['weight'] = weights;

        // 12 : float3             | SDEF-C value (x, y, z)
        // 12 : float3             | SDEF-R0 value (x, y, z)
        // 12 : float3             | SDEF-R1 value (x, y, z) *Requires calculation of correction value
        for (var i = 0; i < 3; i++) {
          sdef.add(reader.readFloat3());
        }
        value['sdef'] = sdef;
        break;
      default:
        // always good to have a default case
        throw Exception('Invalid vertex type: $type');
    }

    edge = value['edge'] = reader.readFloat();
  }
}
