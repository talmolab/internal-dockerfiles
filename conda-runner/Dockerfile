# Base image for defining generic batch runners for Python scripts.
#
# This is heavily based on Jupyter Docker Stacks base-notebook:
# https://github.com/jupyter/docker-stacks/tree/main/base-notebook

# Ubuntu 20.04 (focal)
# https://hub.docker.com/_/ubuntu/?tab=tags&name=focal
ARG ROOT_CONTAINER=ubuntu:focal

FROM $ROOT_CONTAINER

LABEL maintainer="Talmo Pereira <talmo@salk.edu>"
ARG RUNNER_USER="runner"
ARG RUNNER_UID="1000"
ARG RUNNER_GID="100"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    fonts-liberation \
    locales \
    # - pandoc is used to convert notebooks to html files
    #   it's not present in arm64 ubuntu image, so we install it here
    pandoc \
    # - run-one - a wrapper script that runs no more
    #   than one unique  instance  of  some  command with a unique set of arguments,
    #   we use `run-one-constantly` to support `RESTARTABLE` option
    run-one \
    sudo \
    # - tini is installed as a helpful container entrypoint that reaps zombie
    #   processes and such of the actual executable we want to start, see
    #   https://github.com/krallin/tini#why-tini for details.
    tini \
    build-essential \
    # ImportError: libGL.so.1: cannot open shared object file: No such file or directory
    libgl1 \
    # ImportError: libgthread-2.0.so.0: cannot open shared object file: No such file or directory
    libglib2.0-0 \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    RUNNER_USER="${RUNNER_USER}" \
    RUNNER_UID=${RUNNER_UID} \
    RUNNER_GID=${RUNNER_GID} \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH="${CONDA_DIR}/bin:${PATH}" \
    HOME="/home/${RUNNER_USER}"

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Copy a script for installing environments
COPY install-environment /usr/local/bin/install-environment
RUN chmod a+rx /usr/local/bin/install-environment

# Enable prompt color in the skeleton .bashrc before creating the default RUNNER_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    # Add call to conda init script see https://stackoverflow.com/a/58081608/4413446
    echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc

# Create RUNNER_USER user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -l -m -s /bin/bash -N -u "${RUNNER_UID}" "${RUNNER_USER}" && \
    mkdir -p "${CONDA_DIR}" && \
    chown "${RUNNER_USER}:${RUNNER_GID}" "${CONDA_DIR}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "${HOME}" && \
    fix-permissions "${CONDA_DIR}"

USER ${RUNNER_UID}

# Pin python version here, or set it to "default"
ARG PYTHON_VERSION=3.10

# Download and install Micromamba, and initialize Conda prefix.
#   <https://github.com/mamba-org/mamba#micromamba>
#   Similar projects using Micromamba:
#     - Micromamba-Docker: <https://github.com/mamba-org/micromamba-docker>
#     - repo2docker: <https://github.com/jupyterhub/repo2docker>
# Install Python, Mamba, Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files and remove Micromamba
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
COPY --chown="${RUNNER_UID}:${RUNNER_GID}" initial-condarc "${CONDA_DIR}/.condarc"
WORKDIR /tmp
RUN set -x && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
    # Should be simpler, see <https://github.com/mamba-org/mamba/issues/1437>
    arch="64"; \
    fi && \
    wget -qO /tmp/micromamba.tar.bz2 \
    "https://micromamba.snakepit.net/api/micromamba/linux-${arch}/latest" && \
    tar -xvjf /tmp/micromamba.tar.bz2 --strip-components=1 bin/micromamba && \
    rm /tmp/micromamba.tar.bz2 && \
    PYTHON_SPECIFIER="python=${PYTHON_VERSION}" && \
    if [[ "${PYTHON_VERSION}" == "default" ]]; then PYTHON_SPECIFIER="python"; fi && \
    # Install the packages
    ./micromamba install \
    --root-prefix="${CONDA_DIR}" \
    --prefix="${CONDA_DIR}" \
    --yes \
    "${PYTHON_SPECIFIER}" \
    'mamba' && \
    rm micromamba && \
    # Pin major.minor version of python
    mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba clean --all -f -y && \
    rm -rf "/home/${RUNNER_USER}/.cache/yarn" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${RUNNER_USER}"

#COPY --chown="${RUNNER_UID}:${RUNNER_GID}" enable-conda.sh .
#SHELL ["./enable-conda.sh", "/bin/bash", "-c"]

# Set up environments
COPY --chown="${RUNNER_UID}:${RUNNER_GID}" environments "/home/${RUNNER_USER}/environments"
RUN install-environment "/home/${RUNNER_USER}/environments/tf-extras.yml" "tf-extras"

#ENV CONDA_DEFAULT_ENV="tf-extras"

ENV RUNNER_CONDA_ENV="tf-extras"
ENV RUNNER_CMD="python -V"

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-image.sh"]

# Copy local files as late as possible to avoid cache busting
COPY start-image.sh /usr/local/bin/

# Switch back to user to avoid accidental container runs as root
USER ${RUNNER_UID}

WORKDIR "${HOME}"