// the fainting flash: the sprite's shape in white
uniform sampler2D u_Tex0;
uniform vec4 u_Color;
uniform float u_Opacity;
varying vec2 v_TexCoord;

void main(void)
{
  vec4 c = texture2D(u_Tex0, v_TexCoord) * u_Color;
  gl_FragColor = vec4(mix(c.rgb, vec3(1.0), 0.85), c.a * u_Opacity);
}
