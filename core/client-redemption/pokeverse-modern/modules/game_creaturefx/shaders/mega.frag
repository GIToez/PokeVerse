// a Mega Evolved Pokemon: a faint rainbow light that drifts across it, a soft breathing glow and a
// few twinkles, so everyone around can tell it is Mega; quieter than the shiny shimmer
vec3 hue(float h)
{
  return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

void main(void)
{
  vec4 c = sprite();
  float d = (gl_FragCoord.x - gl_FragCoord.y) / 140.0;
  vec3 rainbow = hue(fract(d + u_Time / 3.0 + phase));
  float glow = 0.13 + 0.09 * pulse(2.2);
  vec3 col = mix(c.rgb, rainbow, glow) * 1.06 + vec3(1.0) * sparkles(4.0, 0.06, 5.0) * 0.8;
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
