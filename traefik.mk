# https://github.com/kmmndr/makefile-collection

.PHONY: set-traefik-docker-compose-files
set-traefik-docker-compose-files:
	$(eval compose_files=-f docker-compose.yml -f docker-compose.traefik.yml)

traefik-%: ##- Add docker-compose traefik override file before calling target (use: traefik-<target>)
traefik-% : set-traefik-docker-compose-files % ;
