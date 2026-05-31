cmake_minimum_required(VERSION 3.10)
project(Utilities VERSION 1.0.0)
add_library(Utilities INTERFACE)
target_include_directories(Utilities INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/headers>
    $<INSTALL_INTERFACE:headers>
)
add_library(glew64 STATIC IMPORTED)
set_target_properties(glew64 PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/glew64.lib"
)
add_library(freeglut STATIC IMPORTED)
set_target_properties(freeglut PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/freeglut.lib"
)
target_link_libraries(Utilities INTERFACE glew64 freeglut freeimage)
install(TARGETS Utilities
    EXPORT UtilitiesTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)
install(EXPORT UtilitiesTargets
    FILE NestedPackageConfig.cmake
    NAMESPACE Utilities::
    DESTINATION lib/cmake/Utilities
)