void main(void)
{
  vec4 game = gameColor();
  vec2 p = world();
  float dust = fbm(vec2(p.x * 2.2 - u_Time * 0.45, p.y * 5.0 + sin(p.x * 3.0 + u_Time) * 0.2));
  float gusts = fbm(vec2(p.x * 6.0 - u_Time * 1.2, p.y * 14.0));
  vec2 blown = vec2(p.x - u_Time * 0.9, p.y + sin(p.x * 4.0 + u_Time) * 0.03);
  float grains = flakeLayer(blown, 30.0, 0.0, 0.05, 0.1, 2.0) + flakeLayer(blown * 1.4 + 0.3, 30.0, 0.0, 0.04, 0.1, 7.0);
  float amount = (0.26 + 0.28 * dust + 0.14 * gusts) * strength;
  vec3 col = mix(game.rgb, vec3(0.86, 0.69, 0.44), clamp(amount, 0.0, 0.65)) + vec3(0.6, 0.45, 0.25) * grains * 0.5 * strength;
  gl_FragColor = vec4(col, 1.0);
}
