FROM ubuntu:21.10 AS builder
COPY busybox.config .
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
        ca-certificates \
        git \
        make \
        gcc                       libc6-dev \
        gcc-arm-linux-gnueabi     libc6-dev-armel-cross \
        gcc-aarch64-linux-gnu     libc6-dev-arm64-cross \
        gcc-powerpc64le-linux-gnu libc6-dev-ppc64el-cross \
        gcc-riscv64-linux-gnu     libc6-dev-riscv64-cross \
    && git clone --depth 1 -b 1_30_1 https://git.busybox.net/busybox/ \
    && mv busybox.config busybox/.config \
    && cd busybox \
    && make                                      -j$(nproc) busybox && mv busybox ../busybox-x86_64 \
    && make CROSS_COMPILE=arm-linux-gnueabi-     -j$(nproc) busybox && mv busybox ../busybox-arm \
    && make CROSS_COMPILE=aarch64-linux-gnu-     -j$(nproc) busybox && mv busybox ../busybox-arm64 \
    && make CROSS_COMPILE=powerpc64le-linux-gnu- -j$(nproc) busybox && mv busybox ../busybox-ppc64le \
    && make CROSS_COMPILE=riscv64-linux-gnu-     -j$(nproc) busybox && mv busybox ../busybox-riscv64

FROM ubuntu:21.10
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        git \
        file \
        bc \
        make \
        flex \
        bison \
        ccache \
        libelf-dev \
        gcc                       libc6-dev \
        gcc-arm-linux-gnueabi     libc6-dev-armel-cross \
        gcc-aarch64-linux-gnu     libc6-dev-arm64-cross \
        gcc-powerpc64le-linux-gnu libc6-dev-ppc64el-cross \
        gcc-riscv64-linux-gnu     libc6-dev-riscv64-cross \
        lzop \
        llvm \
        clang \
        lld \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-ppc \
        qemu-system-riscv64 \
        opensbi \
        python3 \
    && rm -r /var/lib/apt/lists/* \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
        -y \
        --no-modify-path \
        --default-toolchain 1.62.0 \
        --profile minimal \
        --component rust-src \
        --component rustfmt \
        --component clippy \
    && $HOME/.cargo/bin/cargo install --locked --version 0.56.0 bindgen \
    && rm -r $HOME/.cargo/registry
COPY --from=builder busybox-* /root/
