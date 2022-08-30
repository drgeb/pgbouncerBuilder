#!/usr/bin/env bash

BUILD_IMAGE=earthly-buildkitd
IMAGE=test/pgbouncer
TAR_BUILD=test_pgbouncer.tar
DIST_DIR=build

rm -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/logs/earthly_build.log
rm -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/test_pgbouncer.tar
if [ -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/pgbouncer_0.0.1-1_amd64.deb ]; then
    rm -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/pgbouncer_0.0.1-1_amd64.deb
fi
if [ -d ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/logs/example-apt-repo/ ]; then
    rm -rf ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/logs/example-apt-repo/
fi

docker stop ${BUILD_IMAGE} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
docker rm ${BUILD_IMAGE} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
docker rmi ${IMAGE} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

earthly -P +pgbouncer-binary 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
earthly -P +pgbouncer-package 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
earthly -P +generate-pgp-key 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
earthly -P +create-repo 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
earthly -P +repo-server 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
earthly -P +pack 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

docker load -i ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
