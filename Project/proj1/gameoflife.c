/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This function allocates space for a new Color.
//Note that you will need to read the eight neighbors of the cell in question. The grid "wraps", so we treat the top row as adjacent to the bottom row
//and the left column as adjacent to the right column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule)
{
    int dr[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
    int dc[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
    int rows = image->rows;
    int cols = image->cols;
    Color *new_color = malloc(sizeof(Color));
    if (!new_color) return NULL;
    Color old = image->image[row][col];
    new_color->R = new_color->G = new_color->B = 0;
    for (int bit = 0; bit < 8; bit++) {
        // R
        int alive = (old.R >> bit) & 1;
        int count = 0;
        for (int k = 0; k < 8; k++) {
            int nr = (row + dr[k] + rows) % rows;
            int nc = (col + dc[k] + cols) % cols;
            Color n = image->image[nr][nc];
            if ((n.R >> bit) & 1) count++;
        }
        int newbit;
        if (alive == 0) {
            // 死细胞，查rule的低9位
            newbit = (rule >> count) & 1;
        } else {
            // 活细胞，查rule的高9位
            newbit = (rule >> (9 + count)) & 1;
        }
        if (newbit) new_color->R |= (1 << bit);
    }
    for (int bit = 0; bit < 8; bit++) {
        // G
        int alive = (old.G >> bit) & 1;
        int count = 0;
        for (int k = 0; k < 8; k++) {
            int nr = (row + dr[k] + rows) % rows;
            int nc = (col + dc[k] + cols) % cols;
            Color n = image->image[nr][nc];
            if ((n.G >> bit) & 1) count++;
        }
        int newbit;
        if (alive == 0) {
            newbit = (rule >> count) & 1;
        } else {
            newbit = (rule >> (9 + count)) & 1;
        }
        if (newbit) new_color->G |= (1 << bit);
    }
    for (int bit = 0; bit < 8; bit++) {
        // B
        int alive = (old.B >> bit) & 1;
        int count = 0;
        for (int k = 0; k < 8; k++) {
            int nr = (row + dr[k] + rows) % rows;
            int nc = (col + dc[k] + cols) % cols;
            Color n = image->image[nr][nc];
            if ((n.B >> bit) & 1) count++;
        }
        int newbit;
        if (alive == 0) {
            newbit = (rule >> count) & 1;
        } else {
            newbit = (rule >> (9 + count)) & 1;
        }
        if (newbit) new_color->B |= (1 << bit);
    }
    return new_color;
}

//The main body of Life; given an image and a rule, computes one iteration of the Game of Life.
//You should be able to copy most of this from steganography.c
Image *life(Image *image, uint32_t rule)
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
            Color *c = evaluateOneCell(image, i, j, rule);
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
Loads a .ppm from a file, computes the next iteration of the game of life, then prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this will be a string.
You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv)
{
    if (argc != 3) {
        printf("    usage: ./gameOfLife filename rule\n");
        printf("    filename is an ASCII PPM file (type P3) with maximum value 255.\n");
        printf("    rule is a hex number beginning with 0x; Life is 0x1808.\n");
        return -1;
    }
    Image *img = readData(argv[1]);
    if (!img) return -1;
    char *endptr;
    uint32_t rule = (uint32_t)strtol(argv[2], &endptr, 0);
    if (*endptr != '\0') {
        freeImage(img);
        return -1;
    }
    Image *next = life(img, rule);
    if (!next) {
        freeImage(img);
        return -1;
    }
    writeData(next);
    freeImage(next);
    freeImage(img);
    return 0;
}
