FROM ghcr.io/ucsd-ets/scipy-ml-notebook:2024.2-stable

LABEL maintainer="Scott <yuy004@ucsd.edu>"

# Fix DL4006
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt clean
RUN apt update


RUN apt update --yes && apt install --yes build-essential
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]


# TODO:
# install conda

# install env COPY + RUN

# add conda to path

# install git

ENV PATH "${CONDA_DIR}/envs/${conda_env}/bin:${PATH}"

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

USER root