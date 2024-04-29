library dart_mmd;

import 'package:dart_mmd/types/pmx/enums/bone_weight_deform_type.dart';
import 'package:dart_mmd/types/pmx/pmx_bone.dart';
import 'package:dart_mmd/types/pmx/pmx_entry.dart';
import 'package:dart_mmd/types/pmx/pmx_joint.dart';
import 'package:dart_mmd/types/pmx/pmx_material.dart';
import 'package:dart_mmd/types/pmx/pmx_morph.dart';
import 'package:dart_mmd/types/pmx/pmx_rigidbody.dart';
import 'package:dart_mmd/types/pmx/pmx_texture.dart';
import 'package:dart_mmd/types/pmx/pmx_vertex.dart';
import 'package:dart_mmd/utils/binary_reader.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';

class PMXFormat {
  bool? ready;

  String? name;
  String? nameEn;
  String? description;
  String? descriptionEn;

  List<PMXVertex>? vertices;
  List<int>? triangleIndexes;
  List<PMXTexture> textures = List<PMXTexture>.empty();
  List<PMXMaterial> materials = List<PMXMaterial>.empty();
  List<PMXBone> bones = List<PMXBone>.empty();
  List<PMXMorph> morphs = List<PMXMorph>.empty();
  List<PMXEntry> entries = List<PMXEntry>.empty();
  List<PMXRigidBody> rigidBodies = List<PMXRigidBody>.empty();
  List<PMXJoint> joints = List<PMXJoint>.empty();

  static PMXFormat load(BinaryReader reader) {
    PMXFormat format = PMXFormat();
    format.reload(reader);
    return format;
  }

  void reload(BinaryReader reader) {
    // clear the lists
    vertices = List<PMXVertex>.empty();
    triangleIndexes = List<int>.empty();
    textures = List<PMXTexture>.empty();
    materials = List<PMXMaterial>.empty();
    bones = List<PMXBone>.empty();

    int fileHeader = reader.readInt32();

    if (fileHeader != 0x20584D50) {
      throw Exception("Error: file is not a PMX file");
    }

    // in the original codebase, these ints were bytes
    // however in Dart, bytes are interopable with the int datatype
    // so we can assume all bytes are ints
    double version = reader.readFloat32();
    int flagsSize = reader.readByte(); // currently useless

    bool isUtf8Encoding = reader.readByte() == 1;
    int extraUvNumber = reader.readByte();
    int vertexIndexSize = reader.readByte();
    int textureIndexSize = reader.readByte();
    int materialindexSize = reader.readByte();
    int boneIndexSize = reader.readByte();
    int morphIndexSize = reader.readByte();
    int rigidBodyIndexSize = reader.readByte();

    var encoding = isUtf8Encoding ? "utf8" : "utf16-le";

    name = reader.readString();
    nameEn = reader.readString();
    description = reader.readString();
    descriptionEn = reader.readString();

    int vertexCount = reader.readInt32();
    
    vertices = List<PMXVertex>.filled(vertexCount, PMXVertex());
    for (int i = 0; i < vertexCount; i++) {
      var vertex = vertices![i];

      vertex.coordinate = _readVector3XInv(reader);
      vertex.normal = _readVector3(reader);
      vertex.uvCoordinate = _readVector2(reader);

      if (extraUvNumber > 0) {
        vertex.extraUvCoordinates = Vector4List(extraUvNumber);
        for (int j = 0; j < extraUvNumber; j++) {
          vertex.extraUvCoordinates![j] = _readVector4(reader);
        }
      }

      int skinningType = reader.readByte();

      switch(PMXBoneWeightDeformType.values[skinningType]) {
        case PMXBoneWeightDeformType.BDEF1:
          vertex.boneID0 = _readIndex(reader, boneIndexSize);
          vertex.boneID1 = -1;
          vertex.boneID2 = -1;
          vertex.boneID3 = -1;
          vertex.weights![i].x = 1;
          break;
        case PMXBoneWeightDeformType.BDEF2:
          vertex.boneID0 = _readIndex(reader, boneIndexSize);
          vertex.boneID1 = _readIndex(reader, boneIndexSize);
          vertex.boneID2 = -1;
          vertex.boneID3 = -1;
          vertex.weights![i].x = 1;
          vertex.weights![i].y = 1.0 - vertex.weights![i].x;
          break;
        case PMXBoneWeightDeformType.BDEF4:
          vertex.boneID0 = _readIndex(reader, boneIndexSize);
          vertex.boneID1 = _readIndex(reader, boneIndexSize);
          vertex.boneID2 = _readIndex(reader, boneIndexSize);
          vertex.boneID3 = _readIndex(reader, boneIndexSize);
          vertex.weights = Vector4List.fromList([_readVector4(reader)]);
          break;
        case  PMXBoneWeightDeformType.SDEF:
          vertex.boneID0 = _readIndex(reader, boneIndexSize);
          vertex.boneID1 = _readIndex(reader, boneIndexSize);
          vertex.boneID2 = -1;
          vertex.boneID3 = -1;
          vertex.weights![i].x = reader.readSingle();
          vertex.weights![i].y = 1.0 - vertex.weights![i].x;
          _readVector3(reader);
          _readVector3(reader);
          _readVector3(reader);
          break;
        default:
          throw Exception("Error: unknown skinning type");
      }
      vertex.edgeScale = reader.readSingle();
    }
  }

  int _readIndex(BinaryReader reader, int size) {
    if (size == 1) reader.readSByte();
    if (size == 2) reader.readInt16();

    return reader.readInt32();
  }

  /// Reads a single vertex from the binary file
  Vector2 _readVector2(BinaryReader reader) {
    return Vector2(reader.readSingle(), reader.readSingle());
  }

  /// Reads a single vertex from the binary file
  Vector3 _readVector3(BinaryReader reader) {
    return Vector3(reader.readSingle(), reader.readSingle(), reader.readSingle());
  }

  /// Reads a single vertex from the binary file, x inverted
  Vector3 _readVector3XInv(BinaryReader reader) {
    return Vector3(-reader.readSingle(), reader.readSingle(), reader.readSingle());
  }

  /// Reads a single vertex from the binary file, y and z inverted
  Vector3 _readVector3YZInv(BinaryReader reader) {
    return Vector3(reader.readSingle(), -reader.readSingle(), -reader.readSingle());
  }

  Vector4 _readVector4(BinaryReader reader) {
    return Vector4(reader.readSingle(), reader.readSingle(), reader.readSingle(), reader.readSingle());
  }

  Quaternion _readQuaternion(BinaryReader reader) {
    return Quaternion(reader.readSingle(), reader.readSingle(), reader.readSingle(), reader.readSingle());
  }
}
