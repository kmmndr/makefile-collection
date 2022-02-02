# https://github.com/kmmndr/makefile-collection

REGISTRY      ?= localhost
BUILD_ID      ?= edge
REF_ID        ?= latest
BUILD_SUBPATH ?= dev
PROJECT_PATH  ?= $(notdir $(realpath $(dir $(lastword $(MAKEFILE_LIST)))))
DOCKERFILE    ?= Dockerfile

export DOCKER_BUILDKIT = 1

REGISTRY_PROJECT_URL ?= $(REGISTRY)/$(PROJECT_PATH)
BUILD_PATH=$(REGISTRY_PROJECT_URL)/${BUILD_SUBPATH}

CONTAINER_BUILD_IMAGE=${BUILD_PATH}:$(BUILD_ID)
CONTAINER_REF_IMAGE=${BUILD_PATH}:$(REF_ID)
CONTAINER_LATEST_BUILD_IMAGE=${BUILD_PATH}:latest
CONTAINER_RELEASE_IMAGE=${REGISTRY_PROJECT_URL}:${REF_ID}

DOCKER_TARGETS=$(shell cat ${DOCKERFILE} | awk '/^[[:blank:]]*FROM/ { print $$4 }' | xargs)

for_each_target=set -eu; for docker_target in ${DOCKER_TARGETS}; do $(1); done

## Targets
.PHONY: docker-targets
docker-targets:
	@echo "Targets: ${DOCKER_TARGETS}"

## Pull
.PHONY: docker-pull-stages
docker-pull-stages: ##- Pull intermediate containers
	$(call for_each_target, \
		docker pull "${CONTAINER_BUILD_IMAGE}-$$docker_target" || \
			docker pull "${CONTAINER_REF_IMAGE}-$$docker_target" || \
			true \
	)

.PHONY: docker-pull-final
docker-pull-final: ##- Pull final container
	-docker pull $(CONTAINER_BUILD_IMAGE)

.PHONY: docker-pull
docker-pull: docker-pull-stages docker-pull-final ##- Pull containers

## Build
.PHONY: docker-build-stages
docker-build-stages: ##- Build intermediate containers
	$(call for_each_target, \
		docker build \
			--tag "${CONTAINER_BUILD_IMAGE}-$$docker_target" \
			--build-arg BUILDKIT_INLINE_CACHE=1 \
			--cache-from "${CONTAINER_BUILD_IMAGE}-$$docker_target" \
			--cache-from "${CONTAINER_REF_IMAGE}-$$docker_target" \
			--cache-from "${CONTAINER_LATEST_BUILD_IMAGE}-$$docker_target" \
			--target $$docker_target \
			. ; \
		docker tag "${CONTAINER_BUILD_IMAGE}-$$docker_target" "${CONTAINER_LATEST_BUILD_IMAGE}-$$docker_target" \
	)

.PHONY: docker-build-final
docker-build-final: ##- Build final container
	docker build \
		--tag $(CONTAINER_BUILD_IMAGE) \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		.
	docker tag ${CONTAINER_BUILD_IMAGE} ${CONTAINER_LATEST_BUILD_IMAGE}

.PHONY: docker-build
docker-build: docker-build-stages docker-build-final ##- Build containers

## Tag
.PHONY: docker-tag-ref
docker-tag-ref:
	$(call for_each_target, \
		docker tag "${CONTAINER_BUILD_IMAGE}-$$docker_target" "${CONTAINER_REF_IMAGE}-$$docker_target" \
	)
	docker tag ${CONTAINER_BUILD_IMAGE} ${CONTAINER_REF_IMAGE}

.PHONY: docker-tag-release
docker-tag-release: docker-pull-final
	docker tag ${CONTAINER_BUILD_IMAGE} ${CONTAINER_RELEASE_IMAGE}

## Push
.PHONY: docker-push-stages
docker-push-stages: ##- Push intermediate containers to registry
	$(call for_each_target, \
		docker push "${CONTAINER_BUILD_IMAGE}-$$docker_target"; \
		docker push "${CONTAINER_LATEST_BUILD_IMAGE}-$$docker_target" \
	)

.PHONY: docker-push-final
docker-push-final: ##- Push final container to registry
	docker push $(CONTAINER_BUILD_IMAGE)

.PHONY: docker-push-ref
docker-push-ref: docker-tag-ref ##- Push ref container to registry
	$(call for_each_target, \
		docker push "${CONTAINER_REF_IMAGE}-$$docker_target" \
	)
	docker push ${CONTAINER_REF_IMAGE}
	docker push ${CONTAINER_LATEST_BUILD_IMAGE}

.PHONY: docker-push-release
docker-push-release: docker-tag-release ##- Push releases containers to registry
	docker push ${CONTAINER_RELEASE_IMAGE}

.PHONY: docker-push
docker-push: docker-push-stages docker-push-final docker-push-ref ##- Push containers to registry
