import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

class GeometryBuilder {
  final List<dynamic> _positions = [];
  final List<dynamic> _uvs = [];
  final List<dynamic> _normals = [];

  final List<dynamic> _indices = [];
  final List<dynamic> _groups = [];

  final List<dynamic> bones = [];
  final List<dynamic> _skinIndices = [];
  final List<dynamic> _skinWeights = [];

  final List<dynamic> _morphTargets = [];
  final List<dynamic> _morphPositions = [];

  final List<dynamic> _iks = [];
  final List<dynamic> _grants = [];
  final List<dynamic> _rigidBodies = [];
  final List<dynamic> _constraints = [];
  dynamic _data;

  void build(dynamic data) {
    _data = data;
    var offset = 0;
    final boneTypeTable = {};

    // build the positions, normals, uvs, skinIndices, skinWeights, and indices
    for (var i = 0; i < data.metadata.vertexCount; i++) {
      final v = data.vertices[i];

      for (var j = 0, jl = v.position.length; j < jl; j++) {
        _positions.add(v.position[j]);
      }

      for (var j = 0, jl = v.normal.length; j < jl; j++) {
        _normals.add(v.normal[j]);
      }

      for (var j = 0, jl = v.uv.length; j < jl; j++) {
        _uvs.add(v.uv[j]);
      }

      for (var j = 0, jl = v.skinIndices.length; j < jl; j++) {
        _skinIndices.add(v.skinIndices[j]);
      }

      for (var j = 0, jl = v.skinWeights.length; j < jl; j++) {
        _skinWeights.add(v.skinWeights[j]);
      }
    }

    // build the indices
    for (var i = 0; i < data.metadata.faceCount; i++) {
      final face = data.faces[i];

      for (var j = 0, jl = face.indices.length; j < jl; j++) {
        _indices.add(face.indices[j]);
      }
    }

    // build the groups
    for (var i = 0; i < data.metadata.materialCount; i++) {
      final material = data.materials[i];

      _groups.add({
        'offset': offset,
        'count': material.faceCount,
        'materialIndex': i,
      });

      offset += material.faceCount as int;
    }

    for (var i = 0; i < data.metadata.boneCount; i++) {
      final bData = data.bones[i];

      Map<String, dynamic> bone = {
        'parent': bData.parentIndex,
        'name': bData.name,
        'pos': bData.position,
        'rotq': bData.rotation,
        'scl': bData.scale,
        'rot': bData.rotation,
      };

      if (bone['parent'] != -1) {
        bone['pos'][0] -= data.bones[bone['parent']].position[0];
        bone['pos'][1] -= data.bones[bone['parent']].position[1];
        bone['pos'][2] -= data.bones[bone['parent']].position[2];
      }

      bones.add(bone);

      // in the original threejs code, pmd and pmx bone code is duplicated
      // obviously we need to handle it in a more elegant way
      for (var i = 0; i < data.metadata.ikCount; i++) {
        final ik = data.iks[i];

        final params = {
          'target': ik.target,
          'effector': ik.effector,
          'iteration': ik.iteration,
          'maxAngle': ik.maxAngle,
          'links': ik.links,
        };

        switch (data.metadata.format) {
          case 'pmd':
            for (var j = 0, jl = ik.links.length; j < jl; j++) {
              final links = {};

              links['index'] = ik.links[j].index;
              links['enabled'] = true;

              if (data.bones[links['index']].name.indexOf('ひざ') >= 0) {
                links['limitation'] = Vector3(1.0, 0.0, 0.0);
              }

              params['links'].add(links);
            }

            _iks.add(params);
            break;

          case "pmx":
            for (var j = 0, jl = ik.links.length; j < jl; j++) {
              final links = {};

              links['index'] = ik.links[j].index;
              links['enabled'] = true;

              if (ik.links[j].angleLimitation == 1) {
                final rotationMin = ik.links[j].lowerLimitationAngle;
                final rotationMax = ik.links[j].upperLimitationAngle;

                // convert to left to right coordinate system to be consistent
                // with MMDParser.
                var tmp1 = -rotationMin[0];
                var tmp2 = -rotationMax[0];
                rotationMax[0] = -rotationMin[0];
                rotationMax[1] = -rotationMin[1];
                rotationMin[0] = tmp1;
                rotationMin[1] = tmp2;

                links['rotiationMin'] = Vector3.array(rotationMin);
                links['rotiationMax'] = Vector3.array(rotationMax);
              }

              params['links'].add(links);
            }
            break;
        }

        _iks.add(params);

        // save the reference from bone data for efficient access
        bones[i].ik = params;
      }
    }

    // build the grants
    if (data.metadata.format == "pmx") {
      final grantEntryMap = {};

      for (var i = 0; i < data.metadata.boneCount; i++) {
        final bData = data.bones[i];
        final bGrant = bData.grant;

        // skip if the bone does not have grant
        if (bGrant == null) continue;

        final param = {
          'index': i,
          'parentIndex': bGrant.parentIndex,
          'ratio': bGrant.ratio,
          'isLocal': bGrant.isLocal,
          'affectRotation': bGrant.affectRotation,
          'affectPosition': bGrant.affectPosition,
          'transformationClass': bGrant.transformationClass
        };

        grantEntryMap[i] = {
          'parent': null,
          'param': param,
          'children': [],
          'visited': false
        };
      }

      final rootEntry = {
        'parent': null,
        'param': null,
        'children': [],
        'visited': false
      };

      // build a tree representing the hierarchy of the grant bones
      for (var boneIndex in grantEntryMap.values) {
        final grantEntry = grantEntryMap[boneIndex];
        final parentEntry = grantEntryMap[grantEntry.param.parentIndex]
            ? grantEntryMap[grantEntry.param.parentIndex]
            : rootEntry;

        grantEntry['parent'] = parentEntry;
        parentEntry['children'].add(grantEntry);
      }

      _traverse(rootEntry);
    }

    for (var i = 0; i < data.metadata.morphCount; i++) {
      final morph = data.morphs[i];
      final params = {'name': morph.name};
      // Float32Attribute in threejs is just a Float32Array which accept
      // an array, itemSize, and normalized as arguments.
      // we don't need to implement this in Dart.
      // so instead of creating a Float32Attribute, we just create a List<double>
      final attribute = List<double>.filled(data.metadata.vertexCount * 3, 0.0);

      for (var j = 0; j < data.metadata.vertexCount * 3; j++) {
        attribute[j] = _positions[j];
      }

      if (data.metadata.format == "pmd") {
        if (i != 0) _updateAttributes(attribute, morph, 1.0);
      } else {
        switch (morph.type) {
          case 0: // group morph
            for (var j = 0; j < morph.elementCount; j++) {
              final morph2 = data.morphs[morph.elements[j].index];
              final ratio = morph.elements[j].ratio;

              if (morph2.type == 1) {
                _updateAttributes(attribute, morph2, ratio);
              } else {
                // TODO: implement other morph types
                throw UnimplementedError(
                    "Morph type ${morph2.type} is not implemented.");
              }
            }
            break;
          case 1: // vertex morph
            _updateAttributes(attribute, morph, 1.0);
            break;
          case 2: // bone morph
          case 3: // uv morph
          case 4: // additional uv1 morph
          case 5: // additional uv2 morph
          case 6: // additional uv3 morph
          case 7: // additional uv4 morph
          case 8: // material morph
            throw UnimplementedError(
                "Morph type ${morph.type} is not implemented.");
          default:
            throw UnimplementedError("Unknown morph type ${morph.type}.");
        }
      }

      _morphTargets.add(params);
      _morphPositions.add(attribute);
    }
  }

  /// Traverses the given [entry] and performs certain operations.
  ///
  /// This method is used to traverse a dynamic [entry] and perform operations
  /// based on its properties. It adds the [entry.param] to the [_grants] list
  /// and saves the reference from bone data for efficient access. It also marks
  /// the [entry] as visited to avoid duplicate traversals. Finally, it recursively
  /// traverses the children of the [entry] if they have not been visited yet.
  ///
  /// Parameters:
  /// - [entry]: The dynamic entry to traverse.
  void _traverse(dynamic entry) {
    if (entry.param) {
      _grants.add(entry.param);

      // save the reference from bone data for efficient access
      bones[entry.index].grant = entry.param;
    }

    entry.visited = true;

    for (var i = 0, il = entry.children.length; i < il; i++) {
      if (!entry.children[i].visited) {
        _traverse(entry.children[i]);
      }
    }
  }

  void _updateAttributes(dynamic attribute, dynamic morph, double ratio) {
    for (var i = 0; i < morph.elementCount; i++) {
      final element = morph.elements[i];
      var idx;

      if (_data.metadata.format == "pmd") {
        idx = _data.morphs[0].elements[i].index;
      } else {
        idx = element.index;
      }

      attribute.array[idx * 3 + 0] += element.position[0] * ratio;
      attribute.array[idx * 3 + 1] += element.position[1] * ratio;
      attribute.array[idx * 3 + 2] += element.position[2] * ratio;
    }
  }
}
