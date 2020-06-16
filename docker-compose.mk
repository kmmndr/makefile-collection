compose_files :=

.PHONY: docker-compose-pull
docker-compose-pull: environment ##- Pull latest containers
	$(info *** Pulling containers ***)
	-$(load_env); docker-compose ${compose_files} pull

.PHONY: docker-compose-start
docker-compose-start: environment ##- Start containers
	$(info *** Starting containers ***)
	$(load_env); docker-compose ${compose_files} up -d

.PHONY: docker-compose-stop
docker-compose-stop: environment ##- Stop containers
	$(info *** Stopping containers ***)
	$(load_env); docker-compose ${compose_files} down

.PHONY: docker-compose-check-remote-env
docker-compose-check-remote-env: environment ##- Check environment variables
	$(info *** Checking env variables ***)
	$(load_env); test $$DOCKER_HOST
	$(load_env); test $$COMPOSE_PROJECT_NAME

.PHONY: docker-compose-deploy
docker-compose-deploy: docker-compose-check-remote-env docker-compose-start ##- Deploy containers
