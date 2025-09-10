VERSION=1.0.0

docker-build:
	docker buildx build --platform linux/amd64 -t quay.io/li9/gh-rulesets:$(VERSION) .

docker-push:
	docker push quay.io/li9/gh-rulesets:$(VERSION)
