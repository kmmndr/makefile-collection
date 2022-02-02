# https://github.com/kmmndr/makefile-collection

.PHONY: rails-container-console
rails-container-console: environment
	$(load_env); docker-compose exec rails /bin/ash

.PHONY: rails-server
rails-server: environment ##- Start rails app locally
	$(load_env); bundle exec rails s

.PHONY: rails-console
rails-console: environment ##- Start rails app locally
	$(load_env); bundle exec rails c

.PHONY: rails-clean-cache
rails-clean:
	bundle exec rake tmp:clear

.PHONY: rails-rubocop
rails-rubocop:
	bundle exec rubocop -v
	bundle exec rubocop -f simple

.PHONY: rails-slim-lint
rails-slim-lint:
	bundle exec slim-lint -v
	bundle exec slim-lint .

.PHONY: rails-test-setup
rails-test-setup:
	rm -rf coverage
	env RAILS_ENV=test bundle exec rake db:migrate

.PHONY: rails-test
rails-test: rails-test-setup
	env RAILS_ENV=test bundle exec rake test

.PHONY: rails-test-system
rails-test-system: rails-test-setup
	env RAILS_ENV=test bundle exec rake test:system

.PHONY: rails-bundle-audit
rails-bundle-audit:
	@echo "*** Running bundle-audit ***"
	bundle-audit check --update

.PHONY: rails-brakeman
rails-brakeman:
	@echo "*** Running brakeman ***"
	brakeman --run-all-checks --no-progress --no-pager --quiet --ignore-config .brakeman.ignore

.PHONY: rails-brakeman-interactive-ignore
rails-brakeman-interactive-ignore:
	brakeman --run-all-checks --no-progress --no-pager --quiet --ensure-latest --ignore-config .brakeman.ignore --interactive-ignore
