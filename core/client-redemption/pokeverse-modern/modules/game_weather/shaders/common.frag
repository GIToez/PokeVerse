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
// brightness outside it, MAPW x MAPH the tiles in the map texture
const float mood = MOOD;
const float haze = HAZE;
const float radius = RADIUS;
const float caveFloor = CAVEFLOOR;
const vec2 mapTiles = vec2(MAPW, MAPH);
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
  vec3 c = styled(game.rgb);
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
