# https://github.com/kmmndr/makefile-collection

REGISTRY      ?= localhost
BUILD_ID      ?= edge
REF_ID        ?= latest
BUILD_SUBPATH ?= dev
PROJECT_PATH  ?= $(notdir $(realpath $(dir $(lastword $(MAKEFILE_LIST)))))
DOCKERFILE    ?= Dockerfile

REGISTRY_PROJECT_URL ?= $(REGISTRY)/$(PROJECT_PATH)

CONTAINER_BUILD_IMAGE=$(REGISTRY_PROJECT_URL)/${BUILD_SUBPATH}:$(BUILD_ID)
CONTAINER_REF_IMAGE=$(REGISTRY_PROJECT_URL)/${BUILD_SUBPATH}:$(REF_ID)
CONTAINER_RELEASE_IMAGE=${REGISTRY_PROJECT_URL}:${REF_ID}

DOCKER_TARGETS=$(shell cat ${DOCKERFILE} | awk '/^[[:blank:]]*FROM/ { print $$4 }' | xargs)

## Pull
.PHONY: docker-pull-stages
docker-pull-stages: ##- Pull intermediate containers
	@for docker_target in ${DOCKER_TARGETS}; \
	do \
		docker_intermediate_image="${CONTAINER_BUILD_IMAGE}-$$docker_target"; \
		docker pull $$docker_intermediate_image || true; \
	done

.PHONY: docker-pull-final
docker-pull-final: ##- Pull final container
	-docker pull $(CONTAINER_BUILD_IMAGE)

.PHONY: docker-pull
docker-pull: docker-pull-stages docker-pull-final ##- Pull containers

## Build
.PHONY: docker-build-stages
docker-build-stages: docker-pull-stages ##- Build intermediate containers
	@for docker_target in ${DOCKER_TARGETS}; \
	do \
		docker_intermediate_image="${CONTAINER_BUILD_IMAGE}-$$docker_target"; \
		docker build -t $$docker_intermediate_image --target $$docker_target .; \
	done

.PHONY: docker-build-final
docker-build-final: docker-pull-final ##- Build final container
	-docker pull $(CONTAINER_BUILD_IMAGE)
	docker build -t $(CONTAINER_BUILD_IMAGE) .

.PHONY: docker-build
docker-build: docker-build-stages docker-build-final ##- Build containers

## Tag
.PHONY: docker-tag-ref
docker-tag-ref:
	docker tag ${CONTAINER_BUILD_IMAGE} ${CONTAINER_REF_IMAGE}

.PHONY: docker-tag-release
docker-tag-release: docker-pull-final
	docker tag ${CONTAINER_BUILD_IMAGE} ${CONTAINER_RELEASE_IMAGE}

## Push
.PHONY: docker-push-stages
docker-push-stages: ##- Push intermediate containers to registry
	@for docker_target in ${DOCKER_TARGETS}; \
	do \
		docker_intermediate_image="${CONTAINER_BUILD_IMAGE}-$$docker_target"; \
		docker push $$docker_intermediate_image; \
	done

.PHONY: docker-push-final
docker-push-final: ##- Push final container to registry
	docker push $(CONTAINER_BUILD_IMAGE)

.PHONY: docker-push-ref
docker-push-ref: docker-tag-ref ##- Push ref container to registry
	docker push ${CONTAINER_REF_IMAGE}

.PHONY: docker-push-release
docker-push-release: docker-tag-release ##- Push releases containers to registry
	docker push ${CONTAINER_RELEASE_IMAGE}

.PHONY: docker-push
docker-push: docker-push-stages docker-push-final docker-push-ref ##- Push containers to registry
