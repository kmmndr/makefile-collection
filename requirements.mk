# https://github.com/kmmndr/makefile-collection

define command_exist
	command -v $(1) > /dev/null || (echo "$(1) command is missing !"; exit 1)
endef

.PHONY: requirements
requirements-gmake: ##- Check GNU Make version
	@$(call command_exist,awk)
	@[ "$$($(MAKE) --version | awk '/GNU Make/ { split($$3,a,"."); print a[1] }')" == "4" ] || (echo "Gnu Make 4.x is required"; exit 1)
