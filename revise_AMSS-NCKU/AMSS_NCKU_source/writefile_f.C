#include <stdio.h>
#include <string.h>
#include <string>
#include <stdlib.h>
#include <thread>   // 新增：线程库
#include <vector>   // 新增：容器库
#include "macrodef.h"

// 这是一个内部的写盘函数，由后台线程执行
void perform_async_write(std::string filename, std::vector<double> data) {
    FILE *fp = fopen(filename.c_str(), "wb");
    if (fp != NULL) {
        fwrite(data.data(), sizeof(double), data.size(), fp);
        fclose(fp);
    }
}

extern "C"
{
#ifdef fortran1
    void writefile_f
#endif
#ifdef fortran2
    void WRITEFILE_F
#endif
#ifdef fortran3
    void writefile_f_
#endif
    (int &filetag, double *matrix, int &msize)
    {
        char fname[256];
        char ftag[32];
        sprintf(ftag, "%d", filetag);
        strcpy(fname, "matrix_f.out");
        strcat(fname, ftag);

        // 1. 关键步骤：在主线程中快速拷贝数据
        // 因为主程序后续会修改 matrix 指向的内存，所以必须先拷贝一份快照
        std::vector<double> data_snapshot(matrix, matrix + msize);
        std::string filename_str(fname);

        // 2. 启动后台线程进行真正的磁盘写入
        // detach() 让线程在后台自主运行，主程序不等待其结束
        std::thread([filename_str, data_snapshot]() {
            FILE *fp = fopen(filename_str.c_str(), "wb");
            if (fp) {
                fwrite(data_snapshot.data(), sizeof(double), data_snapshot.size(), fp);
                fclose(fp);
            } else {
                printf("Error: Could not open file %s for async writing.\n", filename_str.c_str());
            }
        }).detach();

        // 3. 主线程立刻返回，继续黑洞演化计算！
    }
}