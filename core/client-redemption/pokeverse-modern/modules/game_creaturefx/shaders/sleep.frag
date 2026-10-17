// greyed and dimmed, slowly breathing
void main(void)
{
  vec4 c = sprite();
  float l = dot(c.rgb, LUMA);
  vec3 col = mix(c.rgb, vec3(l) * vec3(0.9, 0.92, 1.05), 0.45) * (0.72 + 0.16 * pulse(3.2));
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
