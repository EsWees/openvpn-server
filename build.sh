#!/usr/bin/env bash

. varfile

docker build -f Dockerfile -t ${MSERVICE} .
