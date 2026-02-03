#include <stdio.h>
#include <string.h>
#include <string>
#include <stdlib.h>
#include <thread>
#include <vector>
#include "macrodef.h"

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
        
        // 建议：输出文件名加入进程号区分，防止 64 MPI 进程冲突
        strcpy(fname, "binary_output/matrix_f.out");
        strcat(fname, ftag);

        // 1. 在主线程内完成数据“快照”
        // Zen4 的内存带宽极高，这一步通常在微妙级完成
        std::vector<double> data_snapshot(matrix, matrix + msize);
        std::string filename_str(fname);

        // 2. 丢给后台线程处理 IO
        std::thread([filename_str, data_snapshot]() {
            FILE *fp = fopen(filename_str.c_str(), "wb");
            if (fp) {
                fwrite(data_snapshot.data(), sizeof(double), data_snapshot.size(), fp);
                fclose(fp);
            }
        }).detach();

        // 3. 立即返回，让主进程继续算下一步 RHS
    }
}