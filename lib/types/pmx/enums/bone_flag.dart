enum PMXBoneFlag {
  childUseID(1),
  rotatable(2),
  movable(3),
  visible(8),
  controllable(16),
  hasIK(32),
  acquireRotate(256),
  acquireTranslate(512),
  rotAxisFixed(1024),
  useLocalAxis(2048),
  postPhysics(4096),
  recieveTransform(8192);

  const PMXBoneFlag(this.value);
  final num value;
}