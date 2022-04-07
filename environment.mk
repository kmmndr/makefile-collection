# https://github.com/kmmndr/makefile-collection

stage ?= default

.PHONY: stage-%
stage-%:
	@$(eval override stage=$*)
	@echo "Setting stage to ${stage}"

check-stage-%: environment
	@$(eval expected_stage=$*)
	@[ "${stage}" = "${expected_stage}" ] || (echo "Expected stage ${expected_stage}, actual ${stage}"; exit 1)

.PHONY: environment
environment: ${stage}.env ##- Define environment variables
	@test ${stage} || (echo 'stage not set'; exit 1)
	@$(eval ENV_FILE?=./${stage}.env)
	@$(eval load_env=set -a;. ${ENV_FILE};set +a)

%.env: env.sh
	@echo "Env file $@ is not found or obsolete"
	@echo "Please update it (review and touch, or call make [-e stage=${stage}] generate-env)"; exit 1

.PHONY: generate-env
generate-env: env.sh ##- Generate environment file ${stage}.env
	@test ${stage} || (echo 'stage not set'; exit 1)
	@./env.sh ${stage} > ${stage}.env
	@$(eval OVERRIDE_ENV_FILE?=./override.env)
	@for override_env_file in ${OVERRIDE_ENV_FILE}; \
	do \
		[ -f "$${override_env_file}" ] && echo "Appending environment override from file $${override_env_file}"; true; \
		(([ -x "$${override_env_file}" ] && "$${override_env_file}" ${stage}) || \
			([ -r "$${override_env_file}" ] && cat "$${override_env_file}") || true) | tee -a ${stage}.env | sed -e 's/^\(.*=\).*/\1*****/'; \
	done
	@echo "Environment file ${stage}.env generated"

generate-folder-env-%:
	@current_dir=$(shell pwd); \
		make \
			-C $* \
			-e OVERRIDE_ENV_FILE="$$current_dir/host.env $$current_dir/$*.env" \
			generate-env

generate-folder-env:
	@test ${folder} || (echo 'folder not set'; exit 1)
	@current_dir=$(shell pwd); \
		make \
			-C ${folder} \
			-e OVERRIDE_ENV_FILE="$$current_dir/host.env $$current_dir/${folder}.env" \
			generate-env

.PHONY: dump-env
dump-env: environment ##- Dump environment
	@echo "dump ENV_FILE: ${ENV_FILE}"
	$(load_env); env

.PHONY: shell-env
shell-env: environment ##- Start a local shell with environment
	@$(load_env); PS1='env$$ ' ${SHELL}
