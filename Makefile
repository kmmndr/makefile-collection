all: help
include *.mk

check: ##- Run tests
	bundle exec rubocop
	bundle exec rake test

start: docker-compose-start ##- Start
deploy: docker-compose-deploy ##- Deploy (start remotely)

serve_rails: environment ##- Start rails app locally
	$(load_env); bundle exec rails s
