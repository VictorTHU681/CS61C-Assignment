/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**              YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

// 跳过文件中的注释行，返回下一个非注释字符串
static void skip_comments(FILE *fp, char *buf) {
    do {
        if (fscanf(fp, "%255s", buf) != 1) return;
    } while (buf[0] == '#');
}

// 打开 P3 格式的 .ppm 文件，读取数据并构造 Image 对象
Image *readData(char *filename)
{
    FILE *fp = fopen(filename, "r");
    if (!fp) return NULL;

    char buf[256];
    // 读取 magic number
    if (fscanf(fp, "%255s", buf) != 1 || strcmp(buf, "P3") != 0) {
        fclose(fp);
        return NULL;
    }

    // 读取 cols
    skip_comments(fp, buf);
    uint32_t cols = (uint32_t)atoi(buf);
    // 读取 rows
    skip_comments(fp, buf);
    uint32_t rows = (uint32_t)atoi(buf);
    // 读取最大颜色值
    skip_comments(fp, buf);
    int maxval = atoi(buf);
    if (maxval != 255) {
        fclose(fp);
        return NULL; // 只支持255
    }

    // 分配 Image 结构体
    Image *img = malloc(sizeof(Image));
    if (!img) {
        fclose(fp);
        return NULL;
    }
    img->rows = rows;
    img->cols = cols;
    img->image = malloc(rows * sizeof(Color*));
    if (!img->image) {
        free(img);
        fclose(fp);
        return NULL;
    }
    for (uint32_t i = 0; i < rows; i++) {
        img->image[i] = malloc(cols * sizeof(Color));
        if (!img->image[i]) {
            // 释放已分配的
            for (uint32_t k = 0; k < i; k++) free(img->image[k]);
            free(img->image);
            free(img);
            fclose(fp);
            return NULL;
        }
    }

    // 读取像素数据
    for (uint32_t i = 0; i < rows; i++) {
        for (uint32_t j = 0; j < cols; j++) {
            int r, g, b;
            if (fscanf(fp, "%d %d %d", &r, &g, &b) != 3) {
                // 释放内存
                for (uint32_t k = 0; k < rows; k++) free(img->image[k]);
                free(img->image);
                free(img);
                fclose(fp);
                return NULL;
            }
            img->image[i][j].R = (uint8_t)r;
            img->image[i][j].G = (uint8_t)g;
            img->image[i][j].B = (uint8_t)b;
        }
    }
    fclose(fp);
    return img;
}

// 按 P3 格式输出 Image 到标准输出
void writeData(Image *image)
{
    if (!image) return;
    printf("P3\n");
    printf("%u %u\n", image->cols, image->rows);
    printf("255\n");
    for (uint32_t i = 0; i < image->rows; i++) {
        for (uint32_t j = 0; j < image->cols; j++) {
            Color c = image->image[i][j];
            printf("%3u %3u %3u", c.R, c.G, c.B);
            if (j != image->cols - 1) {
                printf("   "); // 3 spaces between columns
            }
        }
        printf("\n");
    }
}

// 释放 Image 及其所有内存
void freeImage(Image *image)
{
    if (!image) return;
    for (uint32_t i = 0; i < image->rows; i++) {
        free(image->image[i]);
    }
    free(image->image);
    free(image);
}
