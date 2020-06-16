# REGISTRY_PROJECT_URL ?= my-awesome-registry.org/my-cool-project
# BUILD_ID ?= commit_sha
# REF_ID ?= branch_name

all: help
include *.mk

ci-build: docker-pull docker-build
ci-push: docker-push
ci-push-release: docker-push-release

start: docker-compose-pull docker-compose-start ##- Start
deploy: docker-compose-pull docker-compose-deploy ##- Deploy (start remotely)
stop: docker-compose-stop ##- Stop

check: ##- Run tests
	bundle exec rubocop
	bundle exec rake test

serve_rails: environment ##- Start rails app locally
	$(load_env); bundle exec rails s
