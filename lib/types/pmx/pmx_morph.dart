import 'package:dart_mmd/types/pmx/enums/morph_category.dart';
import 'package:dart_mmd/types/pmx/enums/morph_material_method.dart';
import 'package:dart_mmd/types/pmx/enums/morph_type.dart';
import 'package:vector_math/vector_math.dart';

class PMXMorphSubMorphDesc {
  int? groupIndex;
  double? rate;
}

class PMXMorphUVDesc {
  int? vertexIndex;
  Vector4? offset;
}

class PMXMorphMaterialDesc {
  int? materialIndex;
  PMXMorphMaterialMethod? morphMethod;
  Vector4? diffuse;
  Vector4? specular;
  Vector3? ambient;
  Vector4? edgecolor;
  double? edgeSize;
  Vector4? texture;
  Vector4? subTexture;
  Vector4? toonTexture;
}

class PMXMorphVertexDesc {
  int? vertexIndex;
  Vector3? offset;
}

class PMXMorphBoneDesc {
  int? boneIndex;
  Vector3? translation;
  Quaternion? rotation;
}

class PMXMorph {
  String? name;
  String? nameEn;
  PMXMorphCategory? category;
  PMXMorphType? type;

  List<PMXMorphSubMorphDesc>? subMorphs;
  List<PMXMorphUVDesc>? morphUVs;
  List<PMXMorphMaterialDesc>? morphMaterials;
  List<PMXMorphVertexDesc>? morphVertices;
  List<PMXMorphBoneDesc>? morphBones;

  @override
  String toString() {
    return "$name";
  }
}
