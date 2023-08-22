#!/bin/sh
here=$(dirname $0)
export DOCKER_BUILDKIT=0
docker build -t audiobook_tools:${1:-develop} $here
