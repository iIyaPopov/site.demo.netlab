include .env

SITE_DIR := site/

DOCKER_IMAGE := docker.io/squidfunk/mkdocs-material:9.6.7
DOCKER_NAME := mkdocs-material
DOCKER_PORT := -p 8080:8000
DOCKER_MOUNT := -v ${CURDIR}:/docs

DOCKER_SERVE_OPTIONS := --rm -it ${DOCKER_PORT} ${DOCKER_MOUNT} --name ${DOCKER_NAME}
SERVE_OPTIONS := -a 0.0.0.0:8000 -f ./mkdocs.localhost.yml

DOCKER_BUILD_OPTIONS := --rm -it ${DOCKER_MOUNT} --name ${DOCKER_NAME}
BUILD_OPTIONS := -d ${SITE_DIR} --config-file ./mkdocs.github.yml

GITHUB_PAGES_BRANCH := gh-pages


init: local-git-config
	cat << .env.template > .env


serve: clean
	docker run ${DOCKER_SERVE_OPTIONS} ${DOCKER_IMAGE} \
		serve ${SERVE_OPTIONS}


build: clean
	docker run ${DOCKER_BUILD_OPTIONS} ${DOCKER_IMAGE} \
		build ${BUILD_OPTIONS}
	chown -R ${SUDO_UID}:${SUDO_GID} ${SITE_DIR}


publish:
	git branch -D ${GITHUB_PAGES_BRANCH}
	git switch --orphan ${GITHUB_PAGES_BRANCH}
	mv site/ docs/
	git add docs/
	git commit -m "Auto build and commit of site dir"
	git switch main

push-to-github:
	git push --force github ${GITHUB_PAGES_BRANCH}


clean:
	rm -rf ${SITE_DIR}


local-git-config:
	@git config --local user.name ${GIT_CONFIG_USER_NAME}
	@git config --local user.email ${GIT_CONFIG_USER_EMAIL}
	@git remote set-url github https://${GITHUB_CREDS}@${GITHUB_REPO_URL} \
		|| git remote add github https://${GITHUB_CREDS}@${GITHUB_REPO_URL}


.PHONY: serve build clean git_init publish init local-git-config