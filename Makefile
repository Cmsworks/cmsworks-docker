up: docker-up
down: docker-down
restart: docker-down docker-up
init: docker-down-clear cmsworks-clear docker-pull docker-build docker-up cmsworks-init
test: cmsworks-test
test-coverage: cmsworks-test-coverage
test-unit: cmsworks-test-unit
test-unit-coverage: cmsworks-test-unit-coverage

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

cmsworks-init: cmsworks-composer-install cmsworks-wait-db cmsworks-migrations cmsworks-fixtures cmsworks-ready

cmsworks-clear:
	docker run --rm -v ${PWD}/app:/app --workdir=/app alpine rm -f .ready

cmsworks-composer-install:
	docker-compose run --rm cmsworks-php-fpm composer install

cmsworks-wait-db:
	until docker-compose exec -T cmsworks-postgres pg_isready --timeout=0 --dbname=cmsworks ; do sleep 1 ; done

cmsworks-migrations:
	docker-compose run --rm cmsworks-php-fpm php bin/console doctrine:migrations:migrate --no-interaction

cmsworks-fixtures:
	docker-compose run --rm cmsworks-php-fpm php bin/console doctrine:fixtures:load --no-interaction

cmsworks-ready:
	docker run --rm -v ${PWD}/app:/app --workdir=/app alpine touch .ready

cmsworks-test:
	docker-compose run --rm cmsworks-php-fpm php bin/phpunit

cmsworks-test-coverage:
	docker-compose run --rm cmsworks-php-fpm php bin/phpunit --coverage-clover var/clover.xml --coverage-html var/coverage

cmsworks-test-unit:
	docker-compose run --rm cmsworks-php-fpm php bin/phpunit --testsuite=unit

cmsworks-test-unit-coverage:
	docker-compose run --rm cmsworks-php-fpm php bin/phpunit --testsuite=unit --coverage-clover var/clover.xml --coverage-html var/coverage
