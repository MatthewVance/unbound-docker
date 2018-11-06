generate-dockerfiles:
	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.8.1' UNBOUND_SHASUM='c362b3b9c35d1b8c1918da02cdd5528d729206c14c767add89ae95acae363c5d' gomplate -f generic/Dockerfile.tpl -o generic/Dockerfile_amd64
	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.8.1' UNBOUND_SHASUM='c362b3b9c35d1b8c1918da02cdd5528d729206c14c767add89ae95acae363c5d' gomplate -f generic/Dockerfile.tpl -o generic/Dockerfile_arm32v7
	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.8.1' UNBOUND_SHASUM='c362b3b9c35d1b8c1918da02cdd5528d729206c14c767add89ae95acae363c5d' gomplate -f generic/Dockerfile.tpl -o generic/Dockerfile_arm64v8

pull:
	docker pull debian:stretch
	docker pull arm32v7/debian:stretch
	docker pull arm64v8/debian:stretch

build-1.8.1: generate-dockerfiles
#	docker build -t mvance/unbound:1.8.1 1.8.1 -f 1generic/Dockerfile_amd64
#	docker tag mvance/unbound:1.8.1 mvance/unbound:latest
#	docker build -t mvance/unbound:1.8.1-arm32v7 generic -f generic/Dockerfile_arm32v7
#	docker build -t mvance/unbound:1.8.1-arm64v8 generic -f generic/Dockerfile_arm64v8

	docker build -t eugenmayer/unbound:1.8.1 generic -f generic/Dockerfile_amd64
	docker tag eugenmayer/unbound:1.8.1 eugenmayer/unbound:latest
	docker build -t eugenmayer/unbound:1.8.1-arm32v7 generic -f generic/Dockerfile_arm32v7
	docker build -t eugenmayer/unbound:1.8.1-arm64v8 generic -f generic/Dockerfile_arm64v8

build: generate-dockerfiles build-1.8.1

push:
#	docker push mvance/unbound:latest
#	docker push mvance/unbound:1.8.1
#	docker push mvance/unbound:1.8.1-arm32v7
#	docker push mvance/unbound:1.8.1-arm64v8

	docker push eugenmayer/unbound:latest
	docker push eugenmayer/unbound:1.8.1
	docker push eugenmayer/unbound:1.8.1-arm32v7
	docker push eugenmayer/unbound:1.8.1-arm64v8

init:
	go get github.com/hairyhenderson/gomplate/cmd/gomplate
