void main(void)
{
  vec4 game = texture2D(u_Tex0, v_TexCoord);
  vec2 p = world();
  float rays = pow(max(0.0, sin((p.x * 0.8 + p.y) * 7.0 + u_Time * 0.25)), 10.0);
  rays *= 0.5 + 0.5 * noise(vec2(p.x * 3.0 + u_Time * 0.1, p.y * 3.0));
  float glow = smoothstep(0.9, 0.0, length(v_TexCoord - vec2(0.0, 0.0))) * 0.06;
  vec3 warm = game.rgb * mix(vec3(1.0), vec3(1.05, 1.02, 0.95), strength);
  vec3 col = warm + vec3(1.0, 0.9, 0.6) * (rays * 0.07 + glow) * strength;
  gl_FragColor = vec4(col, 1.0);
}
