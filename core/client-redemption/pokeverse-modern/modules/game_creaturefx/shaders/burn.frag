// orange heat rising through the Pokemon, flickering like a flame
void main(void)
{
  vec4 c = sprite();
  float rise = 0.5 + 0.5 * sin(gl_FragCoord.y * 0.3 - u_Time * 7.0 + phase * TAU);
  float flicker = 0.75 + 0.25 * hash(vec2(floor(u_Time * 12.0), phase));
  float heat = (0.25 + 0.25 * rise) * flicker;
  vec3 col = mix(c.rgb, vec3(1.0, 0.42, 0.08) * (0.55 + dot(c.rgb, LUMA)), heat);
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
