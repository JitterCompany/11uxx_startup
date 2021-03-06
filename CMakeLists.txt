cmake_minimum_required(VERSION 3.5.0 FATAL_ERROR)


set(CPM_MODULE_NAME startup_lpc11xxx)

#-----------------------------------------------------------------------
# Required CPM Setup - no need to modify - See: https://github.com/iauns/cpm
#-----------------------------------------------------------------------
set(CPM_LIB_TARGET_NAME ${CPM_MODULE_NAME})

if ((DEFINED CPM_DIR) AND (DEFINED CPM_UNIQUE_ID) AND (DEFINED CPM_TARGET_NAME))
    set(CPM_LIB_TARGET_NAME ${CPM_TARGET_NAME})
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CPM_DIR})
    include(CPM)
else()
    set (CPM_DIR "${CMAKE_CURRENT_BINARY_DIR}/cpm-packages" CACHE TYPE STRING)
    find_package(Git)
    if(NOT GIT_FOUND)
        message(FATAL_ERROR "CPM requires Git.")
    endif()
    if (NOT EXISTS ${CPM_DIR}/CPM.cmake)
        message(STATUS "Cloning repo (https://github.com/iauns/cpm)")
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" clone https://github.com/iauns/cpm ${CPM_DIR}
            RESULT_VARIABLE error_code
            OUTPUT_QUIET ERROR_QUIET)
        if(error_code)
            message(FATAL_ERROR "CPM failed to get the hash for HEAD")
        endif()
    endif()
    include(${CPM_DIR}/CPM.cmake)
endif()

CPM_InitModule(${CPM_MODULE_NAME})

#-----------------------------------------------------------------------
# Project sources / settings
#-----------------------------------------------------------------------

file(GLOB SOURCES 
    "${CPM_MODULE_NAME}/src/*.c"
    )

include_directories("${CPM_MODULE_NAME}")

get_directory_property(DEFINITIONS COMPILE_DEFINITIONS)
if ("CHIP_LPC11UXX" IN_LIST DEFINITIONS)
    message(STATUS "Got lpc11uxx: choosing USB startup code")
    set(LINKER_TYPE "lpc11uxx")
else()
    message(STATUS "Got lpc11xxx: choosing non-USB startup code")
    set(LINKER_TYPE "lpc11xxx")
endif()

set(LINKER_FILE "${CMAKE_CURRENT_LIST_DIR}/${CPM_MODULE_NAME}/\
${LINKER_TYPE}.ld")
set_property(GLOBAL PROPERTY startup_linker "${LINKER_FILE}")


add_library(${CPM_LIB_TARGET_NAME} ${SOURCES})
target_link_libraries(${CPM_LIB_TARGET_NAME} ${CPM_LIBRARIES})

