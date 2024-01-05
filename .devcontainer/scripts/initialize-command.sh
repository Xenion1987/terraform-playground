#!/usr/bin/env bash

DOCKER_VOLUME_NAME="devcontainer-history"

if ! docker volume inspect "${DOCKER_VOLUME_NAME}" >/dev/null 2>&1; then
  docker volume create "${DOCKER_VOLUME_NAME}"
else
  echo "INITIALIZE COMMAND :: Docker volume '${DOCKER_VOLUME_NAME}' already exists - no need to create."
fi
