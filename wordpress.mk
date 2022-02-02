# https://github.com/kmmndr/makefile-collection

.PHONY: wordpress-requirements
wordpress-requirements: ##- Check wordpress requirements
	@$(call command_exist,docker)
	@$(call command_exist,docker-compose)
	@$(call command_exist,gzip)
	@$(call command_exist,gunzip)
	@$(call command_exist,pv)

.PHONY: wordpress-dump-wp-content
wordpress-dump-wp-content: environment
	@$(load_env); echo "*** Dumping wp-content ***"
	@$(load_env); docker exec -i wordpress-$${STAGE}_wordpress_1 sh -c "tar -C /var/www/html/wp-content -czf - ." | pv > wp-content.tgz

.PHONY: wordpress-dump-mariadb
wordpress-dump-mariadb: environment
	$(load_env); echo "*** Dumping database '$$MYSQL_DATABASE' ***"
	$(load_env); docker exec -i wordpress-$${STAGE}_wordpress-db_1 mysqldump -h 127.0.0.1 -u $$MYSQL_USER \
			--password=$$MYSQL_PASSWORD \
			--no-tablespaces $$MYSQL_DATABASE | pv | gzip > $$MYSQL_DATABASE.sql.gz
	$(load_env); echo "- database $$MYSQL_DATABASE => $$MYSQL_DATABASE.sql.gz"

.PHONY: wordpress-restore-wp-content
wordpress-restore-wp-content: environment
	@$(load_env); echo "*** Restoring wp-content ***"
	@$(load_env); pv wp-content.tgz | docker exec -i wordpress-$${STAGE}_wordpress_1 sh -c "tar -C /var/www/html/wp-content -xzf -"
	@$(load_env); docker exec wordpress-$${STAGE}_wordpress_1 chown -R www-data:www-data '/var/www/html/wp-content'
	@$(load_env); docker exec wordpress-$${STAGE}_wordpress_1 chmod -R 755 '/var/www/html/wp-content'

.PHONY: wordpress-restore-mariadb
wordpress-restore-mariadb: environment
	@$(load_env); echo "*** Restoring database '$$MYSQL_DATABASE' ***"
	@$(load_env); pv $$MYSQL_DATABASE.sql.gz | gunzip | \
		docker exec -i wordpress-$${STAGE}_wordpress-db_1 \
			mysql -h 127.0.0.1 -u $$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE

.PHONY: wordpress-console
wordpress-console: environment
	@$(load_env); docker exec -it wordpress-$${STAGE}_wordpress_1 /bin/bash

.PHONY: wordpress-dbconsole
wordpress-dbconsole: environment
	@$(load_env); echo "*** Entering database console ***"
	@$(load_env); docker-compose exec wordpress-db \
		mysql -h 127.0.0.1 -u $$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE

wordpress-convert-db-to-%.env: environment
	@$(eval old_stage=${stage})
	@set -a; . ./${stage}.env; set +a; env | grep WP_BASEURL | sed -e 's/^WP_BASEURL/FROM_WP_BASEURL/' > $@
	@$(eval override stage=$(patsubst wordpress-convert-db-to-%.env,%,$@))
	@set -a; . ./${stage}.env; set +a; env | grep WP_BASEURL | sed -e 's/^WP_BASEURL/TO_WP_BASEURL/' >> $@
	@echo "Transfert file $@ (${old_stage} => ${stage}) generated"
	@$(eval stage=${old_stage})

# http://localhost:8080 => https://server.online
# http:\\\\/\\\\/localhost:8080 => https:\\\\/\\\\/server.online
# localhost:8080 => server.online
.PHONY: wordpress-convert-db-to-%
wordpress-convert-db-to-% : environment wordpress-convert-db-to-%.env ;
	@$(load_env); set -a; . ./$@.env; set +a; \
		pv $$MYSQL_DATABASE.sql.gz | gunzip | \
		sed \
			-e "s|$$FROM_WP_BASEURL|$$TO_WP_BASEURL|g" \
			-e $$(echo "s|$$FROM_WP_BASEURL|$$TO_WP_BASEURL|g" | sed -e 's|/|\\\\\\\\/|g') \
			-e $$(echo "s|$$FROM_WP_BASEURL|$$TO_WP_BASEURL|g" | sed -e 's|http[s]*://||g') \
			| gzip > $$MYSQL_DATABASE.sql.gz.converted
	@$(load_env); mv $$MYSQL_DATABASE.sql.gz $$MYSQL_DATABASE.sql.gz.old-$$(date +%s)
	@$(load_env); mv $$MYSQL_DATABASE.sql.gz.converted $$MYSQL_DATABASE.sql.gz

.PHONY: wordpress-transfert
wordpress-transfert: ##- Migrate data from env to env
wordpress-transfert: check-requirements
	@test ${from} || (echo 'from not set'; exit 1)
	@test ${to} || (echo 'to not set'; exit 1)
	@echo $(MAKE) \
		-e stage=${from} \
		wordpress-dump-mariadb \
		wordpress-dump-wp-content \
		wordpress-convert-db-to-${to}
	@echo $(MAKE) \
		-e stage=${to} \
		wordpress-restore-mariadb \
		wordpress-restore-wp-content
