// encased in ice: pale blue, with frost glinting
void main(void)
{
  vec4 c = sprite();
  float l = dot(c.rgb, LUMA);
  vec3 ice = vec3(0.6, 0.84, 1.0) * (0.45 + 0.75 * l);
  vec3 col = mix(c.rgb, ice, 0.6) + vec3(0.85, 0.95, 1.0) * sparkles(2.0, 0.05, 3.0) * 0.6;
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
