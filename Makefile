all: help
include *.mk

start: docker-compose-pull docker-compose-start ##- Start
deploy: docker-compose-pull docker-compose-deploy ##- Deploy (start remotely)
stop: docker-compose-stop ##- Stop

check: ##- Run tests
	bundle exec rubocop
	bundle exec rake test

serve_rails: environment ##- Start rails app locally
	$(load_env); bundle exec rails s
