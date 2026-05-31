#include <vector>
#include <cmath>
#include <iostream>   // <-- added
#include <string>     // <-- added
#include <filesystem>
#include <nppdefs.h>
#include <nppi_geometry_transforms.h>
#include "ImagesCPU.h"
#include "ImagesNPP.h"
#include "ImageIO.h"

void rotate_image(const npp::ImageCPU_8u_C1 *h_src_img,
                  npp::ImageCPU_8u_C1 *h_dst_img,
                  double rotation_degree) {
    if (!h_dst_img || !h_src_img) {
        std::cerr << "Null image pointer passed to rotate_image\n";
        return;
    }

    npp::ImageNPP_8u_C1 d_src_img(*h_src_img);
    auto src_w = h_src_img->width();
    auto src_h = h_src_img->height();

    // Normalize angle to [0, 360)
    double normalized_degree = std::fmod(std::fmod(rotation_degree, 360.0) + 360.0, 360.0);

    // Determine destination dimensions (swap for 90/270 rotations)
    bool swap_wh = (std::fmod(normalized_degree, 180.0) != 0.0);
    auto dst_w = swap_wh ? src_h : src_w;
    auto dst_h = swap_wh ? src_w : src_h;

    npp::ImageNPP_8u_C1 d_dst_img(dst_w, dst_h);

    NppiSize src_sz{static_cast<int>(src_w), static_cast<int>(src_h)};
    NppiRect src_roi{0, 0, static_cast<int>(src_w), static_cast<int>(src_h)};
    NppiRect dst_roi{0, 0, static_cast<int>(dst_w), static_cast<int>(dst_h)};

    double shiftX = 0.0;
    double shiftY = 0.0;
    // NPPI rotation requires shift to place the image inside the destination ROI
    if (normalized_degree == 90.0) {
        shiftX = static_cast<double>(dst_w);
    } else if (normalized_degree == 180.0) {
        shiftX = static_cast<double>(dst_w);
        shiftY = static_cast<double>(dst_h);
    } else if (normalized_degree == 270.0) {
        shiftY = static_cast<double>(dst_h);
    }

    NppStatus status = nppiRotate_8u_C1R(
        d_src_img.data(), src_sz, static_cast<int>(d_src_img.pitch()), src_roi,
        d_dst_img.data(), static_cast<int>(d_dst_img.pitch()), dst_roi,
        normalized_degree, shiftX, shiftY, NPPI_INTER_LINEAR
    );

    if (status != NPP_SUCCESS) {
        std::cerr << "nppiRotate_8u_C1R failed with code " << status << "\n";
        return;
    }

    // Allocate host image for result and copy from device
    *h_dst_img = npp::ImageCPU_8u_C1(dst_w, dst_h);
    d_dst_img.copyTo(h_dst_img->data(), h_dst_img->pitch());
}

int main(int argc, const char **argv) {
    if (argc != 4) {
        std::cout << "Usage: " << argv[0] << " <input_dir> <output_dir> <rotation_angle>\n";
        return 1;
    }

    std::string indir  = argv[1];     // first argument: input directory
    std::string outdir = argv[2];     // second argument: output directory
    double rotation_angle = std::stod(argv[3]); // third argument: rotation angle in degrees

    // Create output directory if it doesn't exist
    std::filesystem::create_directories(outdir);

    std::vector<std::filesystem::path> images;
    for (const auto &entry : std::filesystem::directory_iterator(indir)) {
        auto ext = entry.path().extension().string();
        if (ext == ".jpg" || ext == ".png" || ext == ".jpeg") {
            images.push_back(entry.path());
        }
    }

    if (images.empty()) {
        std::cout << "No images found in " << indir << "\n";
        return 1;
    }

    for (const auto &file_path : images) {
        npp::ImageCPU_8u_C1 h_src, h_dst;
        try {
            // Load source image
            npp::loadImage(file_path.string().c_str(), h_src);
            std::cout << "Rotating: " << file_path.filename() << " by " << rotation_angle << " degrees\n";

            // Perform rotation
            rotate_image(&h_src, &h_dst, rotation_angle);

            // Save result to output directory (preserve original filename)
            std::filesystem::path out_path = std::filesystem::path(outdir) / file_path.filename();
            npp::saveImage(out_path.string().c_str(), h_dst);
            std::cout << "Saved: " << out_path.string() << "\n";

        } catch (npp::Exception &rException) {
            std::cerr << "NPP exception on " << file_path << ": " << rException << "\n";
        } catch (std::exception &e) {
            std::cerr << "Exception on " << file_path << ": " << e.what() << "\n";
        }
    }

    return 0;
}