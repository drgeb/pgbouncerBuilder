#!/usr/bin/env sh

set -eu
set -o pipefail

############################################################
declare LOGS_DIR=~/logs

earthly -P +pgbouncer-binary 2>&1 | tee ${LOGS_DIR}/pgbouncer-binary.log
earthly -P +pgbouncer-package 2>&1 | tee ${LOGS_DIR}/pgbouncer-package.log
earthly -P +generate-pgp-key 2>&1 | tee ${LOGS_DIR}/generate-pgp-key.log
earthly -P +create-repo 2>&1 | tee ${LOGS_DIR}/create-repo.log
earthly -P +repo-server 2>&1 | tee ${LOGS_DIR}/repo-server.log
earthly -P +install-pgbouncer 2>&1 | tee ${LOGS_DIR}/install-pgbouncer-package.log
earthly -P +pack 2>&1 | tee ${LOGS_DIR}/pack.log