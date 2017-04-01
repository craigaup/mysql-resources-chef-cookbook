.PHONY: test
all: update foodcritic cookstyle create converge verify shutdown

install:
	berks install

update:
	berks update

prepare:
	test ! -f .kitchen/default-debian-docker-jessie.yml || docker start `awk '/container_id:/{print $$2}' .kitchen/default-debian-docker-jessie.yml` || kitchen destroy
	test ! -f .kitchen/default-debian-docker-jessie.yml || docker inspect -f '{{ (index (index .NetworkSettings.Ports "22/tcp") 0).HostPort }}' $$(awk '/container_id:/{print $$2}' .kitchen/default-debian-docker-jessie.yml) | xargs -I '{}' -- sed -i -e "s/^port:.*$$/port: {}/g" .kitchen/default-debian-docker-jessie.yml || kitchen destroy

create: prepare
	kitchen create || kitchen destroy

converge:
	kitchen converge

verify:
	kitchen verify

foodcritic:
	foodcritic .

cookstyle:
	cookstyle --fail-level C --display-cop-names --color .

shutdown:
	test ! -f .kitchen/default-debian-docker-jessie.yml || docker stop `cat .kitchen/default-debian-docker-jessie.yml | grep container_id | cut -d: -f2`

upload:
	berks upload --ssl-verify=false

destroy:
	kitchen destroy

login:
	@docker exec -it `awk '/container_id:/{print $$2}' .kitchen/default-debian-docker-jessie.yml` bash
