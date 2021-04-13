# https://github.com/kmmndr/makefile-collection

.PHONY: set-local-docker-compose-files
set-local-docker-compose-files:
	$(eval compose_files=-f docker-compose.yml -f docker-compose.local.yml)

local-%: ##- Add docker-compose local override file before calling target (use: local-<target>)
local-% : set-local-docker-compose-files % ;
