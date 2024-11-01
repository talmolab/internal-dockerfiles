FROM ubuntu:jammy

LABEL maintainer="Scott Yang<yuy004@ucsd.edu>"

USER root

RUN apt clean
RUN apt update


RUN apt update --yes && apt install --yes build-essential
RUN apt-get update && apt-get install -y openssh-server

# use tini instead of init
ENV TINI_VERSION v0.19.0
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


# TODO:
# install conda

RUN apt-get update

RUN apt-get install -y wget git && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Anaconda3-2024.06-1-Linux-x86_64.sh -b \
    && rm -f Anaconda3-2024.06-1-Linux-x86_64.sh


# need to run this line to add conda to PATH
ENV PATH "/root/anaconda3/bin:${PATH}"
RUN conda init bash \
    && . ~/.bashrc

# install env COPY + RUN
RUN mkdir ray
COPY ray ray
RUN conda env create -f ray/environment.yml