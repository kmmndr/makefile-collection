# https://github.com/kmmndr/makefile-collection

stage ?= default

.PHONY: stage-%
stage-%:
	@$(eval override stage=$(patsubst stage-%,%,$@))
	@echo "Setting stage to ${stage}"

check-stage-%: environment
	@$(eval expected_stage=$(patsubst check-stage-%,%,$@))
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
	@[ -f "${OVERRIDE_ENV_FILE}" ] && echo "Appending environment override"; true
	@(([ -x "${OVERRIDE_ENV_FILE}" ] && "${OVERRIDE_ENV_FILE}" ${stage}) || \
		([ -r "${OVERRIDE_ENV_FILE}" ] && cat "${OVERRIDE_ENV_FILE}") || true) | tee -a ${stage}.env
	@echo "Environment file ${stage}.env generated"

.PHONY: dump-env
dump-env: environment ##- Dump environment
	@echo "dump ENV_FILE: ${ENV_FILE}"
	$(load_env); env

.PHONY: shell-env
shell-env: environment ##- Start a local shell with environment
	@$(load_env); PS1='env$$ ' ${SHELL}
