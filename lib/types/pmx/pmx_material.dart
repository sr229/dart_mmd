library dart_mmd;

import 'dart:typed_data';
import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a Material in a Polygon Model eXtended model.
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L240
class PMXMaterial {
  /// The name of the material.
  late final String name;

  /// The English name of the material.
  late final String englishName;

  /// The diffuse color of the material.
  late final Float32List diffuse;

  /// The specular color of the material.
  late final Float32List specular;

  /// The specular intensity of the material.
  late final double specularMod;

  /// The ambient color of the material.
  late final Float32List ambient;

  /// The bit flag of the material.
  late final int bitFlag;

  /// The edge color of the material.
  late final Float32List edgeColor;

  /// The edge size of the material.
  late final double edgeSize;

  /// The index of the texture used by the material.
  late final int textureIndex;

  /// The index of the sphere used by the material.
  late final int sphereIndex;

  /// The sphere mode of the material.
  late final int sphereMode;

  /// The index of the shared toon used by the material.
  late final int sharedToon;

  /// The index of the toon used by the material.
  late final int toon;

  /// A memo for the material.
  late final String memo;

  /// The number of vertices that reference this material.
  late final int refsVertex;

  /// Additional dynamic value for the material.
  late Map<String, dynamic> value;

  /// Constructs a [PMXMaterial] object.
  ///
  /// The [reader] is used to read the material data from the PMX file.
  /// The [encoding] specifies the character encoding used in the PMX file.
  /// The [textureIndexSize] specifies the size of the texture index in bytes.
  PMXMaterial(BufferReader reader, String encoding, int textureIndexSize) {
    name = value['name'] = reader.readTextBuffer(encoding).toString();
    englishName = value['name_en'] = reader.readTextBuffer(encoding).toString();
    diffuse = value['diffuse'] = reader.readFloat4();
    specular = value['specular'] = reader.readFloat3();
    specularMod = value['specular_mod'] = reader.readFloat();
    ambient = value['ambient'] = reader.readFloat3();
    bitFlag = value['bit_flag'] = reader.readInt();
    edgeColor = value['edge_color'] = reader.readFloat4();
    edgeSize = value['edge_size'] = reader.readFloat();
    textureIndex = value['textureIdx'] = reader.readSizedIdx(textureIndexSize);
    sphereIndex = value['sphereIdx'] = reader.readSizedIdx(textureIndexSize);
    sphereMode = value['sphere_mode'] = reader.readByte();
    sharedToon = value['shared_toon'] = reader.readByte();
    toon = value['toon'] = sharedToon != 0
        ? reader.readByte()
        : reader.readSizedIdx(textureIndexSize);
    memo = value['memo'] = reader.readTextBuffer(encoding).toString();
    refsVertex = value['refs_vertex'] = reader.readInt();
  }
}
