uniform float u_Time;
uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;
uniform vec2 u_WalkOffset;

// STRENGTH (1 full, 0.5 light) and FALL (the sign that makes things fall down the screen) are filled in by weather.lua
const float strength = STRENGTH;
const float fall = FALL;

float hash(vec2 p)
{
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p)
{
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p)
{
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p *= 2.03;
    a *= 0.5;
  }
  return v;
}

// the map in world terms: it moves with the map when the player walks
vec2 world()
{
  return (v_TexCoord + u_WalkOffset) * vec2(1.4, 1.0);
}

// rain: one streak per column, columns at random speeds
float rainLayer(vec2 p, float columns, float speed, float len, float seed)
{
  p.x += p.y * 0.22;
  float column = floor(p.x * columns);
  float h = hash(vec2(column, seed));
  float y = fract(p.y * 1.6 - fall * u_Time * speed * (0.8 + 0.4 * h) + h * 7.0);
  float x = fract(p.x * columns) - 0.5;
  return smoothstep(0.14, 0.0, abs(x)) * smoothstep(len, 0.0, y) * smoothstep(0.0, 0.015, y) * step(0.3, h);
}

// snow and hail: one flake in some cells, swaying as it falls
float flakeLayer(vec2 p, float scale, float speed, float size, float sway, float seed)
{
  p *= scale;
  p.y -= fall * u_Time * speed;
  p.x += sin(p.y * 0.9 + u_Time * 0.8 + seed) * sway;
  vec2 cell = floor(p);
  vec2 f = fract(p) - 0.5;
  float h = hash(cell + seed);
  vec2 o = (vec2(hash(cell + 1.7 + seed), hash(cell + 4.3 + seed)) - 0.5) * 0.6;
  return smoothstep(size, size * 0.35, length(f - o)) * step(0.45, h);
}
