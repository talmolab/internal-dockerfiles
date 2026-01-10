# Directly from a cuda built image.
FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

LABEL maintainer="Scott Yang <scyang@salk.edu>"

USER root

RUN apt clean
RUN apt update


RUN apt update --yes && apt install --yes build-essential
RUN apt-get update && apt-get install -y openssh-server

# use tini instead of init
ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# Install all necessary packages in one step and remove apt cache.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        openssh-server \
        wget \
        curl \
        git \
        screen \
        cmake \
        vim \
        ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Madrona related
RUN apt update && \
    apt install -y --no-install-recommends libx11-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    mesa-common-dev

# EGL and OpenGL drivers for MuJoCo rendering
RUN apt-get update && apt-get install -y \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libglew-dev \
    libglfw3 \
    libglfw3-dev \
    libosmesa6-dev \
    patchelf && \
    rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Create mimic-mjx uv venv (packages installed post-init for flexibility)
WORKDIR /root
RUN uv venv /root/mimic-mjx --python 3.12

ENV VIRTUAL_ENV="/root/mimic-mjx"
ENV PATH="/root/mimic-mjx/bin:${PATH}"

# Install zsh and zsh-syntax-highlighting
RUN apt-get update && apt-get install -y zsh zsh-syntax-highlighting && \
    rm -rf /var/lib/apt/lists/*

# Configure zsh prompt style and enable syntax highlighting
RUN echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /root/.zshrc && \
    echo 'PROMPT="%F{green}%n@%m%f %F{blue}%~%f %% "' >> /root/.zshrc

# Set up environment activation in shell profiles (important, run this after the PROMPT to have env indication)
RUN echo 'source /root/mimic-mjx/bin/activate' >> /root/.bashrc && \
    echo 'source /root/mimic-mjx/bin/activate' >> /root/.zshrc

# Install Claude Code (requires Node.js)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @anthropic-ai/claude-code && \
    rm -rf /var/lib/apt/lists/*


# Install conda (without init to let uv env be default)
RUN curl -fsSL --compressed https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o "Miniforge3-Linux-x86_64.sh" && \
    chmod +x "Miniforge3-Linux-x86_64.sh" && \
    bash "Miniforge3-Linux-x86_64.sh" -b -p "/root/miniforge3" && \
    rm "Miniforge3-Linux-x86_64.sh" && \
    /root/miniforge3/bin/conda clean --all -y

# Add conda to path (available but not auto-activated)
ENV PATH="/root/miniforge3/bin:${PATH}"