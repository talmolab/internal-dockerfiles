# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/tensorflow-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix DL4006
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && apt-get install --yes build-essential \
    git \
    libxrender1 \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libosmesa6-dev \
    xpra \
    patchelf \
    libglfw3-dev \
    libglfw3

USER ${NB_UID}

# Install Mamba gator
RUN mamba install --quiet --yes \
    'conda-forge::mamba_gator' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#add-a-python-3-x-environment
ARG conda_env=python39
ARG py_ver=3.9

# you can add additional libraries you want mamba to install by listing them below the first line and ending with "&& \"
# RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env}" python=${py_ver} ipython ipykernel && \
#    cudatoolkit=11.3.1 && \
#    cudnn=8.2.1 && \
#    mamba clean --all -f -y

# alternatively, you can comment out the lines above and uncomment those below
# if you'd prefer to use a YAML file present in the docker build context

COPY --chown=${NB_UID}:${NB_GID} environment.yml "/home/${NB_USER}/tmp/"
RUN cd "/home/${NB_USER}/tmp/" && \
    mamba env create -p "${CONDA_DIR}/envs/${conda_env}" -f environment.yml && \
    mamba clean --all -f -y


# create Python 3.x environment and link it to jupyter
RUN "${CONDA_DIR}/envs/${conda_env}/bin/python" -m ipykernel install --user --name="${conda_env}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# any additional pip installs can be added by uncommenting the following line
# RUN "${CONDA_DIR}/envs/${conda_env}/bin/pip" install tensorflow
RUN #"${CONDA_DIR}/envs/${conda_env}/bin/pip" install tensorflow-probability==0.16.0

# prepend conda environment to path
ENV PATH "${CONDA_DIR}/envs/${conda_env}/bin:${PATH}"
ENV LD_LIBRARY_PATH "${CONDA_DIR}/envs/${conda_env}/lib:${LD_LIBRARY_PATH}"

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

USER root