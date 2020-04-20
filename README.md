# PyTorch_Compile_Helper

Do remember to edit Line 3 to 10, as the following, to run the script on your environment.
```bash
VENV_ROOT=             Root directory of your virtual environments
VENV_NAME=             Your desired name for this virtual environment
GIT_REPO=https://github.com/pytorch/pytorch.git
COMMIT_TORCH=          Branch or commit id of PyTorch source code, comment this line out to use Master branch
# COMMIT_TORCHVISION=  Branch or commit id of TorchVision source code, comment this line out to use Master branch
SRC_ROOT=              Root directory for PyTorch and TrochVision source codes
SRC_FOLDER=$(echo ${GIT_REPO} | rev | cut -d '/' -f 1 | rev | cut -d '.' -f 1)
# CLANG_ROOT=          Root directory of clang
```
