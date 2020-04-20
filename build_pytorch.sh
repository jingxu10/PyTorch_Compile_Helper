#!/bin/bash

VENV_ROOT=../../venvs
VENV_NAME=venv_pytorch_tacotron2_src_py37
GIT_REPO=https://github.com/pytorch/pytorch.git
COMMIT_TORCH=v1.4
# COMMIT_TORCHVISION=40c99ea
SRC_ROOT=..
SRC_FOLDER=$(echo ${GIT_REPO} | rev | cut -d '/' -f 1 | rev | cut -d '.' -f 1)
# CLANG_ROOT=/usr/lib/llvm-8

if [ ! -z $CLANG_ROOT ]; then
    export CC=$CLANG_ROOT/bin/clang
    export CXX=$CLANG_ROOT/bin/clang++
    export PATH=$CLANG_ROOT/bin:$PATH
    export LD_LIBRARY_PATH=$CLANG_ROOT/lib
    export CPATH=$CLANG_ROOT/include
fi

function get_commit_id() {
    local commit=
    while IFS= read -r line
    do
        if [[ $line == "*"* ]]; then
            commit=$(echo "$line" | cut -c2- | xargs)
            if [[ $commit == "(HEAD"* ]]; then
                commit=$(echo "$commit" | cut -d ' ' -f 4 | cut -c-7)
            fi
        fi
    done <<< $(git branch)
    echo $commit
}

ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

MODE=0
which conda > /dev/null
if [[ $? == 0 ]]; then
    conda env list | grep ${VENV_NAME} > /dev/null
    if [[ $? != 0 ]]; then
        yes | conda create -n ${VENV_NAME} python=3.7
    fi
else
    MODE=1
fi

set -e
if [[ $MODE == 0 ]]; then
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate ${VENV_NAME}
    yes | conda install numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing psutil
    export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
else
    if [[ ! -d ${VENV_ROOT} ]]; then
        mkdir ${VENV_ROOT}
    fi
    cd ${VENV_ROOT}
    if [[ ! -d ${VENV_NAME} ]]; then
        python3.7 -m venv ${VENV_NAME}
    fi
    source ./${VENV_NAME}/bin/activate
    pip install --upgrade pip
    pip install scikit-build
    pip install numpy ninja pyyaml mkl mkl-include setuptools cmake cffi
    pip install psutil
    export CMAKE_PREFIX_PATH=${VENV_ROOT}/${VENV_NAME}
fi

cd $ROOT
if [[ ! -d ${SRC_ROOT} ]]; then
    mkdir ${SRC_ROOT}
fi
cd ${SRC_ROOT}
if [[ ! -d ${SRC_FOLDER} ]]; then
    echo "clone PyTorch from ${GIT_REPO}"
    git clone ${GIT_REPO} ${SRC_FOLDER}
fi
if [[ ! -d vision ]]; then
    echo "clone TorchVision from official git repo"
    git clone https://github.com/pytorch/vision.git
fi
cd ${SRC_FOLDER}
if [ ! -z ${COMMIT_TORCH} ]; then
    commit=$(get_commit_id)
    if [[ $commit != ${COMMIT_TORCH} ]]; then
        echo "checkout PyTorch commit ${COMMIT_TORCH}"
        git checkout ${COMMIT_TORCH}
    else
        echo "Already commit ${COMMIT_TORCH}"
    fi
fi
python setup.py clean
git submodule sync
git submodule update --init --recursive
python setup.py install
cd ../vision
if [ ! -z ${COMMIT_TORCHVISION} ]; then
    commit=$(get_commit_id)
    if [[ $commit != ${COMMIT_TORCHVISION} ]]; then
        echo "checkout TorchVision commit ${COMMIT_TORCHVISION}"
        git checkout ${COMMIT_TORCHVISION}
    else
        echo "Already commit ${COMMIT_TORCHVISION}"
    fi
fi
python setup.py clean
python setup.py install

if [[ $MODE == 0 ]]; then
    conda deactivate
else
    pip install 'Pillow<7.0.0'
    deactivate
fi
