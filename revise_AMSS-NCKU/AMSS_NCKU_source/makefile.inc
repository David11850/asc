# ===========================================================
# ASC1606  (Zen4 + Conda )
# 目标：压榨 AMD EPYC 9334 性能，冲击 10H 以下
# ===========================================================

# --- 1. 显式路径硬编码 (锁死 Conda 环境) ---
CONDA_ENV_PATH = /home/ASC1606/miniconda3/envs/amss_env
MPI_PATH       = $(CONDA_ENV_PATH)
ROCM_PATH      = /opt/rocm-7.1.1

# --- 2. 编译器设置 (显式指向 Conda 包装器) ---
# 使用环境路径下的绝对路径，确保不调用系统 /usr/bin 里的旧版
f90     = $(CONDA_ENV_PATH)/bin/gfortran
f77     = $(CONDA_ENV_PATH)/bin/gfortran
CC      = $(CONDA_ENV_PATH)/bin/mpicc
CXX     = $(CONDA_ENV_PATH)/bin/mpicxx
CLINKER = $(CONDA_ENV_PATH)/bin/gfortran

# --- 3. 针对 Zen4 (EPYC 9334) 的激进优化标志 ---
# -march=znver4: 开启 Zen4 特有的 AVX-512, VNNI, bfloat16 等指令集
# -ffast-math: 极大提升浮点运算速度（数值相对论计算核心提速点）
# -flto: 开启链接时优化，消除跨文件调用开销
OPT_FLAGS = -O3 -march=znver4 -mavx512f -mavx512dq -mavx512vl -mavx512bw -ffast-math -fno-math-errno -funroll-loops -flto -pthread -fopenmp

# C++ 编译参数
CXXAPPFLAGS = $(OPT_FLAGS) -Wno-deprecated -Dfortran3 -Dnewc -I$(CONDA_ENV_PATH)/include

# Fortran 编译参数
f90appflags = $(OPT_FLAGS) -x f95-cpp-input -I$(CONDA_ENV_PATH)/include
f77appflags = $(OPT_FLAGS)

# C 编译参数
cappflags   = $(OPT_FLAGS) -I$(CONDA_ENV_PATH)/include

# --- 4. 包含路径 (显示指定 Conda 优先) ---
filein = -I$(CONDA_ENV_PATH)/include \
         -I$(MPI_PATH)/include \
         -I$(ROCM_PATH)/include \
         -I/usr/include

# --- 5. 链接库 (显示指定路径并强制链接) ---
# 显式指定 -L$(CONDA_ENV_PATH)/lib 确保链接 Conda 的动态库
LDLIBS = -L$(CONDA_ENV_PATH)/lib \
         -Wl,-rpath,$(CONDA_ENV_PATH)/lib \
         -lmpi -lgfortran -fopenmp -lpthread \
         $(ROCM_PATH)/lib/llvm/lib/libFortranRuntime.a \
         $(ROCM_PATH)/lib/llvm/lib/libFortranDecimal.a \
         -lstdc++ -lm

# --- 6. 其它设置 ---
LDFLAGS = $(OPT_FLAGS) -L$(CONDA_ENV_PATH)/lib