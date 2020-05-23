REGISTRY ?= localhost
BUILD_ID ?= latest
BUILD_SUBPATH ?= build
PROJECT_PATH ?= $(notdir $(realpath $(dir $(lastword $(MAKEFILE_LIST)))))
REGISTRY_PROJECT_URL=$(REGISTRY)/$(PROJECT_PATH)
CONTAINER_IMAGE ?= $(REGISTRY_PROJECT_URL)/${BUILD_SUBPATH}:$(BUILD_ID)
CONTAINER_RELEASE_IMAGE=${REGISTRY_PROJECT_URL}:${BUILD_ID}
CONTAINER_LATEST_IMAGE=${REGISTRY_PROJECT_URL}:latest
DOCKER_TARGETS=$(shell cat Dockerfile | awk '/^[[:blank:]]*FROM/ { print $$4 }' | xargs)

## Pull
.PHONY: docker-pull-stages
docker-pull-stages: ##- Pull intermediate containers
	@for docker_target in ${DOCKER_TARGETS}; \
	do \
		docker_intermediate_image="${CONTAINER_IMAGE}-$$docker_target"; \
		docker pull $$docker_intermediate_image || true; \
	done

.PHONY: docker-pull-final
docker-pull-final: ##- Pull final container
	-docker pull $(CONTAINER_IMAGE)

.PHONY: docker-pull
docker-pull: docker-pull-stages docker-pull-final ##- Pull containers

## Build
.PHONY: docker-build-stages
docker-build-stages: docker-pull-stages ##- Build intermediate containers
	@for docker_target in ${DOCKER_TARGETS}; \
	do \
		docker_intermediate_image="${CONTAINER_IMAGE}-$$docker_target"; \
		docker build -t $$docker_intermediate_image --target $$docker_target .; \
	done

.PHONY: docker-build-final
docker-build-final: docker-pull-final ##- Build final container
	-docker pull $(CONTAINER_IMAGE)
	docker build -t $(CONTAINER_IMAGE) .

.PHONY: docker-build
docker-build: docker-build-stages docker-build-final ##- Build containers

## Tag
.PHONY: docker-tag-releases
docker-tag-releases:
	docker tag ${CONTAINER_IMAGE} ${CONTAINER_RELEASE_IMAGE}
	docker tag ${CONTAINER_IMAGE} ${CONTAINER_LATEST_IMAGE}

## Push
.PHONY: docker-push-stages
docker-push-stages: ##- Push intermediate containers to registry
	@for docker_target in ${DOCKER_TARGETS}; \
	do \
		docker_intermediate_image="${CONTAINER_IMAGE}-$$docker_target"; \
		docker push $$docker_intermediate_image || true; \
	done

.PHONY: docker-push-final
docker-push-final: ##- Push final container to registry
	docker push $(CONTAINER_IMAGE)

.PHONY: docker-push-releases
docker-push-releases: docker-tag-releases ##- Push releases containers to registry
	docker push ${CONTAINER_RELEASE_IMAGE}
	docker push ${CONTAINER_LATEST_IMAGE}

.PHONY: docker-push
docker-push: docker-push-stages docker-push-final ##- Push containers to registry
