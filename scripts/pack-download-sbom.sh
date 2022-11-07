#!/usr/bin/env sh

set -eu
set -o pipefail

APP=pgbouncer
APP_IMAGE=test/pgbouncer
############################################################
pack sbom download ${APP_IMAGE}  -o ${APP}-sbom
