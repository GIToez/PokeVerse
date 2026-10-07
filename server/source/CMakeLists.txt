cmake_minimum_required(VERSION 3.16)
project(pokeverse-server CXX)

# Reproduces the original Dev-C++ build (dev-cpp/Makefile.win) on Linux.
# __EXCEPTION_TRACER__ is MinGW-only and is not enabled.
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

find_package(Boost REQUIRED COMPONENTS system filesystem thread regex)
find_package(LibXml2 REQUIRED)
find_package(Threads REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(LUA REQUIRED lua5.1)
pkg_check_modules(MARIADB REQUIRED libmariadb)
pkg_check_modules(SQLITE REQUIRED sqlite3)
find_library(GMP_LIBRARY gmp REQUIRED)

target_include_directories(pokeverse-server PRIVATE
  ${LUA_INCLUDE_DIRS} ${MARIADB_INCLUDE_DIRS} ${SQLITE_INCLUDE_DIRS})
target_link_libraries(pokeverse-server PRIVATE
  Boost::system Boost::filesystem Boost::thread Boost::regex
  LibXml2::LibXml2 OpenSSL::Crypto Threads::Threads
  ${LUA_LIBRARIES} ${MARIADB_LIBRARIES} ${SQLITE_LIBRARIES} ${GMP_LIBRARY})
