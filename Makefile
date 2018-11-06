generate-dockerfiles-1.6:
	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.6.8' UNBOUND_SHASUM='e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49' gomplate -f 1.6/Dockerfile.tpl -o 1.6/Dockerfile_amd64
	env DK_FROM_IMAGE='arm32v7/debian:stretch' UNBOUND_VERSION='1.6.8' UNBOUND_SHASUM='e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49' gomplate -f 1.6/Dockerfile.tpl -o 1.6/Dockerfile_arm32v7
	env DK_FROM_IMAGE='arm64v8/debian:stretch' UNBOUND_VERSION='1.6.8' UNBOUND_SHASUM='e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49' gomplate -f 1.6/Dockerfile.tpl -o 1.6/Dockerfile_arm64v8

generate-dockerfiles-1.7:
	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.7.3' UNBOUND_SHASUM='c11de115d928a6b48b2165e0214402a7a7da313cd479203a7ce7a8b62cba602d' gomplate -f 1.7/Dockerfile.tpl -o 1.7/Dockerfile_amd64
	env DK_FROM_IMAGE='arm32v7/debian:stretch' UNBOUND_VERSION='1.7.3' UNBOUND_SHASUM='c11de115d928a6b48b2165e0214402a7a7da313cd479203a7ce7a8b62cba602d' gomplate -f 1.7/Dockerfile.tpl -o 1.7/Dockerfile_arm32v7
	env DK_FROM_IMAGE='arm64v8/debian:stretch' UNBOUND_VERSION='1.7.3' UNBOUND_SHASUM='c11de115d928a6b48b2165e0214402a7a7da313cd479203a7ce7a8b62cba602d' gomplate -f 1.7/Dockerfile.tpl -o 1.7/Dockerfile_arm64v8

generate-dockerfiles-latest:
	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.6.8' UNBOUND_SHASUM='e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49' gomplate -f 1.6/Dockerfile.tpl -o 1.6/Dockerfile_amd64
	env DK_FROM_IMAGE='arm32v7/debian:stretch' UNBOUND_VERSION='1.6.8' UNBOUND_SHASUM='e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49' gomplate -f 1.6/Dockerfile.tpl -o 1.6/Dockerfile_arm32v7
	env DK_FROM_IMAGE='arm64v8/debian:stretch' UNBOUND_VERSION='1.6.8' UNBOUND_SHASUM='e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49' gomplate -f 1.6/Dockerfile.tpl -o 1.6/Dockerfile_arm64v8

	env DK_FROM_IMAGE='debian:stretch' UNBOUND_VERSION='1.8.1' UNBOUND_SHASUM='c362b3b9c35d1b8c1918da02cdd5528d729206c14c767add89ae95acae363c5d' gomplate -f latest/Dockerfile.tpl -o latest/Dockerfile_amd64
	env DK_FROM_IMAGE='arm32v7/debian:stretch' UNBOUND_VERSION='1.8.1' UNBOUND_SHASUM='c362b3b9c35d1b8c1918da02cdd5528d729206c14c767add89ae95acae363c5d' gomplate -f latest/Dockerfile.tpl -o latest/Dockerfile_arm32v7
	env DK_FROM_IMAGE='arm64v8/debian:stretch' UNBOUND_VERSION='1.8.1' UNBOUND_SHASUM='c362b3b9c35d1b8c1918da02cdd5528d729206c14c767add89ae95acae363c5d' gomplate -f latest/Dockerfile.tpl -o latest/Dockerfile_arm64v8

generate-dockerfiles: generate-dockerfiles-latest generate-dockerfiles-1.7

build-1.6: generate-dockerfiles
	docker build -t mvance/unbound:1.6 1.6 -f 1latest/Dockerfile_amd64
	docker tag mvance/unbound:1.8.1 mvance/unbound:latest
	docker build -t mvance/unbound:1.6-arm32v7 1.6 -f latest/Dockerfile_arm32v7
	docker build -t mvance/unbound:1.6-arm64v8 1.6 -f latest/Dockerfile_arm64v8

build-1.7: generate-dockerfiles
	docker build -t mvance/unbound:1.7 1.7 -f 1latest/Dockerfile_amd64
	docker tag mvance/unbound:1.8.1 mvance/unbound:latest
	docker build -t mvance/unbound:1.7-arm32v7 1.7 -f latest/Dockerfile_arm32v7
	docker build -t mvance/unbound:1.7-arm64v8 1.7 -f latest/Dockerfile_arm64v8

build-latest: generate-dockerfiles
	docker build -t mvance/unbound:1.8.1 1.8.1 -f 1latest/Dockerfile_amd64
	docker tag mvance/unbound:1.8.1 mvance/unbound:latest
	docker build -t mvance/unbound:1.8.1-arm32v7 latest -f latest/Dockerfile_arm32v7
	docker build -t mvance/unbound:1.8.1-arm64v8 latest -f latest/Dockerfile_arm64v8


build: generate-dockerfiles build-latest build-1.7 build-1.6

pull:
	docker pull debian:stretch
	docker pull arm32v7/debian:stretch
	docker pull arm64v8/debian:stretch

push:
	docker push mvance/unbound:latest
	docker push mvance/unbound:1.8.1
	docker push mvance/unbound:1.8.1-arm32v7
	docker push mvance/unbound:1.8.1-arm64v8

push-eugen:
	docker tag mvance/unbound:latest eugenmayer/unbound:latest
	docker tag eugenmayer/unbound:1.8.1 eugenmayer/unbound:1.8.1
	docker tag mvance/unbound:1.8.1-arm32v7 eugenmayer/unbound:1.8.1-arm32v7
	docker tag mvance/unbound:1.8.1-arm64v8 eugenmayer/unbound:1.8.1-arm64v8
	docker push eugenmayer/unbound:latest
	docker push eugenmayer/unbound:1.8.1
	docker push eugenmayer/unbound:1.8.1-arm32v7
	docker push eugenmayer/unbound:1.8.1-arm64v8

init:
	go get github.com/hairyhenderson/gomplate/cmd/gomplate
