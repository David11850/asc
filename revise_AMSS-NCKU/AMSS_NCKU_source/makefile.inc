# ===========================================================
# ASC1606 (Zen4 + Conda + AOCL 5.2)
# 目标：利用 AOCL 深度加速数学运算，压榨 EPYC 9334 每一点性能
# ===========================================================

# --- 1. 显式路径硬编码 ---
CONDA_ENV_PATH = /home/ASC1606/miniconda3/envs/amss_env
MPI_PATH       = $(CONDA_ENV_PATH)
ROCM_PATH      = /opt/rocm-7.1.1
# [新增] AOCL 5.2 安装根路径
AOCL_ROOT      = /home/ASC1606/opt/aocl5.2/5.2.0/gcc

# --- 2. 编译器设置 ---
f90     = $(CONDA_ENV_PATH)/bin/mpif90
f77     = $(CONDA_ENV_PATH)/bin/mpif90
CC      = $(CONDA_ENV_PATH)/bin/mpicc
CXX     = $(CONDA_ENV_PATH)/bin/mpicxx
CLINKER = $(CONDA_ENV_PATH)/bin/mpif90

# --- 3. 针对 Zen4 (EPYC 9334) 的激进优化标志 ---
# -Ofast: 包含 -O3 和 -ffast-math，并启用更积极的数学合并
# -flto: 开启链接时优化，这对数值相对论这种多子程序的代码提速明显
OPT_FLAGS = -Ofast -march=znver4 -mtune=znver4 -mavx512f -mavx512dq -mavx512vl -mavx512bw -fno-math-errno -funroll-loops -flto -pthread

# C++/Fortran 参数保持 $(OPT_FLAGS)
CXXAPPFLAGS = $(OPT_FLAGS) -Wno-deprecated -Dfortran3 -Dnewc -I$(CONDA_ENV_PATH)/include -I$(AOCL_ROOT)/include
f90appflags = $(OPT_FLAGS) -cpp -ffree-form -ffree-line-length-none -fno-backtrace -I$(CONDA_ENV_PATH)/include -I$(AOCL_ROOT)/include
f77appflags = $(OPT_FLAGS) -cpp
cappflags   = $(OPT_FLAGS) -I$(CONDA_ENV_PATH)/include -I$(AOCL_ROOT)/include

# --- 4. 包含路径 (加入 AOCL Include) ---
filein = -I$(AOCL_ROOT)/include \
         -I$(CONDA_ENV_PATH)/include \
         -I$(MPI_PATH)/include \
         -I$(ROCM_PATH)/include \
         -I/usr/include

# --- 5. 链接库 (关键：拦截标准数学库) ---
# [修改点] 将 -L$(AOCL_ROOT)/lib 放在首位，并将 -laocl 放在 -lm 之前
# 这样链接器会优先从 AOCL 中找 sin/cos/exp
LDLIBS = -L$(AOCL_ROOT)/lib -Wl,-rpath,$(AOCL_ROOT)/lib \
         -L$(CONDA_ENV_PATH)/lib -Wl,-rpath,$(CONDA_ENV_PATH)/lib \
         -laocl \
         -lmpi -lgfortran -lpthread -lrt -ldl \
         -lstdc++ -lm

# --- 6. 其它设置 ---
LDFLAGS = $(OPT_FLAGS) -L$(AOCL_ROOT)/lib -L$(CONDA_ENV_PATH)/lib