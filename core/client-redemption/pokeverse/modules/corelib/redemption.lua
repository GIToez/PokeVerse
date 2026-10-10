-- Legacy engine APIs used by the PokeVerse modules, mapped onto the Redemption engine.
-- Every entry is listed in docs/phase3-redemption.md.

-- Redemption rejects protocol versions above this (its own gamelib sets it from its client list).
g_gameConfig.setLastSupportedVersion(854)

-- Redemption added LogTrace = 0 in front of the log levels.
LogDebug = 1
LogInfo = 2
LogWarning = 3
LogError = 4
LogFatal = 5

-- Redemption has a single OpenGL 2 painter with shaders always on.
g_graphics.isPainterEngineAvailable = function(engine) return engine == 2 end
g_graphics.getPainterEngine = function() return 2 end
g_graphics.selectPainterEngine = function(engine) return engine == 2 end
g_graphics.canCacheBackbuffer = function() return true end
g_graphics.canUseShaders = function() return true end
g_graphics.shouldUseShaders = function() return true end
g_graphics.setShouldUseShaders = function(enable) end

-- The map and the interface share one frame limit; the game limit drives it (0 = unlimited).
local backgroundMaxFps = 0
g_app.setBackgroundPaneMaxFps = function(fps)
  backgroundMaxFps = fps
  g_app.setMaxFps(fps)
end
g_app.getBackgroundPaneMaxFps = function() return backgroundMaxFps end
g_app.setForegroundPaneMaxFps = function(fps) end
g_app.getForegroundPaneMaxFps = function() return 0 end
g_app.getBackgroundPaneFps = function() return g_app.getFps() end
g_app.getForegroundPaneFps = function() return g_app.getFps() end

getOufitColor = getOutfitColor

-- Shaders are created asynchronously on the render thread and referenced by name.
local mapShaderNames = {}

g_shaders.createMapShader = function(name, file)
  g_shaders.createFragmentShader(name, file, false)
  g_shaders.setupMapShader(name)
  mapShaderNames[name] = true
  return {
    addMultiTexture = function(self, texture) g_shaders.addMultiTexture(name, texture) end
  }
end

local function mapShaderName(shader)
  if shader == nil then return '' end
  if type(shader) == 'string' then return shader end
  for name in pairs(mapShaderNames) do
    if g_shaders.getShader(name) == shader then return name end
  end
  return ''
end

function UIMap:setMapShader(shader, fadein, fadeout)
  self:setShader(mapShaderName(shader), fadein or 0, fadeout or 0)
end

function UIMap:getMapShader()
  return self:getShader()
end

function UIMap:setDrawTexts(enable)
  g_app.setDrawTexts(enable)
end

function UIMap:isDrawingTexts()
  return g_app.isDrawingTexts()
end
