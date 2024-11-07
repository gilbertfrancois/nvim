#!/usr/bin/env bash
set -xe

NVIM_VERSION="0.10.2"
NODE_VERSION="22.11.0" # NodeJS LTS
FZF_VERSION="0.56.0"

NVIM_CONFIG_DIR=${HOME}/.config/nvim
NVIM_SHARE_DIR=${HOME}/.local/share/nvim
NVIM_STATE_DIR=${HOME}/.local/state/nvim
NVIM_CACHE_DIR=${HOME}/.cache/nvim
NVIM_LIB_DIR=${NVIM_SHARE_DIR}/lib

if ! type "sudo" >/dev/null; then
    echo "No sudo command found."
    SUDO=""
else
    echo "sudo command found."
    SUDO=sudo
fi

function reset_config_dir {
    echo "--- (Re)setting Neovim config folder."
    rm -rf ${NVIM_SHARE_DIR}
    rm -rf ${NVIM_STATE_DIR}
    rm -rf ${NVIM_CACHE_DIR}
    if [[ $(uname -s) == "Linux" ]]; then
        ${SUDO} rm -rf /opt/nvim
        ${SUDO} rm -rf /usr/local/bin/nvim /usr/local/bin/nvim.appimage
    fi
}

function init_config_dir {
    mkdir -p ${HOME}/.config
    mkdir -p ${NVIM_SHARE_DIR}
    mkdir -p ${NVIM_LIB_DIR}
}

function install_deps {
    echo "--- Installing additional dependencies."
    # TODO: Install version for ARMv8
    if [[ $(uname -s) == "Linux" ]]; then
        echo "No additional dependencies to install on Linux."
        ${SUDO} apt update
        ${SUDO} apt install -y git wget build-essential unzip
    elif [[ $(uname -s) == "Darwin" ]]; then
        echo "No additional dependencies to install on macOS."
    fi
}

function compile_neovim {
    echo "--- Compiling Neovim."
    if [[ $(uname -s) == "Linux" ]]; then
        ${SUDO} apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
    elif [[ $(uname -s) == "Darwin" ]]; then
        brew reinstall ninja gettext libtool autoconf automake cmake pkg-config unzip
    fi
    pushd /tmp
    git clone https://github.com/neovim/neovim.git --branch v${NVIM_VERSION} --depth 1
    cd neovim
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH=/opt/nvim"
    ${SUDO} make install
    popd
    rm -rf /tmp/file.txt
}

function install_neovim {
    echo "--- Installing Neovim."
    if [[ $(uname -s) == "Linux" ]]; then
        if [[ $(uname -m) == "x86_64" ]]; then
            ${SUDO} rm -rf /opt/nvim
            cd /tmp
            wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz
            tar zxvf nvim-linux64.tar.gz
            ${SUDO} mv nvim-linux64 /opt/nvim
            ${SUDO} rm -rf nvim-linux64.tar.gz
        elif [[ $(uname -m) == "aarch64" ]]; then
            ${SUDO} apt install -y libuv1 lua-luv-dev lua-lpeg-dev
            compile_neovim
        elif [[ $(uname -m) == "armv7l" ]]; then
            ${SUDO} apt install -y libuv1 lua-luv-dev lua-lpeg-dev
            compile_neovim
        fi
    elif [[ $(uname -s) == "Darwin" ]]; then
        brew update
        brew reinstall neovim wget
    else
        echo "Unsupported OS."
    fi
}

function install_python {
    echo "--- Installing python environment for NeoVim."
    if [[ $(uname -s) == "Linux" ]]; then
        ${SUDO} apt update
        ${SUDO} apt install -y python3-venv
    elif [[ $(uname -s) == "Darwin" ]]; then
        brew update
        brew reinstall python
    else
        echo "Unsupported OS."
    fi
    VENV_PATH="${NVIM_LIB_DIR}/python"
    rm -rf ${VENV_PATH}
    cd ${NVIM_LIB_DIR}
    python3 -m venv --copies ${VENV_PATH}
    source ${VENV_PATH}/bin/activate
    # Avoid problems due to outdated pip.
    pip install --upgrade pip
    pip install setuptools wheel
    # Install neovim extension
    pip install neovim
}

function check_libc_version {
    if [[ $(uname -s) == "Darwin" ]]; then
        return
    fi
    required_version="2.28"
    # Extract version from ldd output
    ldd_output=$(ldd --version)
    current_version=$(echo "$ldd_output" | grep -oP '\b\d+\.\d+\b' | head -1)
    version_compare() {
        local version1=(${1//./ })
        local version2=(${2//./ })
        for ((i = 0; i < ${#version1[@]}; i++)); do
            if [[ ${version1[i]} -lt ${version2[i]} ]]; then
                return 1
            elif [[ ${version1[i]} -ge ${version2[i]} ]]; then
                return 0
            fi
        done
        return 0
    }
    if version_compare "$current_version" "$required_version"; then
        echo "Current version $current_version is high enough."
    else
        echo "Current libc version $current_version is not high enough for NodeJS $NODE_VERSION. Lowering NodeJS version to 16."
        NODE_VERSION="16.20.2" # NodeJS for Ubuntu 18.04
    fi
}

function install_node {
    check_libc_version
    echo "Using NodeJS version: ${NODE_VERSION}"
    INSTALL_DIR=${NVIM_LIB_DIR}
    echo "--- Installing nodejs."
    if [[ $(uname -s) == "Linux" ]]; then
        NODE_OS="linux"
        NODE_EXTENSION="tar.gz"
        if [[ $(uname -m) == "x86_64" ]]; then
            NODE_ARCH="x64"
        elif [[ $(uname -m) == "aarch64" ]]; then
            if [[ $(getconf LONG_BIT) == "32" ]]; then
                NODE_ARCH="armv7l"
            else
                NODE_ARCH="arm64"
            fi
        elif [[ $(uname -m) == "armv7l" ]]; then
            FZF_ARCH="armv7l"
        fi
    elif [[ $(uname -s) == "Darwin" ]]; then
        NODE_OS="darwin"
        NODE_EXTENSION="tar.gz"
        if [[ $(uname -m) == "x86_64" ]]; then
            NODE_ARCH="x64"
        elif [[ $(uname -m) == "arm64" ]]; then
            NODE_ARCH="arm64"
        fi
    fi
    cd /tmp
    rm -rf node*
    rm -rf ${NVIM_LIB_DIR}/node*
    wget https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-${NODE_OS}-${NODE_ARCH}.${NODE_EXTENSION}
    echo "node-v${NODE_VERSION}-${NODE_OS}-${NODE_ARCH}.${NODE_EXTENSION}"
    tar -xvf node-v${NODE_VERSION}-${NODE_OS}-${NODE_ARCH}.${NODE_EXTENSION}
    mv node-v${NODE_VERSION}-${NODE_OS}-${NODE_ARCH} ${NVIM_LIB_DIR}
    ln -s ${NVIM_LIB_DIR}/node-v${NODE_VERSION}-${NODE_OS}-${NODE_ARCH} ${NVIM_LIB_DIR}/node
    export PATH=${NVIM_LIB_DIR}/node/bin:$PATH

    ${NVIM_LIB_DIR}/node/bin/npm install --location=global --prefix ${NVIM_LIB_DIR}/node neovim
}

function install_fzf {
    echo "--- Installing FZF."
    if [[ $(uname -s) == "Linux" ]]; then
        FZF_OS="linux"
        FZF_EXTENSION="tar.gz"
        if [[ $(uname -m) == "x86_64" ]]; then
            FZF_ARCH="amd64"
        elif [[ $(uname -m) == "aarch64" ]]; then
            FZF_ARCH="arm64"
        elif [[ $(uname -m) == "armv7l" ]]; then
            FZF_ARCH="armv7"
        fi
        cd /tmp
        rm -rf ${FZF_VERSION}/fzf-${FZF_VERSION}-${FZF_OS}_${FZF_ARCH}.${FZF_EXTENSION}
        rm -rf fzf
        wget https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-${FZF_OS}_${FZF_ARCH}.${FZF_EXTENSION}
        tar zxvf fzf-${FZF_VERSION}-${FZF_OS}_${FZF_ARCH}.tar.gz
        ${SUDO} cp fzf /usr/local/bin
    elif [[ $(uname -s) == "Darwin" ]]; then
        brew reinstall fzf
    fi
}

function __os_template {
    if [[ $(uname -s) == "Linux" ]]; then
        OS="linux"
    elif [[ $(uname -s) == "Darwin" ]]; then
        OS="darwin"
    else
        OS=""
        echo "Unsupported OS."
    fi
    if [[ $(uname -m) == "x86_64" ]]; then
        ARCH="x86_64"
    elif [[ $(uname -m) == "aarch64" ]]; then
        ARCH="aarch64"
    elif [[ $(uname -m) == "armv7l" ]]; then
        ARCH="armv71"
    else
        ARCH=""
        echo "Unsupported architecture"
    fi
}

function install_alias_in_file {
    FILE_PATH="${HOME}/.${1}"
    ALIAS="alias nvim='PATH=${HOME}/.local/share/nvim/lib/python/bin:${HOME}/.local/share/nvim/lib/node/bin:/opt/nvim/bin:\${PATH} nvim'"
    if [ -f "${FILE_PATH}" ]; then
        if grep -q "alias nvim" ${FILE_PATH}; then
            echo "  - Alias for neovim already added to ${FILE_PATH}."
        else
            echo ${ALIAS} >>${FILE_PATH}
            echo "  - Alias for neovim added to ${FILE_PATH}."
        fi
    fi
}

function install_alias {
    install_alias_in_file bashrc
    install_alias_in_file bash_profile
    install_alias_in_file profile
    install_alias_in_file zshrc
}

reset_config_dir
init_config_dir
install_fzf
install_neovim
# install_python
check_libc_version
# install_node
install_alias
source ${HOME}/.profile
