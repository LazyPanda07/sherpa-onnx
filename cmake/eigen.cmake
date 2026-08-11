function(download_eigen)
  include(FetchContent)

  set(eigen_URL  "https://github.com/eigen-mirror/eigen/archive/1d8b82b0740839c0de7f1242a3585e3390ff5f33/eigen-1d8b82b0740839c0de7f1242a3585e3390ff5f33.zip")
  set(eigen_HASH "SHA256=6a60d76351f97132669daeeb721d6bf14b008101883ad2d687a3201c5c461eb0")

  # If you don't have access to the Internet,
  # please pre-download eigen
  set(possible_file_locations
    $ENV{HOME}/Downloads/eigen-3.4.90.tar.gz
    ${CMAKE_SOURCE_DIR}/eigen-3.4.90.tar.gz
    ${CMAKE_BINARY_DIR}/eigen-3.4.90.tar.gz
    /tmp/eigen-3.4.90.tar.gz
    /star-fj/fangjun/download/github/eigen-3.4.90.tar.gz
  )

  foreach(f IN LISTS possible_file_locations)
    if(EXISTS ${f})
      set(eigen_URL  "${f}")
      file(TO_CMAKE_PATH "${eigen_URL}" eigen_URL)
      message(STATUS "Found local downloaded eigen: ${eigen_URL}")
      break()
    endif()
  endforeach()

  set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
  set(EIGEN_BUILD_DOC OFF CACHE BOOL "" FORCE)

  FetchContent_Declare(eigen
    URL               ${eigen_URL}
    URL_HASH          ${eigen_HASH}
  )

  FetchContent_GetProperties(eigen)
  if(NOT eigen_POPULATED)
    message(STATUS "Downloading eigen from ${eigen_URL}")
    FetchContent_Populate(eigen)
  endif()
  message(STATUS "eigen is downloaded to ${eigen_SOURCE_DIR}")
  message(STATUS "eigen's binary dir is ${eigen_BINARY_DIR}")

  add_subdirectory(${eigen_SOURCE_DIR} ${eigen_BINARY_DIR} EXCLUDE_FROM_ALL)
endfunction()

download_eigen()

