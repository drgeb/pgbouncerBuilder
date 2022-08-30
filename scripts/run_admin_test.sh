#!/usr/bin/env bash

#docker run --entrypoint bash -v $PWD:/node -u 0 --rm --name=pgbouncer -it ninjaone/pgbouncer
docker run --entrypoint bash  -u 0 --rm --name=pgbouncer -it ninjaone/pgbouncer
