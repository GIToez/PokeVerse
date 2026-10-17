uniform float u_Time;
uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;
uniform vec2 u_WalkOffset;

// STRENGTH (1 full, 0.5 light), FALL (the sign that makes things fall down the screen) and STYLE
// (0 off, 1 vibrant, 2 toon) are filled in by weather.lua
const float strength = STRENGTH;
const float fall = FALL;
const float style = STYLE;
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

// the visual style: vibrant is more colour and a little contrast; toon also pulls the shades
// toward a few steps of brightness, keeping each colour's hue
vec3 styled(vec3 c)
{
  if (style < 0.5)
    return c;
  float l = dot(c, LUMA);
  c = clamp(mix(vec3(l), c, style > 1.5 ? 1.3 : 1.25), 0.0, 1.0);
  c = mix(c, c * c * (3.0 - 2.0 * c), 0.3);
  if (style > 1.5) {
    l = max(dot(c, LUMA), 0.001);
    float bands = 6.0;
    float f = l * bands;
    // a soft staircase: flat steps with smooth risers, so textures that sit on a step's edge don't blotch
    float q = (floor(f) + smoothstep(0.25, 0.75, fract(f))) / bands;
    c = clamp(c * mix(1.0, q / l, 0.7), 0.0, 1.0);
  }
  return c;
}

vec4 gameColor()
{
  vec4 game = texture2D(u_Tex0, v_TexCoord);
  return vec4(styled(game.rgb), game.a);
}

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
  return (1.0 - smoothstep(0.0, 0.14, abs(x))) * (1.0 - smoothstep(0.0, len, y)) * smoothstep(0.0, 0.015, y) * step(0.3, h);
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
  return (1.0 - smoothstep(size * 0.35, size, length(f - o))) * step(0.45, h);
}
