# Makefile collection

This repo contains a collection of makefiles for various tools

Make is a simple/wonderful/easy tool existing since last century. The syntax
may be complex, but avoiding complex syntax may lead to simple and
understandable files.

As (web) development tends to include more and more tools, it may be handy to
have a quick way to build or deploy applications.

Today, containers are the most proeminent way to package and start services.
This repository aims to contain makefiles for packaging, integrating and
deploying containers.

## How it works

Simply copy the files you want in your projects, and tune `Makefile` and
`env.sh` to your needs.

The only required file is `environment.mk` as it adds a way to read
standardized environment files.

## Make for docker

If your project need to build a docker container, use `docker.mk` for quick
build make targets.

## Make for docker-compose

If you want to deploy your project using docker-compose, add
`docker-compose.mk` for quick deployments targets.

## Make for ci

You may want to build containers from your favorite CI. Why don't you make
everything with make ?

Add the following example to your Makefile:
```
ci-build: docker-pull docker-build
ci-push: docker-push
ci-push-release: docker-push-release
```

Define some variables:
```
REGISTRY_PROJECT_URL=my-awesome-registry.org/my-cool-project
BUILD_ID=<a unique id>    # git sha for example
REF_ID=<a reference name> # git branch for example
```

Create a `build` step:
```
$ make -e REGISTRY_PROJECT_URL=$REGISTRY_PROJECT_URL -e BUILD_ID=$BUILD_ID -e REF_ID=$REF_ID ci-build ci-push
```

Then create a `release` step:
```
$ make -e REGISTRY_PROJECT_URL=$REGISTRY_PROJECT_URL -e BUILD_ID=$BUILD_ID -e REF_ID=$REF_ID ci-push-release
$ make -e REGISTRY_PROJECT_URL=$REGISTRY_PROJECT_URL -e BUILD_ID=$BUILD_ID -e REF_ID=latest ci-push-release
```
