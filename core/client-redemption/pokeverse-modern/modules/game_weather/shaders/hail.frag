void main(void)
{
  vec4 game = gameColor();
  vec2 p = world();
  p.x += p.y * 0.1;
  float hail = flakeLayer(p, 14.0, 1.6, 0.085, 0.05, 0.0);
  hail += flakeLayer(p + 0.41, 20.0, 1.9, 0.07, 0.05, 3.0) * 0.85;
  hail += flakeLayer(p + 0.77, 28.0, 2.2, 0.06, 0.05, 6.0) * 0.7 * strength;
  float streak = rainLayer(p, 60.0, 2.0, 0.06, 4.0);
  vec3 col = mix(game.rgb, vec3(0.78, 0.86, 0.95), 0.12 * strength) + vec3(0.88, 0.95, 1.0) * (hail + streak * 0.35) * strength;
  gl_FragColor = vec4(col, 1.0);
}
