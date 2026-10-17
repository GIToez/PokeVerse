void main(void)
{
  vec4 game = texture2D(u_Tex0, v_TexCoord);
  vec2 p = world();
  float snow = flakeLayer(p, 9.0, 0.35, 0.09, 0.35, 0.0);
  snow += flakeLayer(p + 0.31, 14.0, 0.28, 0.08, 0.3, 5.0) * 0.8;
  snow += flakeLayer(p + 0.67, 22.0, 0.22, 0.07, 0.25, 9.0) * 0.6 * strength;
  vec3 col = mix(game.rgb, vec3(0.92, 0.96, 1.0), 0.06 * strength) + vec3(1.0) * snow * 0.75 * strength;
  gl_FragColor = vec4(col, 1.0);
}
