#!/usr/bin/env sh

set -eu
set -o pipefail

############################################################
alias drit='docker run -it'
drit --entrypoint bash -u 0 --rm --name test \
    test/pgbouncer
