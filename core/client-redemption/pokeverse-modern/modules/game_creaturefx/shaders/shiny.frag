// a warm sheen that breathes, a glint that sweeps across the Pokemon every couple of seconds and
// pixels that twinkle; strong enough to read on a phone screen and under fog or haze
void main(void)
{
  vec4 c = sprite();
  // often enough that a shiny coming out of its ball glints within a moment
  float t = fract(u_Time / 1.4 + phase);
  float sweep = t / 0.35;
  float d = (gl_FragCoord.x + gl_FragCoord.y) / 90.0;
  float band = (1.0 - smoothstep(0.0, 0.16, abs(fract(d - sweep) - 0.5))) * step(t, 0.35);
  float glint = band * 0.9 + sparkles(4.0, 0.12, 6.0);
  float sheen = 0.12 + 0.14 * pulse(1.8);
  vec3 col = mix(c.rgb, vec3(1.0, 0.92, 0.6), sheen) * 1.08 + vec3(1.0, 0.97, 0.85) * glint;
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
