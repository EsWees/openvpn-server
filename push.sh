#!/usr/bin/env bash

. varfile

set -e

docker tag    ${MSERVICE} ${REGISTRY}/eswees/${MSERVICE}
docker push   ${REGISTRY}/eswees/${MSERVICE}
#docker rmi -f ${REGISTRY}/eswees/${MSERVICE}
