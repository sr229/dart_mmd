import 'dart:typed_data';

import 'package:dart_mmd/types/pmx/enums/draw_flag.dart';
import 'package:vector_math/vector_math.dart';

class PMXMaterial {
  String? name;
  String? nameEn;
  Vector4? diffuseColor;
  Vector3? specularColor;
  Vector3? ambientColor;
  PMXDrawFlag? drawFlags;
  Vector4? edgeColor;
  double? edgeScale;
  int? textureIndex;
  int? sphereTextureIndex;
  int? sphereTextureType;
  bool? useToon;
  int? toonIndex;
  String? meta;
  int? triangleIndexStartNum;
  int? triangleIndexNum;

  @override
  String toString() {
    return "$name";
  }
}