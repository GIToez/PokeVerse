// a glint sweeps across the Pokemon every few seconds, and a few pixels twinkle
void main(void)
{
  vec4 c = sprite();
  float t = fract(u_Time / 3.5 + phase);
  float sweep = t / 0.3;
  float d = (gl_FragCoord.x + gl_FragCoord.y) / 110.0;
  float band = (1.0 - smoothstep(0.0, 0.1, abs(fract(d - sweep) - 0.5))) * step(t, 0.3);
  float glint = band * 0.7 + sparkles(3.0, 0.06, 5.0) * 0.8;
  vec3 col = c.rgb * (1.0 + 0.06 * pulse(3.5)) + vec3(1.0, 0.97, 0.85) * glint;
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
