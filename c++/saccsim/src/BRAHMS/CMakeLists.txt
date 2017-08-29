file(GLOB SOURCE_FILES *.cpp)
file(GLOB HEADER_FILES *.h)
set(SOURCE ${SOURCE_FILES} ${HEADER_FILES})

# requred by BRAHMS to compile
add_definitions(-D__64BIT__)
add_definitions(-D__LINUX__)

# define paths for base dir and configuration file
set(saccadesimulator_root $ENV{SACCSIM_DIR} CACHE PATH "Root dir of SaccadeSimulator")
add_definitions(-D__BASE_DIR__="${saccadesimulator_root}/")
add_definitions(-D__CONF__="${saccadesimulator_root}/config/params_brahms.txt")
message("Using: [" ${saccadesimulator_root}/config/params_brahms.txt "] for config file")
set(BC_TARGET component CACHE TYPE STRING)

# SYSTEMML_INSTALL_PATH is only required if you have a standalone
# BRAHMS installation in a SystemML directory.
set(SYSTEMML_INSTALL_PATH $ENV{SYSTEMML_INSTALL_PATH} CACHE PATH
    "Installation location of Brahms (e.g. ~/SystemML)")

# saccadesimulator interface
include_directories(../Saccsim)

# BRAHMS engine
include_directories(${SYSTEMML_INSTALL_PATH}/BRAHMS/include)
include_directories(${SYSTEMML_INSTALL_PATH}/Namespace)
# BRAHMS may be installed in $ENV{HOME}/usr/include:
include_directories($ENV{HOME}/usr/include)

add_library(${BC_TARGET} SHARED ${SOURCE})
# "" rather than "lib" to give Brahms style "component.so" not "libcomponent.so":
set_target_properties (${BC_TARGET} PROPERTIES PREFIX "")
set_target_properties (${BC_TARGET} PROPERTIES COMPILE_DEFINITIONS "__GLN__")
set_target_properties (${BC_TARGET} PROPERTIES COMPILE_FLAGS "-Werror -pthread -O3")

# removed brahms-engine from the following:
target_link_libraries(${BC_TARGET} saccsim)
