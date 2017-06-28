include(GenerateExportHeader)
cmake_minimum_required (VERSION 2.6)
project (blake2)
include_directories(BLAKE2/ref)

set(files BLAKE2/ref/blake2b-ref.c)

add_library(blake2 SHARED ${files})

target_link_libraries(blake2)
