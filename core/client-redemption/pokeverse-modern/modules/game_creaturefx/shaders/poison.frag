// a sickly purple that swells and fades
void main(void)
{
  vec4 c = sprite();
  float p = pulse(1.8);
  vec3 col = mix(c.rgb, vec3(0.62, 0.22, 0.85) * (0.45 + dot(c.rgb, LUMA)), 0.2 + 0.35 * p * p);
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
