# REGISTRY_PROJECT_URL ?= my-awesome-registry.org/my-cool-project
# BUILD_ID ?= commit_sha
# REF_ID ?= branch_name

default: help
include *.mk

ci-build: docker-pull docker-build
ci-push: docker-push
ci-push-release: docker-pull-final docker-push-release

start: docker-compose-pull docker-compose-start ##- Start
deploy: docker-compose-pull docker-compose-deploy ##- Deploy (start remotely)
stop: docker-compose-stop ##- Stop

set-dev-docker-compose-files:
	$(eval compose_files=-f docker-compose.yml -f docker-compose.dev.yml)
start-dev: set-dev-docker-compose-files generate-env docker-build docker-tag-release docker-compose-start ##- Quickly build and start
	$(load_env); docker-compose logs -f

check: ##- Run tests
