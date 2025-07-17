/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				YOUR NAME HERE
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This should not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col)
{
    Color *new_color = malloc(sizeof(Color));
    if (!new_color) return NULL;
    uint8_t lsb = image->image[row][col].B & 1;
    if (lsb) {
        new_color->R = 255;
        new_color->G = 255;
        new_color->B = 255;
    } else {
        new_color->R = 0;
        new_color->G = 0;
        new_color->B = 0;
    }
    return new_color;
}

//Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{
    if (!image) return NULL;
    Image *out = malloc(sizeof(Image));
    if (!out) return NULL;
    out->rows = image->rows;
    out->cols = image->cols;
    out->image = malloc(out->rows * sizeof(Color*));
    if (!out->image) { free(out); return NULL; }
    for (uint32_t i = 0; i < out->rows; i++) {
        out->image[i] = malloc(out->cols * sizeof(Color));
        if (!out->image[i]) {
            for (uint32_t k = 0; k < i; k++) free(out->image[k]);
            free(out->image);
            free(out);
            return NULL;
        }
        for (uint32_t j = 0; j < out->cols; j++) {
            Color *c = evaluateOnePixel(image, i, j);
            if (!c) {
                for (uint32_t k = 0; k <= i; k++) free(out->image[k]);
                free(out->image);
                free(out);
                return NULL;
            }
            out->image[i][j] = *c;
            free(c);
        }
    }
    return out;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with printf) a new image, 
where each pixel is black if the LSB of the B channel is 0, 
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not necessarily with .ppm file extension).
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!
*/
int main(int argc, char **argv)
{
    if (argc != 2) return -1;
    Image *img = readData(argv[1]);
    if (!img) return -1;
    Image *decoded = steganography(img);
    if (!decoded) {
        freeImage(img);
        return -1;
    }
    writeData(decoded);
    freeImage(decoded);
    freeImage(img);
    return 0;
}
