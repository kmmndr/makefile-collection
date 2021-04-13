# REGISTRY_PROJECT_URL ?= my-awesome-registry.org/my-cool-project
# BUILD_ID ?= commit_sha
# BUILD_ID ?=$(shell test -d .git && git rev-parse --short=8 HEAD)
# REF_ID = branch_name
# REF_ID ?=$(shell test -d .git && git symbolic-ref --short HEAD)

default: help
include *.mk

ci-build: docker-pull docker-build
ci-push: docker-push
ci-push-release: docker-pull-final docker-push-release

.PHONY: start
start: docker-compose-pull docker-compose-start ##- Start
.PHONY: deploy
deploy: docker-compose-pull docker-compose-deploy ##- Deploy (start remotely)
.PHONY: stop
stop: docker-compose-stop ##- Stop

check: ##- Run tests
