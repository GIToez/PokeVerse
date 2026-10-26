// the cocoon of a Mega Evolution (game_megafx) and its flash when it ends: the Pokemon is a bright
// white shape with rainbow light running through it
vec3 hue(float h)
{
  return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

void main(void)
{
  vec4 c = sprite();
  float d = (gl_FragCoord.x + gl_FragCoord.y) / 60.0;
  vec3 rainbow = hue(fract(d - u_Time * 1.5));
  float wave = 0.5 + 0.5 * sin(u_Time * 18.0 + d * 6.0);
  vec3 col = mix(vec3(1.0, 0.99, 0.95), rainbow, 0.18 + 0.14 * wave);
  gl_FragColor = vec4(col, c.a * u_Opacity);
}
