build:
	docker build -t go-rest -f ./docker/dev/Dockerfile ./server

start-server:
	docker run -p 4321:4321 --rm --name go-test-rest -v $(shell pwd)/server:/app go-rest

make-migration:
	docker run -v $(shell pwd)/migrations/sql:/migrations migrate/migrate create -ext sql -dir ./migrations -seq ${migration_name}
mm: make-migration

migrate:
	docker run -v $(shell pwd)/migrations/sql:/migrations --network host migrate/migrate -path=/migrations/ -database postgres://postgres:password@host.docker.internal:3432/go_test?sslmode=disable up
m: migrate

count ?= 1 # use -all to go all the way down
migrate-down:
	docker run -v $(shell pwd)/migrations/sql:/migrations --network host migrate/migrate -path=/migrations/ -database postgres://postgres:password@host.docker.internal:5432/go_test?sslmode=disable down ${count}

start-db:
	docker run --rm -p 3432:5432 --name go-rest-postgres -v $(shell pwd)/pgData:/var/lib/postgresql/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=go_test -e PGDATA=/var/lib/postgresql/data/pgdata postgres:14
