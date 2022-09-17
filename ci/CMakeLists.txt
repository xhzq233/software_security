cmake_minimum_required(VERSION 3.23)
project(ci)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)

add_library(ci SHARED main.c main.h)
