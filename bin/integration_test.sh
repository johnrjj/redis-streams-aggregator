#!/usr/bin/env bash
set -e

TARGET="${1:-local}"
TEST_TARGET="${2:-index.js}"

if [[ ! -d test/integration/${TEST_TARGET} && ! -f test/integration/${TEST_TARGET} ]]; then
  echo "no test named '${TEST_TARGET}'"
  exit 1
fi

# Generate TAG from git commit
if [ -z "${TAG}" ]; then
  COMMIT_HASH=$(git log -1 | head -n1 | awk '{print $2}')
  TAG=$(echo $COMMIT_HASH | cut -c1-7)
fi

if [ "${3}" == "--compose-link" ]; then
  echo "Deploying local integration test container, linking via compose"
  docker run --rm -it \
    --name ${PROJECT}_integration \
    --network ${PROJECT}_default \
    -e "REDIS_URIS=redis:6379" \
    ${DOCKER_CONTAINER_NAME}:${TAG} \
    ./node_modules/.bin/mocha test/integration/${TEST_TARGET}
elif [ "${TARGET}" == "local" ]; then
  . ./bin/_find_compose_services.sh
  REDIS_URIS="${DOCKER_SRV}:${REDIS_PORT}" \
  ./node_modules/.bin/mocha test/integration/${TEST_TARGET}
else
  echo "not supported yet"
  exit 0
fi
