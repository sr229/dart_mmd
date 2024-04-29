library dart_mmd;

import 'package:vector_math/vector_math.dart';

class PMXJoint {
  String? name;
  String? nameEn;
  int? type;
  int? associatedRigidBodyIndex1;
  int? associatedRigidBodyIndex2;
  Vector3? position;
  Vector3? rotation;
  Vector3? positionMinimum;
  Vector3? positionMaximum;
  Vector3? rotationMinimum;
  Vector3? rotationMaximum;
  Vector3? positionSpring;
  Vector3? rotationSpring;

  @override
  String toString() {
    return "$name";
  }
}
