# ===========================================================
# ASC26 AMSS-NCKU 编译配置文件 (makefile.inc)
# 适配环境: Miniconda (amss_env) + AMD EPYC 9334 (Zen4)
# ===========================================================

# --- 1. 路径定义 ---
# 使用 CONDA_PREFIX 自动获取当前激活环境的路径 [cite: 491]
CONDA_ENV_PATH = $(HOME)/miniconda3/envs/amss_env
ROCM_PATH      = /opt/rocm-7.1.1
# MPI_PATH 指向 Conda 环境以使用你安装的 OpenMPI 5.0.8
MPI_PATH       = $(CONDA_ENV_PATH)

# --- 2. 编译器与链接器设置 ---
# 直接调用 Conda 环境中的编译器命令
f90     = gfortran
f77     = gfortran
CC      = mpicc
CXX     = mpicxx
# AMSS-NCKU 链接时建议使用 Fortran 编译器作为 Linker 以正确处理运行时库
CLINKER = gfortran

# --- 3. 编译标志 (针对 EPYC 9334 优化) ---
# -march=znver4: 针对 Zen4 架构优化 [cite: 477]
# -O3: 开启最高级性能优化 [cite: 361]
OPT_FLAGS = -O3 -march=znver4 -mavx512f -ffast-math -funroll-loops

# C++ 编译参数
CXXAPPFLAGS = $(OPT_FLAGS) -Wno-deprecated -Dfortran3 -Dnewc

# Fortran 编译参数 (-x f95-cpp-input 用于处理带预处理指令的 Fortran 文件)
f90appflags = $(OPT_FLAGS) -x f95-cpp-input
f77appflags = $(OPT_FLAGS)

# C 编译参数
cappflags   = $(OPT_FLAGS)

# --- 4. 包含路径 ---
# 确保编译器优先查找 Conda 环境和 ROCm 的头文件
filein = -I$(CONDA_ENV_PATH)/include \
         -I$(MPI_PATH)/include \
         -I$(ROCM_PATH)/include \
         -I/usr/include

# --- 5. 链接库  ---
# 使用 -L 指定 Conda 库路径，避免链接到错误的系统旧版 MPI [cite: 830]
LDLIBS = -L$(CONDA_ENV_PATH)/lib \
         -lmpi -lgfortran \
         $(ROCM_PATH)/lib/llvm/lib/libFortranRuntime.a \
         $(ROCM_PATH)/lib/llvm/lib/libFortranDecimal.a \
         -lstdc++ -lm

# --- 6. GPU 标志 (当前设为禁用) ---
# 组委会建议初赛仅使用 CPU 版本 [cite: 461, 929]
# CUDA_APP_FLAGS = -O3 --offload-arch=gfx1100 -Dfortran3 -Dnewc