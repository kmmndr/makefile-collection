# https://github.com/kmmndr/makefile-collection

CHANGELOG_BASE_PATH =$(shell git rev-parse --show-toplevel)
CHANGELOG_FILE =${CHANGELOG_BASE_PATH}/CHANGELOG.md
CHANGELOG_PATH =${CHANGELOG_BASE_PATH}/changelog
CHANGELOG_UNRELEASED_PATH =${CHANGELOG_PATH}/unreleased

${CHANGELOG_UNRELEASED_PATH}:
	@mkdir -p "${CHANGELOG_UNRELEASED_PATH}"

.PHONY: changelog-unreleased
changelog-unreleased: ${CHANGELOG_UNRELEASED_PATH}
	@find ${CHANGELOG_UNRELEASED_PATH} -type f | sort | xargs -i sh -c 'cat {} ; echo'

.PHONY: changelog-issue-file
changelog-issue-file: ${CHANGELOG_UNRELEASED_PATH}
	$(eval issue_id=$(shell git rev-parse --abbrev-ref HEAD | awk -F '-' '{ print $$1 }'))
	$(eval issue_file=${CHANGELOG_UNRELEASED_PATH}/issue-${issue_id}.md)

.PHONY: changelog-check
changelog-check: ${CHANGELOG_UNRELEASED_PATH} changelog-issue-file
	@test -f ${issue_file} || (echo "Changelog file '${issue_file}' is missing"; exit 1)

.PHONY: changelog-edit
changelog-edit: ${CHANGELOG_UNRELEASED_PATH} changelog-issue-file
	@[ -s ${issue_file} ] || echo -e "**Issue #${issue_id}**\n\n-" > ${issue_file}; \
		$$EDITOR ${issue_file}

.PHONY: changelog-version-from-last-tag
changelog-version-from-last-tag:
	$(eval version=$(shell git describe --tags --abbrev=0))
	@echo "Version ${version}"

.PHONY: changelog-create-release-from-last-tag
changelog-create-release-from-last-tag: \
	changelog-version-from-last-tag \
	changelog-create-release

.PHONY: changelog-create-release
changelog-create-release:
	@test ${version} || (echo 'version not set'; exit 1)
	@set -eu; \
		version_path="${CHANGELOG_PATH}/${version}"; \
		release_log_file="$${version_path}.md"; \
		echo -e "## ${version} - $$(date '+%Y-%m-%d')\n" > "$$release_log_file"; \
		for file in "${CHANGELOG_UNRELEASED_PATH}/"*; \
		do \
			[ -f "$$file" ] || continue; \
			cat "$$file" <(echo) >> "$$release_log_file"; \
			git rm "$$file" || rm "$$file"; \
		done; \
		git add "$$release_log_file"; \
		touch ${CHANGELOG_FILE}; \
		cat "$$release_log_file" ${CHANGELOG_FILE} | tee ${CHANGELOG_FILE}.tmp; \
		mv ${CHANGELOG_FILE}.tmp ${CHANGELOG_FILE}; \
		git add ${CHANGELOG_FILE}

.PHONY: changelog-clean
changelog-clean:
	rm -rf ${CHANGELOG_FILE} ${CHANGELOG_PATH}
