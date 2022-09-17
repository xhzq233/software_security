cmake_minimum_required(VERSION 3.22)
project(ci VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)

add_library(ci SHARED lib.c lib.def)


set_target_properties(ci PROPERTIES
    PUBLIC_HEADER lib.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "ci"
)