// the trainer on the map while a copy of them plays the warp
uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;

void main(void)
{
  gl_FragColor = vec4(texture2D(u_Tex0, v_TexCoord).rgb, 0.0);
}
