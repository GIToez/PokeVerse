cmake_minimum_required(VERSION 3.16)
project(pokeverse-server CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()

find_package(Boost REQUIRED COMPONENTS system filesystem thread regex)
find_package(LibXml2 REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Threads REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_search_module(LUA REQUIRED lua5.1 lua-5.1 lua51)
pkg_search_module(GMP REQUIRED gmp)
pkg_search_module(SQLITE REQUIRED sqlite3)
pkg_search_module(MARIADB REQUIRED libmariadb mariadb)

file(GLOB SERVER_SOURCES CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
list(FILTER SERVER_SOURCES EXCLUDE REGEX "/(databaseodbc|databasepgsql|protocolhttp)\\.cpp$")
if(WIN32)
  list(APPEND SERVER_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/pokeverse-server.rc)
endif()

add_executable(pokeverse-server ${SERVER_SOURCES})

# Same feature set as the original Windows build (dev-cpp/Makefile.win).
target_compile_definitions(pokeverse-server PRIVATE
  __USE_MYSQL__ __MYSQL_ALT_INCLUDE__ __USE_SQLITE__ __ENABLE_SERVER_DIAGNOSTIC__ __EMERGENCY_SAVE__
  BOOST_BIND_GLOBAL_PLACEHOLDERS BOOST_ALLOW_DEPRECATED_HEADERS BOOST_TIMER_ENABLE_DEPRECATED)
if(WIN32)
  target_compile_definitions(pokeverse-server PRIVATE __CONSOLE__ WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0601)
else()
  target_compile_definitions(pokeverse-server PRIVATE _THREAD_SAFE _REENTRANT)
endif()

target_compile_options(pokeverse-server PRIVATE -w -fpermissive)

target_include_directories(pokeverse-server PRIVATE
  ${LUA_INCLUDE_DIRS} ${GMP_INCLUDE_DIRS} ${SQLITE_INCLUDE_DIRS} ${MARIADB_INCLUDE_DIRS})
target_link_directories(pokeverse-server PRIVATE
  ${LUA_LIBRARY_DIRS} ${GMP_LIBRARY_DIRS} ${SQLITE_LIBRARY_DIRS} ${MARIADB_LIBRARY_DIRS})
target_link_libraries(pokeverse-server PRIVATE
  Boost::system Boost::filesystem Boost::thread Boost::regex
  LibXml2::LibXml2 OpenSSL::Crypto Threads::Threads
  ${LUA_LIBRARIES} ${GMP_LIBRARIES} ${SQLITE_LIBRARIES} ${MARIADB_LIBRARIES})
if(WIN32)
  target_link_libraries(pokeverse-server PRIVATE ws2_32 wsock32 mswsock)
endif()

install(TARGETS pokeverse-server RUNTIME DESTINATION .)
