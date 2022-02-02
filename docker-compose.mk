# https://github.com/kmmndr/makefile-collection

compose_files :=

export COMPOSE_DOCKER_CLI_BUILD = 1
export DOCKER_BUILDKIT = 1

.PHONY: docker-compose-pull
docker-compose-pull: environment ##- Pull latest containers
	$(info *** Pulling containers ***)
	-$(load_env); docker-compose ${compose_files} pull

.PHONY: docker-compose-build
docker-compose-build: environment ##- Build containers
	$(info *** Building containers ***)
	$(load_env); docker-compose ${compose_files} build

.PHONY: docker-compose-start
docker-compose-start: environment ##- Start containers
	$(info *** Starting containers ***)
	$(load_env); docker-compose ${compose_files} up -d

.PHONY: docker-compose-stop
docker-compose-stop: environment ##- Stop containers
	$(info *** Stopping containers ***)
	$(load_env); docker-compose ${compose_files} down

.PHONY: docker-compose-logs
docker-compose-logs: environment ##- Print containers logs
	$(info *** Printing containers logs ***)
	$(load_env); docker-compose ${compose_files} logs -f

.PHONY: docker-compose-ps
docker-compose-ps: environment ##- Print containers statuses
	$(info *** Printing containers statuses ***)
	$(load_env); docker-compose ${compose_files} ps

.PHONY: docker-compose-clean
docker-compose-clean: environment ##- Stop and remove volumes
	$(info *** Stopping containers and remove volumes ***)
	$(load_env); docker-compose ${compose_files} down -v --remove-orphans

.PHONY: docker-compose-check-remote-env
docker-compose-check-remote-env: environment ##- Check environment variables
	$(info *** Checking env variables ***)
	$(load_env); test $$DOCKER_HOST
	$(load_env); test $$COMPOSE_PROJECT_NAME

.PHONY: docker-compose-deploy
docker-compose-deploy: docker-compose-check-remote-env docker-compose-start ##- Deploy containers
