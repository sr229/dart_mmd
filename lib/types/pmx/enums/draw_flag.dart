enum PMXDrawFlag {
  drawDoubleFace(1),
  drawGroundShadow(2),
  castSelfShadow(4),
  drawSelfShadow(8),
  drawEdge(16);

  const PMXDrawFlag(this.value);
  final num value;
}