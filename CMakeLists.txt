cmake_minimum_required(VERSION 4.1)
project(CUDA_at_Scale_for_the_Enterprise_final_project LANGUAGES CUDA CXX C)
set(CMAKE_CXX_STANDARD 17)
enable_language(CUDA)
find_package(CUDAToolkit REQUIRED)
add_subdirectory(Utilities)
add_executable(${PROJECT_NAME} main.cu)
target_link_libraries(${PROJECT_NAME}
        CUDA::cudart
        CUDA::nppif
        CUDA::nppig
        CUDA::nppicc
        CUDA::nppisu
        CUDA::nppidei
        Utilities)
target_include_directories(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/Utilities/headers
        ${CUDAToolkit_INCLUDE_DIRS}
        ${CUDAToolkit_INCLUDE_DIRS}/npp
        ${CUDAToolkit_INCLUDE_DIRS}/NPP) # Added this line
set_target_properties(${PROJECT_NAME} PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
        CUDA_RESOLVE_DEVICE_SYMBOLS ON
)
target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>
        $<$<COMPILE_LANGUAGE:CXX>:-Wall>
)