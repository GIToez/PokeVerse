void main(void)
{
  vec4 game = gameColor();
  vec2 p = world();
  float rain = rainLayer(p, 70.0, 1.6, 0.10, 1.0);
  rain += rainLayer(p * 1.3 + 0.37, 95.0, 1.9, 0.08, 2.0) * 0.8;
  rain += rainLayer(p * 1.7 + 0.71, 130.0, 2.2, 0.06, 3.0) * 0.6 * strength;
  vec3 col = game.rgb * mix(1.0, 0.9, strength) + vec3(0.72, 0.8, 0.95) * rain * 0.6 * strength;
  gl_FragColor = vec4(col, 1.0);
}
