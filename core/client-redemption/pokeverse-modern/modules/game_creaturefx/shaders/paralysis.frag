// a faint yellow, with sudden crackles of electricity
void main(void)
{
  vec4 c = sprite();
  float slot = floor(u_Time * 9.0 + phase * 9.0);
  float crackle = step(0.7, hash(vec2(slot, 3.7)));
  float zigzag = abs(fract(gl_FragCoord.y / 14.0) - 0.5) * 10.0;
  float bolt = 1.0 - smoothstep(0.0, 1.6, abs(mod(gl_FragCoord.x + zigzag + slot * 17.0, 22.0) - 11.0));
  vec3 col = mix(c.rgb, vec3(1.0, 0.92, 0.25) * (0.6 + dot(c.rgb, LUMA)), 0.15 + 0.3 * crackle);
  col += vec3(1.0, 0.95, 0.5) * bolt * crackle * 0.6;
  gl_FragColor = vec4(min(col, vec3(1.0)), c.a * u_Opacity);
}
