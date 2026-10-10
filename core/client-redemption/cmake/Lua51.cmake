# PUC Lua 5.1.5 as a static library, used instead of LuaJIT when OPTIONS_USE_LUA51 is on.
# The PokeVerse modules were written against PUC Lua 5.1 (table iteration order, bit32),
# so the Redemption client runs them on the same interpreter as the legacy client.
include(FetchContent)

FetchContent_Declare(lua51
  URL https://www.lua.org/ftp/lua-5.1.5.tar.gz
  URL_HASH SHA256=2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(lua51)

file(GLOB LUA51_SOURCES "${lua51_SOURCE_DIR}/src/*.c")
list(REMOVE_ITEM LUA51_SOURCES
  "${lua51_SOURCE_DIR}/src/lua.c"
  "${lua51_SOURCE_DIR}/src/luac.c"
  "${lua51_SOURCE_DIR}/src/print.c")

add_library(lua51 STATIC ${LUA51_SOURCES})
set_target_properties(lua51 PROPERTIES LINKER_LANGUAGE C POSITION_INDEPENDENT_CODE ON)
target_include_directories(lua51 PUBLIC "${lua51_SOURCE_DIR}/src" "${lua51_SOURCE_DIR}/etc")
if(UNIX AND NOT APPLE AND NOT ANDROID AND NOT EMSCRIPTEN)
  target_compile_definitions(lua51 PRIVATE LUA_USE_POSIX LUA_USE_DLOPEN)
  target_link_libraries(lua51 PRIVATE ${CMAKE_DL_LIBS})
elseif(APPLE)
  target_compile_definitions(lua51 PRIVATE LUA_USE_MACOSX)
endif()

set(LUAJIT_INCLUDE_DIR "${lua51_SOURCE_DIR}/src;${lua51_SOURCE_DIR}/etc")
set(LUAJIT_LIBRARY lua51)
set(LUA_LIBRARY lua51)
