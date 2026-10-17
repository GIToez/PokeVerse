void main(void)
{
  vec4 game = texture2D(u_Tex0, v_TexCoord);
  vec2 p = world();
  float lines = 0.0;
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    vec2 q = vec2(p.x * (7.0 + fi * 2.0) - u_Time * (4.0 + fi), p.y * (55.0 + fi * 20.0) + fi * 3.1);
    float streak = smoothstep(0.82, 0.97, noise(q));
    float gust = smoothstep(0.5, 0.75, noise(vec2(p.x * 1.6 - u_Time * 2.2, p.y * 9.0 + fi * 5.0)));
    lines += streak * gust * (1.0 - fi * 0.25);
  }
  float sway = fbm(p * 3.0 - vec2(u_Time * 0.3, 0.0));
  vec3 col = game.rgb * (1.0 - 0.05 * strength * sway) + vec3(0.92, 0.96, 1.0) * lines * 0.35 * strength;
  gl_FragColor = vec4(col, 1.0);
}
