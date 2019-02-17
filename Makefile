docker-build:
	docker build -t rodesousa/replicator .

docker-push:
	docker push rodesousa/replicator

dep:
	mix deps.get

helm-test-install:
	helm install --name replicator-test ./chart/replicator

helm-test-delete:
	helm del --purge replicator-test

compile:
	iex -S mix compile

run:
	iex -S mix
