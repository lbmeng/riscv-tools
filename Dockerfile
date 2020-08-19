# Use Ubuntu 18.04
FROM ubuntu:bionic
MAINTAINER Bin Meng <bmeng.cn@gmail.com>
LABEL Description="This image is for building various tools needed for RISC-V development"

# Make sure apt is happy
ENV DEBIAN_FRONTEND=noninteractive

# Update and install things from apt now
RUN apt-get update && apt-get install -y \
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
	libexpat-dev

# Build RISC-V toolchains
RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain && \
	cd /tmp/riscv-gnu-toolchain && \
	./configure --prefix=/opt/riscv --enable-multilib && \
	make linux && \
	rm -rf /tmp/riscv-gnu-toolchain

# Create our user/group
RUN echo riscv ALL=NOPASSWD: ALL > /etc/sudoers.d/riscv
RUN useradd -m -U riscv
USER riscv:riscv

# Append the toolchain path
ENV PATH $PATH:/opt/riscv/bin
