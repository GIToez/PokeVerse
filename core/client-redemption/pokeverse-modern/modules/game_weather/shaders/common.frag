uniform float u_Time;
uniform sampler2D u_Tex0;
varying vec2 v_TexCoord;
uniform vec2 u_WalkOffset;
uniform vec2 u_MapCenterCoord; // where the trainer stands

// STRENGTH (1 full, 0.5 light), FALL (the sign that makes things fall down the screen) and STYLE
// (0 off, 1 vibrant, 2 toon) are filled in by weather.lua
const float strength = STRENGTH;
const float fall = FALL;
const float style = STYLE;
// MOOD (0 none, 1 Lavender haze, 2 dark cave) and its settings are filled in by weather.lua too: HAZE is
// how thick the haze is (thinner under weather), RADIUS the lit circle in tiles, CAVEFLOOR the
// brightness outside it, MAPW x MAPH the tiles in the map texture (also set for toon's outlines)
const float mood = MOOD;
const float haze = HAZE;
const float radius = RADIUS;
const float caveFloor = CAVEFLOOR;
const vec2 mapTiles = vec2(MAPW, MAPH);
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

// toon, in the look of the anime: flat clean fills (the sprite's speckle smoothed away inside a
// shape, its edges kept), bright saturated colour, soft cel shading in three tones, a little
// shine on the brightest parts and ink lines on the outlines in a dark shade of the colour
vec3 toon(vec3 c, vec2 uv)
{
  // one sprite pixel of the map texture (mapTiles is the texture in tiles of 32 pixels)
  vec2 px = 1.0 / (mapTiles * 32.0);
  float l0 = dot(c, LUMA);
  vec3 sum = c;
  float weight = 1.0;
  float n[9];
  for (int i = 0; i < 9; i++) {
    vec2 o = vec2(float(i - (i / 3) * 3) - 1.0, float(i / 3) - 1.0);
    vec3 s = texture2D(u_Tex0, uv + o * px).rgb;
    float ls = dot(s, LUMA);
    n[i] = ls;
    float w = (i == 4) ? 0.0 : 1.0 - smoothstep(0.04, 0.14, abs(ls - l0));
    sum += s * w;
    weight += w;
  }
  c = sum / weight;

  float l = dot(c, LUMA);
  c = pow(clamp(mix(vec3(l), c, 1.4), 0.0, 1.0), vec3(0.88));
  l = max(dot(c, LUMA), 0.001);
  float f = l * 3.0;
  float q = (floor(f) + smoothstep(0.4, 0.6, fract(f))) / 3.0 + 0.04;
  c = clamp(c * mix(1.0, q / l, 0.55), 0.0, 1.0);
  c += (1.0 - c) * 0.12 * smoothstep(0.7, 0.95, dot(c, LUMA));

  float gx = (n[2] + 2.0 * n[5] + n[8]) - (n[0] + 2.0 * n[3] + n[6]);
  float gy = (n[6] + 2.0 * n[7] + n[8]) - (n[0] + 2.0 * n[1] + n[2]);
  float edge = smoothstep(0.38, 0.85, sqrt(gx * gx + gy * gy)) * 0.85;
  return mix(c, c * 0.3, edge);
}

// the visual style: vibrant is more colour and a little contrast; toon is above
vec3 styled(vec3 c, vec2 uv)
{
  if (style < 0.5)
    return c;
  if (style > 1.5)
    return toon(c, uv);
  float l = dot(c, LUMA);
  c = clamp(mix(vec3(l), c, 1.25), 0.0, 1.0);
  return mix(c, c * c * (3.0 - 2.0 * c), 0.3);
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

// Lavender Town: greyer and purple, with mist drifting through and the edges of the screen dimmed
vec3 lavenderHaze(vec3 c)
{
  float l = dot(c, LUMA);
  c = mix(c, vec3(l), 0.6 * haze);
  c = mix(c, c * vec3(0.84, 0.7, 1.12), haze);
  c = mix(c, vec3(0.42, 0.36, 0.52), 0.12 * haze);
  float mist = fbm(world() * 2.5 + vec2(u_Time * 0.03, -u_Time * 0.015));
  c = mix(c, vec3(0.62, 0.52, 0.8), 0.32 * haze * smoothstep(0.35, 0.8, mist));
  vec2 v = (v_TexCoord - u_MapCenterCoord) * vec2(1.0, 0.75);
  return c * (1.0 - 0.35 * haze * smoothstep(0.2, 0.6, length(v)));
}

// a cave: dark but for a softly flickering circle of light around the trainer
vec3 caveDark(vec3 c)
{
  float r = length((v_TexCoord - u_MapCenterCoord) * mapTiles) + 0.1 * sin(u_Time * 2.3) + 0.05 * sin(u_Time * 5.7);
  float light = 1.0 - smoothstep(radius * 0.45, radius, r);
  return mix(c * vec3(0.85, 0.9, 1.05) * caveFloor, c * vec3(1.04, 1.0, 0.94), light);
}

vec4 gameColor()
{
  vec4 game = texture2D(u_Tex0, v_TexCoord);
  vec3 c = styled(game.rgb, v_TexCoord);
  if (mood > 1.5)
    c = caveDark(c);
  else if (mood > 0.5)
    c = lavenderHaze(c);
  return vec4(c, game.a);
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
