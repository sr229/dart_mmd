library dart_mmd;

import 'dart:typed_data';

import 'pmx/pmx_bone.dart';
import 'pmx/pmx_face.dart';
import 'pmx/pmx_frame.dart';
import 'pmx/pmx_joint.dart';
import 'pmx/pmx_material.dart';
import 'pmx/pmx_morph.dart';
import 'pmx/pmx_rigidbody.dart';
import 'pmx/pmx_vertex.dart';
import '../utils/buffer_reader.dart';

/// Represents a Polygon Model eXtended model.
///
/// The [PMX] class is responsible for parsing and storing the data of a PMX model file.
/// It provides methods to access and manipulate the model's vertices, faces, textures, materials, bones, morphs, frames, rigid bodies, and joints.
///
/// Example usage:
/// ```dart
/// var buffer = ...; // Provide the PMX model file buffer
/// var model = PMX(buffer, (err, data) {
///   if (err != null) {
///     // Handle error
///   } else {
///     // Access and manipulate the model data
///   }
/// });
/// ```
class PMX {
  List<dynamic> log = [];
  Map<String, dynamic> value = {};

  /// Creates a new instance of the [PMX] class.
  ///
  /// The [buffer] parameter is the byte buffer containing the PMX model data.
  /// The [callback] parameter is a function that will be called when the model data is parsed.
  /// It takes an [Error] object as the first parameter (or `null` if no error occurred) and the parsed model data as the second parameter.
  PMX(ByteBuffer buffer, Function(Error err, dynamic data) callback) {
    push(buffer.toString());

    var reader = BufferReader(buffer, 4);
    var version = reader.readFloat();
    var headerSize = reader.readByte();
    push(version);
    push(headerSize);

    var encodingID = reader.readByte();
    var encoding = encodingID == 0 ? 'utf-16le' : 'utf-8';
    push(encoding);

    var additionalUV = reader.readByte();
    push(additionalUV);

    var vertexIndexSize = reader.readByte();
    push(vertexIndexSize);

    var textureIndexSize = reader.readByte();
    push(textureIndexSize);

    var materialSize = reader.readByte();
    push(materialSize);

    var boneIndexSize = reader.readByte();
    push(boneIndexSize);

    var morphIndexSize = reader.readByte();
    push(morphIndexSize);

    reader.pushPos(17);

    var model = reader.readTextBuffer(encoding);
    var modelEnglish = reader.readTextBuffer(encoding);
    var comment = reader.readTextBuffer(encoding);
    var commentEnglish = reader.readTextBuffer(encoding);
    var vertexLength = reader.readInt();

    push("modelname", val: model);
    push("modelname_en", val: modelEnglish);
    push("comment", val: comment);
    push("comment_en", val: commentEnglish);
    push("VertexLen", val: vertexLength);

    // vertices
    var vertices = [];
    for (var i = 0; i < vertexLength; i++) {
      var vertex = PMXVertex(reader, additionalUV, boneIndexSize);
      vertices.add(vertex);
    }
    push("vertex", val: vertices);

    // faces
    var faceLength = reader.readInt();
    var faces = [];
    push("face", val: faceLength);
    for (var i = 0; i < faceLength / 3; i++) {
      var face = PMXFace(reader, vertexIndexSize);
      faces.add(face);
    }
    push("face", val: faces);

    // materials
    var materialLength = reader.readInt();
    var materials = [];
    for (var i = 0; i < materialLength; i++) {
      var material = PMXMaterial(reader, encoding, textureIndexSize);
      var m = material.value;
      materials.add(m);
    }
    push("material", val: materials);

    // bones
    var boneLength = reader.readInt();
    var bones = [];
    for (var i = 0; i < boneLength; i++) {
      var bone = PMXBone(reader, encoding, boneIndexSize);
      var b = bone.value;
      bones.add(b);
    }

    // morphs
    var morphLength = reader.readInt();
    var morphs = [];
    for (var i = 0; i < morphLength; i++) {
      var morph = PMXMorph(reader, encoding, vertexIndexSize, materialSize,
          boneIndexSize, morphIndexSize);
      var m = morph.value;
      morphs.add(m);
    }

    // frames
    var frameLength = reader.readInt();
    var frames = [];
    for (var i = 0; i < frameLength; i++) {
      var frame = PMXFrame(reader, encoding, boneIndexSize, morphIndexSize);
      var f = frame.value;
      frames.add(f);
    }

    // RigidBodies
    var rigidBodyLength = reader.readInt();
    var rigidBodies = [];
    for (var i = 0; i < rigidBodyLength; i++) {
      var rigidBody = PMXRigidBody(reader, encoding, boneIndexSize);
      var r = rigidBody.value;
      rigidBodies.add(r);
    }

    // Joints
    var jointLength = reader.readInt();
    var joints = [];
    for (var i = 0; i < jointLength; i++) {
      var joint = PMXJoint(reader, encoding);
      var j = joint.value;
      joints.add(j);
    }
  }

  void push(dynamic key, {dynamic val, bool assigned = true}) {
    if (val == null) {
      log.add(val);
    } else {
      if (assigned)  {
        value[key] = val;
      }
      log.add([key, val]);
    }
  }
}
