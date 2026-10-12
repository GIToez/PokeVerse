uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;

void main()
{
  vec4 col = texture2D(u_Tex0, v_TexCoord);
  gl_FragColor = vec4(1.0, 1.0, 1.0, col.a);
}
