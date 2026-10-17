// the colours wobble round the colour wheel
void main(void)
{
  vec4 c = sprite();
  float angle = sin(TAU * (u_Time / 1.6 + phase)) * 0.9;
  // hue rotation in YIQ
  float y = dot(c.rgb, vec3(0.299, 0.587, 0.114));
  float i = dot(c.rgb, vec3(0.596, -0.274, -0.322));
  float q = dot(c.rgb, vec3(0.211, -0.523, 0.312));
  float ci = cos(angle), si = sin(angle);
  vec2 iq = vec2(i * ci - q * si, i * si + q * ci);
  vec3 col = vec3(y + 0.956 * iq.x + 0.621 * iq.y, y - 0.272 * iq.x - 0.647 * iq.y, y - 1.106 * iq.x + 1.703 * iq.y);
  gl_FragColor = vec4(clamp(col, 0.0, 1.0), c.a * u_Opacity);
}
