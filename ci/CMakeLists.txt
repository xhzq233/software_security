cmake_minimum_required(VERSION 3.22)
project(ci)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)

add_library(ci SHARED lib.c lib.def)

set_target_properties(ci PROPERTIES
    PUBLIC_HEADER lib.h
    OUTPUT_NAME "ci"
)