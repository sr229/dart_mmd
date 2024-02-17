library dart_mmd;

import 'dart:typed_data';
import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a Polygon Model eXtended morph.
///
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L413
class PMXMorph {
  late final String name;
  late final String englishName;
  late final int panel;
  late final int morphType;
  late final int offsetSize;
  late final Map<String, dynamic> value;

  late final int morphIndex;
  late final double morphRate;
  late final int vertexIndex;
  late final Float32List coordinateOffset;

  late final int boneIndex;
  late final Float32List boneDistance;
  late final List<double> boneRotation;

  late final Float32List uvOffset;

  late final int materialIndex;
  late final int materialOffsetType;
  late final List<double> materialDiffuse;
  late final List<double> materialSpecular;
  late final double materialSpecularPower;
  late final List<double> materialAmbient;
  late final List<double> materialEdgeColor;
  late final double materialEdgeSize;
  late final List<double> materialTexture;
  late final List<double> materialSphere;
  late final List<double> materialToon;
  late final List<dynamic> offsetData;

  /// Constructs a PMXMorph object.
  ///
  /// [reader] - The buffer reader.
  /// [encoding] - The encoding used for reading text buffers.
  /// [vertexSize] - The size of the vertex index.
  /// [materialSize] - The size of the material index.
  /// [boneSize] - The size of the bone index.
  /// [morphSize] - The size of the morph index.
  PMXMorph(BufferReader reader, String encoding, int vertexSize,
      int materialSize, int boneSize, int morphSize) {
    // 4 + n : TextBuf | Morph name
    name = value["name"] = reader.readTextBuffer(encoding).toString();
    // 4 + n : TextBuf | Morph English name
    englishName =
        value["english_name"] = reader.readTextBuffer(encoding).toString();
    // 1 : byte | Operation panel (PMD: Category) 1: Eyebrow (bottom left) 2: Eye (top left) 3: Mouth (top right) 4: Other (bottom right) | 0: System reserved
    panel = value["panel"] = reader.readByte();
    // 1 : byte | Morph type - 0: Group, 1: Vertex, 2: Bone, 3: UV, 4: Additional UV1, 5: Additional UV2, 6: Additional UV3, 7: Additional UV4, 8: Material
    morphType = value["type"] = reader.readByte();
    // 4 : int | Number of offsets in the morph: number of subsequent elements
    offsetSize = value["offset_size"] = reader.readByte();

    for (var i = 0; i < offsetSize; i++) {
      Map<String, dynamic> offset = {};

      switch (morphType) {
        case 0: // Group morph
          // n : Morph index size | Morph index ※ Grouping of group morphs is not supported according to the specifications
          morphIndex = offset["morph_index"] = reader.readSizedIdx(vertexSize);
          // 4 : float | Morph rate: Group morph value * Morph rate = Target morph value
          morphRate = offset["morph_rate"] = reader.readFloat();
          break;
        case 1: // Vertex morph
          // n : Vertex index size | Vertex index
          vertexIndex =
              offset["vertex_index"] = reader.readSizedIdx(vertexSize);
          // 12 : float3 | Coordinate offset (x, y, z)
          coordinateOffset = offset["coordinate_offset"] = reader.readFloat3();
          break;
        case 2: // Bone morph
          // n : Bone index size | Bone index
          boneIndex = offset["bone_index"] = reader.readSizedIdx(boneSize);
          // 12 : float3 | Translation amount (x, y, z)
          boneDistance = offset["bone_distance"] = reader.readFloat3();
          // 16 : float4 | Rotation amount - Quaternion (x, y, z, w)
          boneRotation = offset["turning"] = reader.readFloat4();
          break;
        case 3: // UV morph
        case 4: // Additional UV1
        case 5: // Additional UV2
        case 6: // Additional UV3
        case 7: // Additional UV4
          // n : Vertex index size | Vertex index
          vertexIndex =
              offset["vertex_index"] = reader.readSizedIdx(vertexSize);
          // 16 : float4 | UV offset (x, y, z, w) ※ For normal UV, z and w are unnecessary items, but the data value as a morph is recorded
          uvOffset = offset["uv_offset"] = reader.readFloat4();
        case 8: // Material morph
          // n : Material index size | Material index -> -1: All materials targeted
          materialIndex =
              offset["material_idx"] = reader.readSizedIdx(materialSize);
          // 1 : Offset operation type | 0: Multiplication, 1: Addition - Details are described below
          materialOffsetType =
              offset["material_offset_type"] = reader.readByte();
          // 16 : float4 | Diffuse (R, G, B, A) - Multiplication: 1.0 / Addition: 0.0 is the initial value (same below)
          materialDiffuse = offset["material_diffuse"] = reader.readFloat4();
          // 12 : float3 | Specular (R, G, B)
          materialSpecular = offset["material_specular"] = reader.readFloat3();
          // 4 : float | Specular coefficient
          materialSpecularPower = offset["specular_mod"] = reader.readFloat();
          // 12 : float3 | Ambient (R, G, B)
          materialAmbient = offset["ambient"] = reader.readFloat3();
          // 16 : float4 | Edge color (R, G, B, A)
          materialEdgeColor = offset["edge_color"] = reader.readFloat4();
          // 4 : float | Edge size
          materialEdgeSize = offset["edge_size"] = reader.readFloat();
          // 16 : float4 | Texture coefficient (R, G, B, A)
          materialTexture = offset["texture_mod"] = reader.readFloat4();
          // 16 : float4 | Sphere texture coefficient (R, G, B, A)
          materialSphere = offset["sphere_mod"] = reader.readFloat4();
          // 16 : float4 | Toon texture coefficient (R, G, B, A)
          materialToon = offset["toon_mod"] = reader.readFloat4();
          break;
      }
      offsetData.add(offset);
    }
  }
}
