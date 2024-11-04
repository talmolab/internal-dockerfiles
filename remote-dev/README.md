# Remote-dev Dockerfiles

This directory hosts the Dockerfiles that are used in Manticore's remote development environment using vscode. After specifying the image when creating a jobs, you can use vscode's remote development plugins to have the best developing experience alongside with powerful linting support and easy to access documentations.

## Tutorials

Those docker images are likely already built by Scott and are available on docker hub for direct use. You can find them in the following link [`scottyang17/remote-dev:<tags>`](https://hub.docker.com/r/scottyang17/remote-dev/tags). If you are unsure about which tags belongs to which image, contact [Scott](mailto:scyang@salk.edu) for more details. Should you want to build the image yourself, here is a brief step-by-step tutorial of how to build the image. 

To build the image, first clone this repository, and then `cd` into corresponding directory. I will use the `remote-dev/minimal` as an example.

```bash
git clone https://github.com/talmolab/internal-dockerfiles.git
cd internal-dockerfiles/remote-dev/minimal
```

Before building the docker image, you should install [docker](https://docs.docker.com/engine/install/) and start the daemon process on the background. To build the image, run

```bash
docker build -t <your_docker_hub_username>/<image_name>:<image_tag> .
```

Note: Yes, there is a `.` at the end fo the command to tell the docker to find the file in the current directory.

After successfully build the image, you can do a quick test run to test the image. For `remote-dev`, dry-run involves an extra step to setup the ssh servers. To run the image, execute the following command:

```bash
docker run -p <local_port>:22 <your_docker_hub_username>/<image_name>:<image_tag>
```

Optionally, if you want to pass GPU supports to the docker image, pass the following flag `--gpus all` **before -p and after docker run**. You might need to install [NVIDIA Container Toolkit
](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) for GPU pass through.

After `docker run`, you should see your bash terminal hanging, without printing anything. This is expected because the docker container is now listening to the internal port 22 (corresponding to external port `<local_port>` you specified in `-p`), and waiting for SSH connections. Open your vscode and try to setup remote connections.

First, install the `Remote Development` (with id: ms-vscode-remote.vscode-remote-extensionpack) extension on vscode. Bring up the command palette, search and choose `Remote-SSH: Connect to Host` -> `Configure SSH Hosts` -> `<your ssh config path>`, and put following config:

```
Host local-testing
    HostName localhost
    Port <local_port>
    User root
```

Bring up your command palette, choose `Remote-SSH: Connect to Host` -> `local-testing`, type in the password `root`, you are now connecting to the image.

