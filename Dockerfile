# [Build and install in build image ]----------------------------------

FROM ubuntu:22.04 AS build

WORKDIR /src

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    unzip \
    wget \
    xz-utils

WORKDIR /root/.config/nvim

COPY . /root/.config/nvim/

RUN /root/.config/nvim/install.sh

# [Install in clean image] --------------------------------------------

FROM ubuntu:22.04

COPY . /root/.config/nvim/

RUN mkdir -p /root/.config/nvim
RUN mkdir -p /root/.local/share/nvim
COPY --from=build /opt/nvim /opt/nvim
COPY --from=build /root/.local/share/nvim /root/.local/share/nvim
