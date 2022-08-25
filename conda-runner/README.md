# conda-runner

This image serves as a general-purpose container for running Python scripts.

Environment variables:

| Name               | Description                                                                                                                                                  |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LOGGING_QUIET`    | If set, will suppress some logging.                                                                                                                          |
| `RUNNER_CONDA_ENV` | Specifies the name of the conda environment to use. <br>This can be specified as `env_name:path/to/environment.yml` to install new environments from a file. |
| `RUNNER_CMD`       | Specifies the command to run.                                                                                                                                |

The default home directory is:
```
/home/runner
```

**Build:**
```
docker build -t talmo/conda-runner .
```

**Run:**
```
docker run -e RUNNER_CONDA_ENV="environment_name" -e RUNNER_CMD="python my_script.py" talmo/conda-runner
```

## Tips
Out of space?
```
docker system prune --all --force
```
Want to build without using the cache?
```
docker build --no-cache -t talmo/conda-runner .
```

## Examples
### Running a script
Let's say we have this script saved as `test.py`:
```py
import numpy as np
import sys

if __name__ == "__main__":
    print(f"numpy: {np.__version__}")
    print(f"sys.argv: {sys.argv}")
```

We can run it with:
<small>**Windows:**</small>
```
docker run -e RUNNER_CONDA_ENV="tf-extras" -e RUNNER_CMD="python test.py -flag1 \"arg with spaces\"" -v %cd%:"/home/runner" talmo/conda-runner
```
<small>**Linux:**</small>
```
docker run -e RUNNER_CONDA_ENV="tf-extras" -e RUNNER_CMD="python test.py -flag1 \"arg with spaces\"" -v $(pwd):"/home/runner" talmo/conda-runner
```
<small>**Output:**</small>
```
Entered start-image.sh with args:
in start-image.sh
RUNNER_CONDA_ENV: tf-extras
RUNNER_CMD: python test.py -flag1 "arg with spaces"
numpy: 1.19.5
sys.argv: ['test.py', '-flag1', 'arg with spaces']
```

### Installing a custom environment

Let's say we want to run a custom environment. First, we'll define an `environment.yml` file:
```
name: sleap

dependencies:
  - python=3.8
  - cudatoolkit=11.3.1
  - cudnn=8.2.1
  - nvidia::cuda-nvcc=11.3
  - pip
  - pip:
    - sleap==1.2.6
```

Then, we can run the container setting the `RUNNER_CONDA_ENV` flag to `<environment_name>:<path_to_environtment_yml>`, for example:
```
docker run -e RUNNER_CONDA_ENV="sleap:testdir/sleap.yml" -e RUNNER_CMD="python -c \"import sleap; sleap.versions()\"" -v %cd%:"/home/runner" talmo/conda-runner
```
<small>**Output:**</small>
```
Entered start-image.sh with args:
in start-image.sh
RUNNER_CONDA_ENV: sleap:testdir/sleap.yml
RUNNER_CMD: python -c "import sleap; sleap.versions()"
Installing new environment.
RUNNER_CONDA_ENV: sleap
CONDA_ENV_FILE: testdir/sleap.yml
Transaction

  Prefix: /opt/conda/envs/sleap

  Updating specs:

   - python=3.8
   - cudatoolkit=11.3.1
   - cudnn=8.2.1
   - nvidia::cuda-nvcc=11.3
   - pip
...
```

This will install the environment from the provided file using the specified environment name, activate it, and run the contents of `RUNNER_CMD` in that environment.


### Installing a package in an existing environment

To do this, we just need to call `conda run -n <env>` again inside the `RUNNER_CMD`:
```
docker run -e RUNNER_CONDA_ENV="tf-extras" -e RUNNER_CMD="pip install sleap && conda run -n tf-extras python -c \"import sleap; sleap.versions()\"" -v %cd%:"/home/runner" talmo/conda-runner
```