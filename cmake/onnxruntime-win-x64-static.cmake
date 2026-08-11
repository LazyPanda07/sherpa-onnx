# Copyright (c)  2022-2023  Xiaomi Corporation
message(STATUS "CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_VS_PLATFORM_NAME: ${CMAKE_VS_PLATFORM_NAME}")

set(ONNXRUNTIME_VERSION 1.28.0)

set(ORIGINAL_ONNXRUNTIME_URL https://github.com/microsoft/onnxruntime/releases/download/v1.28.0/onnxruntime-win-x64-1.28.0.zip)
set(ORIGINAL_ONNXRUNTIME_HASH "SHA256=abef733dacbe2f571547a7150b479b5cb9cc0df22f96c24983a42cadb1b4f8bc")

if(NOT CMAKE_SYSTEM_NAME STREQUAL Windows)
  message(FATAL_ERROR "This file is for Windows only. Given: ${CMAKE_SYSTEM_NAME}")
endif()

if(NOT (CMAKE_VS_PLATFORM_NAME STREQUAL X64 OR CMAKE_VS_PLATFORM_NAME STREQUAL x64))
  message(FATAL_ERROR "This file is for Windows x64 only. Given: ${CMAKE_VS_PLATFORM_NAME}")
endif()

if(BUILD_SHARED_LIBS AND NOT ${SHERPA_STATIC_ONNXRUNTIME})
  message(FATAL_ERROR "This file is for building static libraries. BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")
endif()

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Release|Debug|RelWithDebInfo|MinSizeRel)$")
  message(FATAL_ERROR "Supported CMAKE_BUILD_TYPE values are: Release, Debug, RelWithDebInfo, MinSizeRel. Given ${CMAKE_BUILD_TYPE}")
endif()

# Hashes for static CRT (/MT)
set(ONNXRUNTIME_HASH_MT_Release "SHA256=91c9e1967138fd7f04ecddab61519423580666470a2e58594fc1743195623e5c")
set(ONNXRUNTIME_HASH_MT_Debug "SHA256=4fe6e158416c191e3afb2dbe0af3025894b93e3507c8185d4f6acedaad56a663")
set(ONNXRUNTIME_HASH_MT_RelWithDebInfo "SHA256=21efbef71ec78c9fc2e1abfc9d9272738e6e554246af33b8a7bbe355bd98ef29")
set(ONNXRUNTIME_HASH_MT_MinSizeRel "SHA256=91f1ea570dc48c01c93861cd514274abae0c4ac683acfc5fcd8eee1e148dbdad")

# Hashes for dynamic CRT (/MD)
set(ONNXRUNTIME_HASH_MD_Release "SHA256=0be3f2074f5226dd08ed78caf12e516021f402a1680a929f7f26bdee9458e932")
set(ONNXRUNTIME_HASH_MD_Debug "SHA256=aa0dae71a4b09bf30fb6c12723922942879e0aad991e1b22ce034f10410f76be")
set(ONNXRUNTIME_HASH_MD_RelWithDebInfo "SHA256=47cc9e99cc84191c494e8658274f9a1db4b8c602daa53091735f696682c06adf")
set(ONNXRUNTIME_HASH_MD_MinSizeRel "SHA256=c53a630ffc1246a03a2a1dfd2d15fe3bb677add7b102a1bfa4a7652e68199514")

if(SHERPA_ONNX_USE_STATIC_CRT)
  set(onnxruntime_crt "MT")
else()
  set(onnxruntime_crt "MD")
endif()

message(STATUS "Use MSVC CRT: ${onnxruntime_crt}")

set(onnxruntime_filename "onnxruntime-win-x64-static_lib-${onnxruntime_crt}-${CMAKE_BUILD_TYPE}-${ONNXRUNTIME_VERSION}.tar.bz2")
set(onnxruntime_HASH "${ONNXRUNTIME_HASH_${onnxruntime_crt}_${CMAKE_BUILD_TYPE}}")
set(onnxruntime_URL  "https://github.com/csukuangfj/onnxruntime-libs/releases/download/v${ONNXRUNTIME_VERSION}/${onnxruntime_filename}")

# If you don't have access to the Internet,
# please download onnxruntime to one of the following locations.
# You can add more if you want.
set(possible_file_locations
  $ENV{HOME}/Downloads/${onnxruntime_filename}
  ${CMAKE_SOURCE_DIR}/${onnxruntime_filename}
  ${CMAKE_BINARY_DIR}/${onnxruntime_filename}
  $ENV{TMP}/${onnxruntime_filename}
  $ENV{TEMP}/${onnxruntime_filename}
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

file(GLOB onnxruntime_lib_files "${onnxruntime_SOURCE_DIR}/lib/*.lib")

set(onnxruntime_lib_files ${onnxruntime_lib_files} PARENT_SCOPE)

message(STATUS "onnxruntime lib files: ${onnxruntime_lib_files}")
if(SHERPA_ONNX_ENABLE_PYTHON)
  install(FILES ${onnxruntime_lib_files} DESTINATION ..)
else()
  install(FILES ${onnxruntime_lib_files} DESTINATION lib)
endif()
