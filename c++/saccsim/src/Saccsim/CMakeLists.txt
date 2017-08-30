file(GLOB SOURCE_FILES *.cpp)
file(GLOB HEADER_FILES *.h)
set(SOURCE ${SOURCE_FILES} ${HEADER_FILES})

if(BUILD_WITHOUT_CPP11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DNO_CPP_11_COMPILER")
else()
    # Latest OpenSim uses C++11 language features.
    if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" OR
            "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
        # Using C++11 on OSX requires using libc++ instead of libstd++.
        # libc++ is an implementation of the C++ standard library for OSX.
        if(APPLE)
            if(XCODE)
                set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
                set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
            else()
                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
            endif()
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
        endif()
    endif()
endif(BUILD_WITHOUT_CPP11)

set(OPENSIM_INSTALL_DIR $ENV{OPENSIM_HOME} CACHE PATH "Top-level directory of OpenSim install")

# To add Debug feature add ";Debug" after Release on the line below
set(CMAKE_CONFIGURATION_TYPES "RelWithDebInfo;Release" CACHE STRING "Semicolon separated list of supported configuration types, only supports Debug, Release, MinSizeRel, and RelWithDebInfo, anything else will be ignored." FORCE )

# Location of headers
set(SIMTK_HEADERS_DIR ${OPENSIM_INSTALL_DIR}/sdk/include/SimTK/include)
set(OPENSIM_HEADERS_DIR ${OPENSIM_INSTALL_DIR}/sdk/include)
include_directories(${OpenSim_SOURCE_DIR} ${OpenSim_SOURCE_DIR}/Vendors)
include_directories(${SIMTK_HEADERS_DIR} ${OPENSIM_HEADERS_DIR})

# Libraries and dlls
set(OPENSIM_LIBS_DIR ${OPENSIM_INSTALL_DIR}/sdk/lib ${OPENSIM_INSTALL_DIR}/lib)
set(OPENSIM_DLLS_DIR ${OPENSIM_INSTALL_DIR}/bin)
link_directories(${OPENSIM_LIBS_DIR} ${OPENSIM_DLLS_DIR})

if(WIN32)
	set(NameSpace "OpenSim_" CACHE STRING "Prefix for simtk lib names, includes trailing '_'. Leave empty to use stock SimTK libraries.")
    set(PLATFORM_LIBS  pthreadVC2)
else(WIN32)
  set(NameSpace "")
  if(APPLE)
    set(PLATFORM_LIBS  SimTKAtlas)
  else(APPLE)
    set(PLTAFORM_LIBS SimTKAtlas_Lin_generic)
  endif(APPLE)
endif(WIN32)

add_library(saccsim SHARED ${SOURCE})

# Specify libraries used
target_link_libraries(saccsim LINK_PRIVATE
    debug osimSimulation_d	optimized osimSimulation
    debug osimActuators_d	optimized osimActuators
    debug osimCommon_d		optimized osimCommon
    debug osimAnalyses_d	optimized osimAnalyses
    debug osimTools_d		optimized osimTools
    debug osimLepton_d      optimized osimLepton
    debug ${NameSpace}SimTKcommon_d optimized ${NameSpace}SimTKcommon
    debug ${NameSpace}SimTKmath_d optimized  ${NameSpace}SimTKmath
    debug ${NameSpace}SimTKsimbody_d optimized ${NameSpace}SimTKsimbody
    ${PLATFORM_LIBS}
)

# Mark Advanced 
mark_as_advanced(CMAKE_INSTALL_PREFIX)
mark_as_advanced(EXECUTABLE_OUTPUT_PATH)
mark_as_advanced(LIBRARY_OUTPUT_PATH)
