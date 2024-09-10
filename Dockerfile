FROM ubuntu:22.04

# Authors Jean Iaquinta
# Contact jeani@uio.no
# Version v1.0.0
#
# This is a definition file to build FSL using a base container image with Ubuntu20.04 
# It is the responsibility of the user to:
#                 - register on https://fsl.fmrib.ox.ac.uk/fsldownloads_registration
#                 - read and accept the terms of the FSL software License 
#                 - download locally fslinstaller.py (and place it in the same folder as this Dockerfile)

# Install system dependencies, FSL installer dependencies, OpenGL, and set up locales and CA certificates
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bc \
    ca-certificates \
    csh \
    dc \
    libfile-copy-recursive-perl \
    libglu1-mesa \
    libgl1-mesa-glx \
    libice6 \
    libsm6 \
    libxext6 \
    libxmu6 \
    libxt6 \
    locales \
    micro \
    procps \
    python3 \
    python3-pip \
    tcsh \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8 && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set locale environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Copy FSL installer script to the container
COPY ./fslinstaller.py /opt/uio/fslinstaller.py

# Run the FSL installer script
RUN cd /opt/uio && \
    python3 /opt/uio/fslinstaller.py -d /opt/uio/fsl --skip_registration && \
    rm /opt/uio/fslinstaller.py

# Set up FSL environment directly in the Dockerfile
ENV FSLDIR=/opt/uio/fsl \
    PATH=/opt/uio/fsl/bin:$PATH \
    FSLOUTPUTTYPE=NIFTI_GZ \
    FSLMULTIFILEQUIT=TRUE \
    FSLTCLSH=/opt/uio/fsl/bin/fsltclsh \
    FSLWISH=/opt/uio/fsl/bin/fslwish

# Default user environment variable
ENV USER=defaultuser

ENTRYPOINT [ "sh", "-c", ". /opt/uio/fsl/etc/fslconf/fsl.sh && /bin/bash" ]
