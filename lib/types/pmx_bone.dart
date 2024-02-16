library dart_mmd;

import 'dart:typed_data';
import 'package:dart_mmd/utils/textbuf.dart';
import 'package:dart_mmd/utils/buffer_reader.dart';

/// Represents a PMX bone.
///
/// Source: https://gist.github.com/felixjones/5f4479c9c9d1682b2f3a
///
/// This is originally ported from a TypeScript version of the library.
/// Source: https://github.com/kanryu/pmx/blob/master/pmx.ts#L302
class PMXBone {
  /// The name of the bone.
  late TextBuf name;

  /// The English name of the bone.
  late TextBuf englishName;

  /// The position of the bone.
  late final Float32List position;

  /// The index of the parent bone.
  late final int parentIndex;

  /// The index of the morph.
  late final int morphIndex;

  /// The bit flag of the bone.
  late final int bitFlag;

  /// The index of the connected bone.
  late final int connectIndex;

  /// The offset of the bone.
  late final Float32List offset;

  /// The index of the invested parent bone.
  late final int investParentIndex;

  /// The investment rate of the bone.
  late final double investRate;

  /// The axis vector of the bone.
  late final Float32List axisVector;

  /// The X-axis vector of the bone.
  late final Float32List xAxisVector;

  /// The Z-axis vector of the bone.
  late final Float32List zAxisVector;

  /// The parent key of the bone.
  late final int parentKey;

  /// The index of the IK target bone.
  late final int ikTargetIndex;

  /// The length of the IK loop.
  late final int ikLoopLength;

  /// The radian limit of the IK.
  late final double ikRadLimit;

  /// The length of the IK link.
  late final int ikLinkLength;

  /// The list of IK links.
  late final List<dynamic> ikLinks;

  /// The value of the bone.
  late final Map<String, dynamic> value;

  /// Constructs a PMXBone object.
  ///
  /// The [reader] parameter is used to read data from a buffer.
  /// The [encoding] parameter specifies the character encoding to be used.
  /// The [boneSize] parameter specifies the size of the bone.
  PMXBone(BufferReader reader, String encoding, int boneSize) {
    //4 + n : TextBuf	| Bone name
    name = value["name"] =
        TextBuf(boneSize, reader.readTextBuffer(encoding).toString());
    //4 + n : TextBuf	| Bone English name
    englishName = value["name_en"] =
        TextBuf(boneSize, reader.readTextBuffer(encoding).toString());
    //12 : float3	| Position
    position = value["position"] = reader.readFloat3();
    //4  : int		| Deformation Hierarchy
    parentIndex = value["parent_index"] = reader.readInt();

    //2  : bitFlag*2	| Bone flags (16 bits) Each bit 0: OFF 1: ON
    // 0x0001  : Connection destination (PMD child bone specified) display method -> 0: Specified by coordinate offset 1: Specified by bone
    // 0x0002  : Rotatable
    // 0x0004  : Movable
    // 0x0008  : Display
    // 0x0010  : Operable
    // 0x0020  : IK
    // 0x0080  : Local addition | Target 0: User deformation value / IK link / Multiple additions 1: Parent's local deformation amount
    // 0x0100  : Rotation addition
    // 0x0200  : Movement addition
    // 0x0400  : Axis fixed
    // 0x0800  : Local axis
    // 0x1000  : Physical after deformation
    // 0x2000  : External parent deformation
    bitFlag = value["bit_flag"] = reader.readShort();

    if (bitFlag & 0x1 != 0) {
      //4  : int		| Connection destination
      connectIndex = value["connect_idx"] = reader.readSizedIdx(boneSize);
    } else {
      //12 : float3	| Offset
      offset = value["offset"] = reader.readFloat3();
    }

    if (bitFlag & 0x0300 != 0) {
      investParentIndex =
          value["invest_parent_idx"] = reader.readSizedIdx(boneSize);
      investRate = value["invest_rate"] = reader.readFloat();
    }

    if (bitFlag & 0x0400 != 0) {
      axisVector = value["axis_vector"] = reader.readFloat3();
    }

    if (bitFlag & 0x0800 != 0) {
      // 12 : float3	| X-axis direction vector
      xAxisVector = value["x_axis_vector"] = reader.readFloat3();
      // 12 : float3	| Z-axis direction vector ※ Frame axis calculation method is described later
      zAxisVector = value["z_axis_vector"] = reader.readFloat3();
    }

    if (bitFlag & 0x2000 != 0) {
      // 4  : int		| Parent key
      parentKey = value["parent_key"] = reader.readInt();
    }

    if (bitFlag & 0x0020 != 0) {
      // n  : Bone index size | IK target bone's bone index
      ikTargetIndex = value["ik_target_idx"] = reader.readSizedIdx(boneSize);
      // 4  : int  	| IK loop count (255 is the maximum in PMD and MMD environments)
      ikLoopLength = value["ik_loop_length"] = reader.readInt();
      // 4  : float	| Limit angle per loop in IK calculation -> Radian angle | Note that it is 4 times different from the IK value in PMD
      ikRadLimit = value["ik_rad_limited"] = reader.readFloat();
      // 4  : int  	| Number of IK links: number of subsequent elements
      ikLinkLength = value["ik_link_length"] = reader.readInt();

      ikLinks = value["ik_links"] = [];

      for (var i = 0; i < ikLinkLength; i++) {
        Map<String, dynamic> ikLink = {
          "link_idx": reader.readSizedIdx(boneSize)
        };

        //   1  : byte	| Angle limit 0: OFF 1: ON
        ikLink["rad_limited"] = reader.readByte();
        if (ikLink["read_limited"] != 0) {
          // 12 : float3	| Lower limit (x, y, z) -> Radian angle
          ikLink["lower_vector"] = reader.readFloat();
          // 12 : float3	| Upper limit (x, y, z) -> Radian angle
          ikLink["upper_vector"] = reader.readFloat();
        }
        ikLinks.add(ikLink);
      }
    }
    value["ik_links"] = ikLinks;
  }
}
