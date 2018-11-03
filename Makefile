docker-build:
	docker build -t rodesousa/replicator .

docker-push:
	docker push rodesousa/replicator

dep:
	mix deps.get

helmtest-install:
	helm install --name replicator-test ./chart/replicator

helmtest-delete:
	helm del --purge replicator-test
