# https://github.com/kmmndr/makefile-collection

.PHONY: git-submodule-init
git-submodule-init: git-submodule-upgrade

.PHONY: git-submodule-revert
git-submodule-revert: ##- Revert to local commited versions
	git submodule update --init ${path}

.PHONY: git-submodule-upgrade
git-submodule-upgrade: ##- Upgrade to remote versions
	git submodule update --init --remote --merge ${path}
