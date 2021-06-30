# https://github.com/kmmndr/makefile-collection

.PHONY: help
help: ##- Show this help.
	@echo 'Usage: make <target> (see target list below)'
	@echo
	@sed -e '/#\{2\}-/!d; s/\\$$//; s/:[^#\t]*/:/; s/#\{2\}-*//' $(MAKEFILE_LIST)
