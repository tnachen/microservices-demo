# Run weave-socks demo on the new Docker Swarm

Please refer to the [new Docker Swarm introduction](http://container-solutions.com/hail-new-docker-swarm/)

# Blockers

Currently, new Docker Swarm does not support running containers in privileged mode. 
Maybe it will be allowed in the future.
Please refer to the issue [1030](https://github.com/docker/swarmkit/issues/1030#issuecomment-232299819).
This prevents from running Weave Scope, since it needs privileged mode.

Running global plugins is not supported either.

# Overview

This setup includes 3 nodes for Docker Swarm.
master1 - is the Docker Swarm manager node
node1 and node2 - worker nodes

# Pre-requisities

* Vagrant
* VirtualBox

or 

* Docker For Mac (limited to a single node)


# How-to using Docker For Mac

* Put your docker into the swarm mode
```
docker swarm init
```

* Execute the services startup script
```
docker deploy swarmkit
```
