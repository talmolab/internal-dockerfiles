# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/tensorflow-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix DL4006
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt update --yes && apt install --yes build-essential

USER ${NB_UID}

# Install Mamba gator
RUN mamba install --quiet --yes \
    'conda-forge::mamba_gator' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#add-a-python-3-x-environment
ARG conda_env=python37
ARG py_ver=3.7

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

# prepend conda environment to path
ENV PATH "${CONDA_DIR}/envs/${conda_env}/bin:${PATH}"

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

USER root

### MUJOCO STUFF
RUN mkdir -p /home/jovyan/.mujoco \
&& wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
&& tar -xf mujoco.tar.gz -C /home/jovyan/.mujoco \
&& rm mujoco.tar.gz

ENV LD_LIBRARY_PATH=/home/jovyan/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}

RUN mkdir -p /home/jovyan/.mujoco \
&& wget https://github.com/deepmind/mujoco/releases/download/2.1.1/mujoco-2.1.1-linux-x86_64.tar.gz -O mujoco.tar.gz \
&& tar -xf mujoco.tar.gz -C /home/jovyan/.mujoco \
&& rm mujoco.tar.gz

ENV LD_LIBRARY_PATH=/home/jovyan/.mujoco/mujoco-2.1.1/bin:${LD_LIBRARY_PATH}


RUN wget https://roboti.us/download/mujoco200_linux.zip -O mujoco.zip \
&& unzip mujoco.zip -d /home/jovyan/.mujoco \
&& rm mujoco.zip

RUN cp -r /home/jovyan/.mujoco/mujoco200_linux/ /home/jovyan/.mujoco/mujoco200/

ENV LD_LIBRARY_PATH=/home/jovyan/.mujoco/mujoco200/bin:${LD_LIBRARY_PATH}

RUN wget https://roboti.us/file/mjkey.txt -O mjkey.txt \
&& mv mjkey.txt /home/jovyan/.mujoco/mjkey.txt

ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

RUN sudo apt update && sudo apt install libosmesa6-dev libgl1-mesa-glx libglfw3 patchelf -y


# these settings are for remote server stuff
ENV MUJOCO_GL=osmesa
