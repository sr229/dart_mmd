import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';

class PMXVertex {
  Vector3? coordinate;
  Vector3? normal;
  Vector2? uvCoordinate;
  double? edgeScale;

  Vector4List? extraUvCoordinates;
  int? boneID0;
  int? boneID1;
  int? boneID2;
  int? boneID3;
  Vector4List? weights;

  @override
  String toString() {
    return coordinate.toString();
  }
}
