library dart_mmd;

import 'dart:typed_data';

import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a Polygon Model eXtended joint.
///
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L619
class PMXJoint {
  /// The name of the joint.
  late final String name;

  /// The English name of the joint.
  late final String englishName;

  /// The type of the joint.
  late final int type;

  /// The index of the rigid body A.
  late final int rigidBodyA;

  /// The index of the rigid body B.
  late final int rigidBodyB;

  /// The position of the joint.
  late final Float32List position;

  /// The rotation of the joint in radians.
  late final Float32List rotation;

  /// The lower limit of the position for the joint.
  late final Float32List positionLowerLimit;

  /// The upper limit of the position for the joint.
  late final Float32List positionUpperLimit;

  /// The lower limit of the rotation for the joint.
  late final Float32List rotationLowerLimit;

  /// The upper limit of the rotation for the joint.
  late final Float32List rotationUpperLimit;

  /// The bounce value for moving.
  late final Float32List bounceMoving;

  /// The bounce value for rotation.
  late final Float32List bounceRotation;

  /// K/V data for the joint. Used internally.
  Map<String, dynamic> value = {};

  /// Constructs a PMXJoint object from the given [reader].
  ///
  /// The [reader] is used to read the joint data from a buffer.
  PMXJoint(BufferReader reader, String encoding) {
    // 4 + n : TextBuf	| Japanese name
    name = value["name"] = reader.readTextBuffer(encoding).toString();
    // 4 + n : TextBuf	| English name
    englishName = value["name_en"] = reader.readTextBuffer(encoding).toString();
    // 1  : byte	| Joint Type - 0:Spring 6DOF   | Only 0 is supported in PMX2.0 (for extension)
    type = value["type"] = reader.readByte();

    // guard against unsupported joint types
    if (type != 0) {
      throw UnsupportedError('Unsupported joint type: $type');
    }

    // 4  : int	| Rigid Body A
    rigidBodyA = value["rigid_a_idx"] = reader.readSizedIdx(4);
    // 4  : int	| Rigid Body B
    rigidBodyB = value["rigid_b_idx"] = reader.readSizedIdx(4);
    // 12 : float3	| Position
    position = value["position"] = reader.readFloat3();
    // 12 : float3	| Rotation
    rotation = value["rad"] = reader.readFloat3();
    // 12 : float3	| Position Lower Limit
    positionLowerLimit = value["position_lower_vector"] = reader.readFloat3();
    // 12 : float3	| Position Upper Limit
    positionUpperLimit = value["position_upper_vector"] = reader.readFloat3();
    // 12 : float3	| Rotation Lower Limit
    rotationLowerLimit = value["rad_lower_vector"] = reader.readFloat3();
    // 12 : float3	| Rotation Upper Limit
    rotationUpperLimit = value["rad_upper_vector"] = reader.readFloat3();
    // 12 : float3	| Spring Constant - Moving (x, y, z)
    bounceMoving = value["spring_constant_moving"] = reader.readFloat3();
    // 12 : float3	| Spring Constant - Rotation (x, y, z)
    bounceRotation = value["spring_constant_rotation"] = reader.readFloat3();
  }
}
