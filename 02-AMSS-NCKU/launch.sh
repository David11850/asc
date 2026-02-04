#!/bin/bash
# 1. 只有主进程负责基建
if [ "$SLURM_PROCID" -eq 0 ]; then
    echo "Task 0: Cleaning and extracting..."
    rm -rf /dev/shm/ext
    mkdir -p /dev/shm/ext
    tar -xf /tmp/super_bundle.tar -C /dev/shm/ext
fi

# 2. 等待文件就绪
sleep 5

# 3. 环境适配
cd /dev/shm/ext || exit
ln -sf AMSS_NCKU_Input.py Input.py

# 自动寻找 MPI 根目录
REAL_ROOT=$(find /dev/shm/ext -name 'help-mpi-runtime.txt' | head -n 1 | sed 's|/share/openmpi/help-mpi-runtime.txt||')

if [ -z "$REAL_ROOT" ]; then
    echo "Node $(hostname): ERROR - MPI help files not found!"
    exit 1
fi

export OPAL_PREFIX=$REAL_ROOT
export PATH=$REAL_ROOT/bin:$PATH
export LD_LIBRARY_PATH=$REAL_ROOT/lib:/opt/rocm-7.1.1/lib:$LD_LIBRARY_PATH

# 4. 真正点火
echo "Node $(hostname): Launching ABE..."
stdbuf -oL -eL ./ABE