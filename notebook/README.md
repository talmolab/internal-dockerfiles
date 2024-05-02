# notebook

This image defines a Jupyter Lab instance used to run interactive jobs. It is based off of [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks).

The stack is:

1. [`base-notebook`](https://github.com/jupyter/docker-stacks/tree/main/base-notebook)
2. [`minimal-notebook`](https://github.com/jupyter/docker-stacks/tree/main/minimal-notebook)
3. [`scipy-notebook`](https://github.com/jupyter/docker-stacks/tree/main/scipy-notebook)
4. [`tensorflow-notebook`](https://github.com/jupyter/docker-stacks/tree/main/tensorflow-notebook)
5. `notebook` (this image)

This image adds:

- `build-essential` for compilation
- A default environment called `python37` defined in [`environment.yml`](environment.yml)
- Sets the user to `root` (this is bad practice, but more convenient for internal use)
