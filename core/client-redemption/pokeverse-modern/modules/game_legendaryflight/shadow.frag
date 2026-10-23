uniform sampler2D u_Tex0;
uniform vec4 u_Color;
uniform float u_Opacity;
varying vec2 v_TexCoord;

// the sprite as a dark, see-through shape: a flyer's shadow on the ground, Lugia under the water
void main(void)
{
  float a = texture2D(u_Tex0, v_TexCoord).a * u_Color.a;
  gl_FragColor = vec4(0.03, 0.04, 0.08, a * ALPHA * u_Opacity);
}
