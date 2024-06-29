cmake_minimum_required(VERSION 3.12)
project(u_tasks_repository CXX)


###################################################################################################
# Fetch CPM if not already present
if(NOT EXISTS "${CMAKE_BINARY_DIR}/cmake/CPM.cmake")
    file(DOWNLOAD
        https://github.com/cpm-cmake/CPM.cmake/releases/latest/download/cpm.cmake
        "${CMAKE_BINARY_DIR}/cmake/CPM.cmake"
    )
endif()

# Add CPM / Include CPM
#include(cmake/CPM.cmake)
include("${CMAKE_BINARY_DIR}/cmake/CPM.cmake")

###################################################################################################
# Set Protobuf and gRPC directories
set(Protobuf_DIR "/usr/local/lib/cmake/protobuf")
set(gRPC_DIR "/usr/local/lib/cmake/grpc")

find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

include_directories(${Protobuf_INCLUDE_DIRS} ${gRPC_INCLUDE_DIRS})
message(STATUS "Using Protobuf ${Protobuf_VERSION}")


###################################################################################################
# Run userver build:
CPMAddPackage(
    NAME userver
    #VERSION (userver release version or git commit hash)
    #GIT_TAG ("v2.1")
    GIT_TAG bb713ea

    #GIT_REPOSITORY https://github.com/userver-framework/userver.git
    GITHUB_REPOSITORY userver-framework/userver
    OPTIONS
    "USERVER_FEATURE_GRPC ON"
)

# Adding userver dependency
find_package(userver COMPONENTS core postgresql QUIET)
if(NOT userver_FOUND)  # Fallback to subdirectory usage
    # Enable userver libraries that are needed in this project
    set(USERVER_FEATURE_POSTGRESQL ON CACHE BOOL "" FORCE)

    # Compatibility mode: some systems don't support these features
    set(USERVER_FEATURE_CRYPTOPP_BLAKE2 OFF CACHE BOOL "" FORCE)
    set(USERVER_FEATURE_GRPC_CHANNELZ OFF CACHE BOOL "" FORCE)
    set(USERVER_FEATURE_REDIS_HI_MALLOC ON CACHE BOOL "" FORCE)

    if (EXISTS third_party/userver)
        message(STATUS "Using userver framework from third_party/userver")
        add_subdirectory(third_party/userver)
    else()
        message(FATAL_ERROR "Either install the userver or provide a path to it")
    endif()
endif()

userver_setup_environment()


# Common sources
add_library(${PROJECT_NAME}_objs OBJECT
    src/hello.hpp
    src/hello.cpp
)
target_link_libraries(${PROJECT_NAME}_objs PUBLIC userver::postgresql)


# The Service
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_objs)


# Unit Tests
add_executable(${PROJECT_NAME}_unittest
    src/hello_test.cpp
)
target_link_libraries(${PROJECT_NAME}_unittest PRIVATE ${PROJECT_NAME}_objs userver::utest)
add_google_tests(${PROJECT_NAME}_unittest)


# Benchmarks
add_executable(${PROJECT_NAME}_benchmark
    src/hello_benchmark.cpp
)
target_link_libraries(${PROJECT_NAME}_benchmark PRIVATE ${PROJECT_NAME}_objs userver::ubench)
add_google_benchmark_tests(${PROJECT_NAME}_benchmark)


# Functional Tests
include(UserverTestsuite)

userver_testsuite_add_simple()


# Install
include(GNUInstallDirs)

if(DEFINED ENV{PREFIX})
  message(STATUS "Set install prefix: $ENV{PREFIX}")
  file(TO_CMAKE_PATH "$ENV{PREFIX}" PREFIX_PATH)
  set(CMAKE_INSTALL_PREFIX ${PREFIX_PATH})
endif()

file(GLOB CONFIGS_FILES ${CMAKE_CURRENT_SOURCE_DIR}/configs/*.yaml ${CMAKE_CURRENT_SOURCE_DIR}/configs/*.json)

install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT ${PROJECT_NAME})
install(FILES ${CONFIGS_FILES} DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/${PROJECT_NAME} COMPONENT ${PROJECT_NAME})
