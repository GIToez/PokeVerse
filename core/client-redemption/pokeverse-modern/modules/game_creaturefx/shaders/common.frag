uniform float u_Time;
uniform sampler2D u_Tex0;
uniform vec4 u_Color;
uniform float u_Opacity;
varying vec2 v_TexCoord;

// PHASE (0 to 1) is filled in by creaturefx.lua: each copy of an effect runs at its own point in
// the cycle, so Pokemon side by side don't pulse together
const float phase = PHASE;
const vec3 LUMA = vec3(0.299, 0.587, 0.114);
const float TAU = 6.2831853;

float hash(vec2 p)
{
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

vec4 sprite()
{
  return texture2D(u_Tex0, v_TexCoord) * u_Color;
}

// 0 to 1 and back, once every period seconds
float pulse(float period)
{
  return 0.5 + 0.5 * sin(TAU * (u_Time / period + phase));
}

// a few pixels of the sprite twinkle white; cell is their size in screen pixels
float sparkles(float cell, float density, float speed)
{
  vec2 c = floor(gl_FragCoord.xy / cell);
  float h = hash(c);
  float twinkle = max(0.0, sin(u_Time * speed + h * 40.0 + phase * TAU));
  return step(1.0 - density, h) * pow(twinkle, 4.0);
}
