FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Douala

# X11 runtime tweak for Docker
ENV QT_X11_NO_MITSHM=1

# Base tools
RUN apt update && apt install -y \
    curl \
    gnupg2 \
    lsb-release \
    git \
    build-essential \
    cmake \
    python3-pip \
    locales \
    mesa-utils \
    x11-apps \
    software-properties-common \
    pkg-config \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Qt/X11 runtime libs for CloudCompare GUI
RUN apt update && apt install -y \
    libxkbcommon-x11-0 \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-util1 \
    libgl1-mesa-glx \
    libglu1-mesa \
    libxkbcommon-x11-0 \
    libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

# Prefer XCB platform (works with Xorg/Xwayland)
ENV QT_QPA_PLATFORM=xcb

# Install CloudCompare dependencies
RUN apt update && apt install -y \
    libcgal-dev \
    libxslt-dev \
    libzstd-dev \
    libtiff-dev \
    libgdal-dev \
    liblas-dev \
    libboost-all-dev \
    libflann-dev \
    libpcl-dev \
    libvtk9-dev \
    qtbase5-dev \
    qt5-qmake \
    libqt5svg5 \
    libqt5opengl5 \
    && rm -rf /var/lib/apt/lists/*

# Download and build CloudCompare from source
RUN mkdir -p /opt/cloudcompare && cd /opt/cloudcompare && \
    git clone --depth 1 https://github.com/CloudCompare/CloudCompare.git . && \
    mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_QPCL=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_VTK_NANOVIS=OFF \
    && make -j$(nproc) && \
    make install && \
    ldconfig

# Headless GUI support (VNC via noVNC)
RUN apt update && apt install -y \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Start script for VNC/noVNC session
RUN mkdir -p /usr/local/bin
ADD start_vnc.sh /usr/local/bin/start_vnc.sh
RUN chmod +x /usr/local/bin/start_vnc.sh

# Create data directory for mounting
RUN mkdir -p /data

EXPOSE 6080

# Auto-source environment if needed
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> /root/.bashrc

CMD ["bash"]
