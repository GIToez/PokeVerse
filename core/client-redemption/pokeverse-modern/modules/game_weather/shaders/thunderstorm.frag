void main(void)
{
  vec4 game = gameColor();
  vec2 p = world();
  p.x += p.y * 0.12;
  float rain = rainLayer(p, 80.0, 2.3, 0.14, 1.0);
  rain += rainLayer(p * 1.3 + 0.37, 110.0, 2.6, 0.11, 2.0) * 0.85;
  rain += rainLayer(p * 1.7 + 0.71, 150.0, 2.9, 0.09, 3.0) * 0.7 * strength;
  float clouds = fbm(p * 2.0 + vec2(u_Time * 0.05, 0.0));
  vec3 col = game.rgb * mix(1.0, 0.8 + 0.12 * clouds, strength) + vec3(0.7, 0.78, 0.92) * rain * 0.62 * strength;
  gl_FragColor = vec4(col, 1.0);
}
