#!/usr/bin/env bash

BUILD_IMAGE=earthly-buildkitd
IMAGE=test/pgbouncer
TAR_BUILD=test_pgbouncer.tar
DIST_DIR=build

rm -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/logs/earthly_build.log
rm -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/test_pgbouncer.tar
if [ -f ${DIST_DIR}/${TAR_BUILD} ]; then
    rm -f ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/pgbouncer_0.0.1-1_amd64.deb
fi
if [ -d ${DIST_DIR}/${TAR_BUILD} ]; then
    rm -rf ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee ${DIST_DIR}/logs/example-apt-repo/
fi

docker stop ${BUILD_IMAGE} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
docker rm ${BUILD_IMAGE} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
docker rmi ${IMAGE} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +pgbouncer-binary" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +pgbouncer-binary 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +pgbouncer-package" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +pgbouncer-package 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +generate-pgp-key" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +generate-pgp-key 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +create-repo" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +create-repo 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +repo-server" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +repo-server 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +install-pgbouncer" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +install-pgbouncer 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "earthly -P +pack" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
earthly -P +pack 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log

echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
echo "docker load -i ${DIST_DIR}/${TAR_BUILD}" >> ${DIST_DIR}/logs/earthly_build.log
echo "********************************************************************************" >> ${DIST_DIR}/logs/earthly_build.log
docker load -i ${DIST_DIR}/${TAR_BUILD} 2>&1 | tee -a ${DIST_DIR}/logs/earthly_build.log
