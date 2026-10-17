void main(void)
{
  vec4 game = texture2D(u_Tex0, v_TexCoord);
  vec2 p = world();
  float drift = fbm(p * 2.5 + vec2(u_Time * 0.025, u_Time * 0.008));
  float wisps = fbm(p * 5.0 - vec2(u_Time * 0.04, 0.0));
  float amount = (0.28 + 0.32 * drift + 0.12 * wisps) * strength;
  vec3 col = mix(game.rgb, vec3(0.8, 0.82, 0.86), clamp(amount, 0.0, 0.75));
  gl_FragColor = vec4(col, 1.0);
}
