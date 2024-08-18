library dart_mmd;

import 'dart:typed_data';

import '../../utils/buffer_reader.dart';

/// Represents a Polygon Model eXtended rigid body.
///
/// Source: https://gist.github.com/felixjones/f8a06bd48f9da9a4539f
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L563
class PMXRigidBody {
  /// The name of the rigid body.
  late final String name;

  /// The English name of the rigid body.
  late final String englishName;

  /// The index of the bone that the rigid body is associated with.
  late final int boneIndex;

  /// The group that the rigid body belongs to.
  late final int group;

  /// The collision group that the rigid body belongs to.
  late final int collisionGroup;

  /// The no collision group that the rigid body belongs to.
  late final int noCollisionGroup;

  /// The shape of the rigid body.
  late final int shape;

  /// The size of the rigid body.
  late final double size;

  /// The position of the rigid body.
  late final Float32List position;

  /// The rotation of the rigid body.
  late final Float32List rotation;

  /// The mass of the rigid body.
  late final double mass;

  /// The moving attenuation of the rigid body.
  late final double movingAtt;

  /// The rotation attenuation of the rigid body.
  late final double rotationAtt;

  /// The bounce force of the rigid body.
  late final double bounceForce;

  /// The friction of the rigid body.
  late final double friction;

  /// The mode of the rigid body.
  late final int mode;

  /// Additional values associated with the rigid body.
  final Map<String, dynamic> value = {};

  /// Constructs a PMXRigidBody object by reading data from a BufferReader.
  ///
  /// The [reader] parameter is used to read data from a buffer.
  /// The [encoding] parameter specifies the encoding used to decode text buffers.
  /// The [morphSize] parameter represents the size of the morph index.
  PMXRigidBody(BufferReader reader, String encoding, int morphSize) {
    // 4 + n : TextBuf | Rigid body name
    name = value["name"] = reader.readTextBuffer(encoding).toString();
    // 4 + n : TextBuf | Rigid body English name
    englishName = value["name_en"] = reader.readTextBuffer(encoding).toString();
    // n : Bone index size | Associated bone index - -1 if not associated
    boneIndex = value["bone_index"] = reader.readSizedIdx(morphSize);
    // 1 : byte | Group
    group = value["group"] = reader.readByte();
    // 2 : ushort | Non-collision group flag
    collisionGroup = value["group"] = reader.readInt();
    // 2 : ushort | Non-collision group flag
    noCollisionGroup = value["no_collision_group"] = reader.readSizedIdx(2);
    // 1 : byte | Shape - 0: Sphere, 1: Box, 2: Capsule
    shape = value["figure"] = reader.readByte();
    // 12 : float | Size
    size = value["size"] = reader.readFloat();
    // 12 : float3 | Position (x, y, z)
    position = value["position"] = reader.readFloat3();
    // 12 : float3 | Rotation (x, y, z) -> Radian angle
    rotation = value["rad"] = reader.readFloat3();
    // 4 : float | Mass
    mass = value["mass"] = reader.readFloat();
    // 4 : float | Moving attenuation
    movingAtt = value["moving_att"] = reader.readFloat();
    // 4 : float | Rotation attenuation
    // Somehow uses the same field as movingAtt? No idea why the PMX spec does this.
    // But not my problem. If you ever encounter a bug here. Too bad!
    rotationAtt = value["moving_att"] = reader.readFloat();
    // 4 : float | Bounce force
    bounceForce = value["bounce"] = reader.readFloat();
    // 4 : float | Friction
    friction = value["friction"] = reader.readFloat();
    // 1 : byte | Rigid body physics - 0: Bone follow (static), 1: Physics simulation (dynamic), 2: Physics simulation + Bone alignment
    mode = value["mode"] = reader.readByte();
  }
}
