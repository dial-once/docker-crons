NAMESPACE = dialonce
IMAGE = crons
VERSION ?= latest

build:
	docker build -t $(NAMESPACE)/$(IMAGE) .

debug:
	docker run -it $(NAMESPACE)/$(IMAGE) bash

run:
	docker run -it $(NAMESPACE)/$(IMAGE) --env-file env-test

push:
	docker login -e $(DOCKER_EMAIL) -u $(DOCKER_USER) -p $(DOCKER_PASS)
	docker push $(NAMESPACE)/$(IMAGE):$(VERSION)

.PHONY: build
