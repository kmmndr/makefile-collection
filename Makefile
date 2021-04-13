# REGISTRY_PROJECT_URL ?= my-awesome-registry.org/my-cool-project
# BUILD_ID ?= commit_sha
# REF_ID ?= branch_name

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
