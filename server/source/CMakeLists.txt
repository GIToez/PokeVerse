cmake_minimum_required(VERSION 3.16)
project(pokeverse-server CXX)

# Reproduces the original Dev-C++ build (dev-cpp/Makefile.win). One codebase for Linux (GCC)
# and Windows (MinGW-w64 / MSYS2 UCRT64); see docs/BUILD_SERVER_LINUX.md and
# docs/BUILD_SERVER_WINDOWS.md. __EXCEPTION_TRACER__ is not enabled.
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS ON)

file(GLOB SERVER_SOURCES CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
list(REMOVE_ITEM SERVER_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/databaseodbc.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/databasepgsql.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/protocolhttp.cpp)

add_executable(pokeverse-server ${SERVER_SOURCES})

target_compile_definitions(pokeverse-server PRIVATE
  __USE_MYSQL__ __USE_SQLITE__ __ENABLE_SERVER_DIAGNOSTIC__ __EMERGENCY_SAVE__ __CONSOLE__
  __ROOT_PERMISSION__ _THREAD_SAFE _REENTRANT)
target_compile_options(pokeverse-server PRIVATE -fpermissive -Wno-deprecated-declarations)

find_package(Boost REQUIRED COMPONENTS filesystem thread)
# Boost.System (1.89+) and Boost.Regex are header-only in newer Boost and may ship no library.
set(BOOST_OPTIONAL_LIBS)
foreach(component system regex)
  find_package(Boost QUIET COMPONENTS ${component})
  if(TARGET Boost::${component})
    list(APPEND BOOST_OPTIONAL_LIBS Boost::${component})
  endif()
endforeach()
find_package(LibXml2 REQUIRED)
find_package(Threads REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_search_module(LUA REQUIRED lua5.1 lua-5.1 lua51)
pkg_check_modules(MARIADB REQUIRED libmariadb)
pkg_check_modules(SQLITE REQUIRED sqlite3)
find_library(GMP_LIBRARY gmp REQUIRED)

target_include_directories(pokeverse-server PRIVATE
  ${LUA_INCLUDE_DIRS} ${MARIADB_INCLUDE_DIRS} ${SQLITE_INCLUDE_DIRS})
target_link_libraries(pokeverse-server PRIVATE
  Boost::filesystem Boost::thread ${BOOST_OPTIONAL_LIBS}
  LibXml2::LibXml2 OpenSSL::Crypto Threads::Threads
  ${LUA_LIBRARIES} ${MARIADB_LIBRARIES} ${SQLITE_LIBRARIES} ${GMP_LIBRARY})
target_link_directories(pokeverse-server PRIVATE
  ${LUA_LIBRARY_DIRS} ${MARIADB_LIBRARY_DIRS} ${SQLITE_LIBRARY_DIRS})

# Fail the build on Boost APIs that newer Boost (1.87+, as shipped by MSYS2) has removed.
target_compile_definitions(pokeverse-server PRIVATE BOOST_ASIO_NO_DEPRECATED BOOST_FILESYSTEM_NO_DEPRECATED
  BOOST_BIND_GLOBAL_PLACEHOLDERS)

if(WIN32)
  target_compile_definitions(pokeverse-server PRIVATE WIN32_LEAN_AND_MEAN)
  target_link_libraries(pokeverse-server PRIVATE ws2_32 mswsock)
endif()
