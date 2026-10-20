# Copyright (c)  2022-2023  Xiaomi Corporation
message(STATUS "CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")

set(ONNXRUNTIME_VERSION 1.28.0)

set(ORIGINAL_ONNXRUNTIME_URL https://github.com/microsoft/onnxruntime/releases/download/v1.28.0/onnxruntime-linux-x64-1.28.0.tgz)
set(ORIGINAL_ONNXRUNTIME_HASH "SHA256=a3e1b79d7bb1bf09696ce675f49e4064e6c81f6202b8225624fff0e93f8d6407")

if(NOT CMAKE_SYSTEM_NAME STREQUAL Linux)
  message(FATAL_ERROR "This file is for Linux only. Given: ${CMAKE_SYSTEM_NAME}")
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR STREQUAL x86_64)
  message(FATAL_ERROR "This file is for x86_64 only. Given: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

if(BUILD_SHARED_LIBS AND NOT ${SHERPA_STATIC_ONNXRUNTIME})
  message(FATAL_ERROR "This file is for building static libraries. BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")
endif()

set(onnxruntime_URL  "https://github.com/csukuangfj/onnxruntime-libs/releases/download/v${ONNXRUNTIME_VERSION}/onnxruntime-linux-x64-static_lib-${ONNXRUNTIME_VERSION}-glibc2_17.zip")
set(onnxruntime_HASH "SHA256=1da130c29e7588b928a9f93ffe1d0b99c5ecd8da038b0715782055f06f133dcf")

# If you don't have access to the Internet,
# please download onnxruntime to one of the following locations.
# You can add more if you want.
set(possible_file_locations
  $ENV{HOME}/Downloads/onnxruntime-linux-x64-static_lib-${ONNXRUNTIME_VERSION}-glibc2_17.zip
  ${CMAKE_SOURCE_DIR}/onnxruntime-linux-x64-static_lib-${ONNXRUNTIME_VERSION}-glibc2_17.zip
  ${CMAKE_BINARY_DIR}/onnxruntime-linux-x64-static_lib-${ONNXRUNTIME_VERSION}-glibc2_17.zip
  /tmp/onnxruntime-linux-x64-static_lib-${ONNXRUNTIME_VERSION}-glibc2_17.zip
  /star-fj/fangjun/download/github/onnxruntime-linux-x64-static_lib-${ONNXRUNTIME_VERSION}-glibc2_17.zip
)

foreach(f IN LISTS possible_file_locations)
  if(EXISTS ${f})
    set(onnxruntime_URL  "${f}")
    file(TO_CMAKE_PATH "${onnxruntime_URL}" onnxruntime_URL)
    message(STATUS "Found local downloaded onnxruntime: ${onnxruntime_URL}")
    break()
  endif()
endforeach()

FetchContent_Declare(onnxruntime
  URL
    ${onnxruntime_URL}
  URL_HASH          ${onnxruntime_HASH}
)

FetchContent_GetProperties(onnxruntime)
if(NOT onnxruntime_POPULATED)
  message(STATUS "Downloading onnxruntime from ${onnxruntime_URL}")
  FetchContent_Populate(onnxruntime)

  FetchContent_Declare(
      onnxruntime_headers 
      URL ${ORIGINAL_ONNXRUNTIME_URL}
      URL_HASH ${ORIGINAL_ONNXRUNTIME_HASH}
  )

  FetchContent_MakeAvailable(onnxruntime_headers)

  file(COPY "${onnxruntime_headers_SOURCE_DIR}/include/" DESTINATION "${onnxruntime_SOURCE_DIR}/include")
endif()
message(STATUS "onnxruntime is downloaded to ${onnxruntime_SOURCE_DIR}")

# for static libraries, we use onnxruntime_lib_files directly below
include_directories(${onnxruntime_SOURCE_DIR}/include)

file(GLOB onnxruntime_lib_files "${onnxruntime_SOURCE_DIR}/lib/lib*.a")

set(onnxruntime_lib_files ${onnxruntime_lib_files} PARENT_SCOPE)

message(STATUS "onnxruntime lib files: ${onnxruntime_lib_files}")
install(FILES ${onnxruntime_lib_files} DESTINATION lib)
