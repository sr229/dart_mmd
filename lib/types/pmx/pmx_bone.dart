import 'package:dart_mmd/types/pmx/enums/bone_flag.dart';
import 'package:vector_math/vector_math.dart';

class PMXBoneLink {
  int? linkedIndex;
  bool? hasLimit;
  Vector3? limitMin;
  Vector3? limitMax;
}

class PMXBoneIKLink {
  int? linkedIndex;
  bool? hasLimit;
  Vector3? limitMin;
  Vector3? limitMax;
}

class PMXBoneIK {
  int? ikTargetIndex;
  int? ccdIterateLimit;
  double? ccdAngleLimit;
  List<PMXBoneIKLink>? ikLinks;
}

class PMXBone {
  String? name;
  String? nameEn;
  Vector3? position;
  int? parentIndex;
  int? transformLevel;
  PMXBoneFlag? flags;
  int? childID;
  Vector3? childOffset;
  Vector3? rotAxisFixed;

  int? appendBoneIndex;
  double? appendBoneRatio;

  Vector3? localAxisX;
  Vector3? localAxisY;
  Vector3? localAxisZ;

  int? exportKey;
  PMXBoneIK? boneIK;

  @override
  String toString() {
    return "$name";
  }
}
