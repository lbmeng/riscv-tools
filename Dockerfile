# Use Ubuntu 18.04
FROM ubuntu:bionic
MAINTAINER Bin Meng <bmeng.cn@gmail.com>
LABEL Description="This image is for building various tools needed for RISC-V development"

# Make sure apt is happy
ENV DEBIAN_FRONTEND=noninteractive

# Update and install things from apt now
RUN apt-get update && apt-get install -y \
	git \
	sudo \
	autoconf \
	automake \
	autotools-dev \
	curl \
	python3 \
	libmpc-dev \
	libmpfr-dev \
	libgmp-dev gawk \
	build-essential \
	bison \
	flex \
	texinfo \
	gperf \
	libtool \
	patchutils \
	bc \
	zlib1g-dev \
	libexpat-dev \
	pkg-config \
	libglib2.0-dev \
	libfdt-dev \
	libpixman-1-dev \
	&& rm -rf /var/lib/apt/lists/*

# Build RISC-V toolchains
RUN git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain && \
	cd /tmp/riscv-gnu-toolchain && \
	git submodule update --init riscv-binutils && \
	git submodule update --init riscv-gcc && \
	git submodule update --init riscv-gdb && \
	git submodule update --init riscv-glibc && \
	./configure --prefix=/opt/riscv --enable-multilib && \
	make -j$(nproc) linux && \
	rm -rf /tmp/riscv-gnu-toolchain

# Build QEMU RISC-V
RUN git clone git://git.qemu.org/qemu.git /tmp/qemu && \
	cd /tmp/qemu && \
	git checkout v5.1.0 && \
	./configure --prefix=/opt/qemu --target-list="riscv32-linux-user,riscv32-softmmu,riscv64-linux-user,riscv64-softmmu" && \
	make -j$(nproc) all install && \
	rm -rf /tmp/qemu

# Create our user/group
RUN echo riscv ALL=NOPASSWD: ALL > /etc/sudoers.d/riscv
RUN useradd -m -U riscv
USER riscv:riscv

# Append the toolchain path
ENV PATH $PATH:/opt/riscv/bin:/opt/qemu/bin
