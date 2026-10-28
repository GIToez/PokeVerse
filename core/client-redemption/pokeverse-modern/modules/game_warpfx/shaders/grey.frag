// a defeated trainer, grey and a little dark
uniform sampler2D u_Tex0;
uniform vec4 u_Color;
uniform float u_Opacity;
varying vec2 v_TexCoord;

void main(void)
{
  vec4 c = texture2D(u_Tex0, v_TexCoord) * u_Color;
  float l = dot(c.rgb, vec3(0.299, 0.587, 0.114));
  gl_FragColor = vec4(mix(c.rgb, vec3(l) * vec3(0.78, 0.8, 0.9), 0.85), c.a * u_Opacity);
}
