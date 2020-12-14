#!/bin/sh
here=$(dirname $0)
docker build -t audiobook_tools:develop $here
