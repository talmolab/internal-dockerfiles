# Dockerfiles for the Talmo Lab

A repo to store Dockerfiles. General folder structure - each folder contains a separate container build.

Generally to build most images:

```
cd <directory containing the Docker setup you want>

docker build -t <your docker hub username>/<whatever_name_you_want> .

docker login  # if you haven't logged into docker hub yet

docker push <your docker hub username>/<the same name from before>  # push to your docker hub container repository
```

You should be able to access it from RunAI once it pushes.
