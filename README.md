# CUDA at Scale – Image Batch Rotator

A CUDA-powered command-line tool that applies an arbitrary rotation to a folder of images using NVIDIA Performance Primitives (NPP). It accelerates the rotation on the GPU and saves the results automatically.

---

## Features
- **Batch processing** – Rotate every compatible image in a directory with a single command.
- **GPU acceleration** – Uses `nppiRotate_8u_C1R` from NPP for high-performance geometric transformations.
- **Flexible angles** – Any floating-point degree value (e.g., 10.5, -45, 90).
- **Supports common formats** – JPEG, PNG, and other formats supported by FreeImage.
- **Automatic output directory creation** – Saves rotated images with the original filenames.

---

## Prerequisites
To build and run the project you need:

| Dependency | Installation (Ubuntu/Debian) |
|------------|------------------------------|
| **CMake** (≥3.10) | `sudo apt install cmake` |
| **CUDA Toolkit** (with NPP) | Download from [NVIDIA CUDA](https://developer.nvidia.com/cuda-downloads) |
| **FreeImage** | `sudo apt install libfreeimage-dev` |
| **GLEW** | `sudo apt install libglew-dev` |
| **freeglut** | `sudo apt install freeglut3-dev` |

*Note:* The project links against static libraries of GLEW and freeglut provided in `Utilities/lib/`, but you may still need the development packages for headers and runtime dependencies.

---

## Building
1. **Clone or navigate to the repository**
   cd CUDA_at_Scale_for_the_Enterprise_final_project
2 Configure with CMake
    cmake -B build -S .
3 Build the executable
        cmake --build build --target CUDA_at_Scale_for_the_Enterprise_final_project -j $(nproc)

4. Usage
   Run the program from the terminal:

   ./CUDA_at_Scale_for_the_Enterprise_final_project <input_dir> <output_dir> <rotation_angle>
   Arguments
   <input_dir> – Path to the folder containing the source images.
   <output_dir> – Path where the rotated images will be saved. Created if missing.
   <rotation_angle> – Angle in degrees (double). Positive = counter‑clockwise.
   Only files with extensions .jpg, .jpeg, or .png (case‑sensitive) are processed.
   Example
   bash
   ./CUDA_at_Scale_for_the_Enterprise_final_project \
       /path/images \
       /path/images_rotated \
       10.5
   Rotates every compatible image in dataset by 10.5° and writes the results into dataset_rotated.
Important: Image Format Requirement
The rotation kernel operates on 8‑bit single‑channel (grayscale) images. If your input images are color (RGB), you have two options:

A. Pre‑convert your dataset to grayscale
Use ImageMagick or Python to create a grayscale copy of your folder:

# Using ImageMagick
mkdir -p dataset_gray
for f in dataset/*.jpg; do
    convert "$f" -colorspace Gray "dataset_gray/$(basename $f)"
done
Then run the tool on the dataset_gray folder.

