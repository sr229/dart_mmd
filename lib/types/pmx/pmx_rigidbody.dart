library dart_mmd;

import 'package:dart_mmd/types/pmx/enums/rigidbody_shape.dart';
import 'package:dart_mmd/types/pmx/enums/rigidbody_type.dart';
import 'package:vector_math/vector_math.dart';

class PMXRigidBody {
  String? name;
  String? nameEn;
  int? associatedBoneIndex;
  int? collisionGroup;
  int? collisionMask;
  PMXRigidBodyShape? shape;
  Vector3? dimensions;
  Vector3? position;
  Vector3? rotation;
  double? mass;
  double? translateDamp;
  double? rotateDamp;
  double? restitution;
  double? friction;
  PMXRigidBodyType? type;

  @override
  String toString() {
    return "$name";
  }
}
