#!/usr/bin/env bash


############################################################
# Attempt to set APP_HOME
# Resolve links:  may be a link
PRG="$0"
# Need this for relative symlinks.
while [ -h "PRG" ] ; do
     ls=`ls -ld "$PRG"`
     link=`expr "$ls" : '.*-> .*$'`
     if expr "$link" : /.* > /dev/null; then
          PRG="$link"
     else
          PRG=`dirname "$PRG"`"/$link"
     fi
done
SAVED="`pwd`"
cd "`dirname "$PRG"`/.." >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

APP_BASE_NAME=`basename "$0"`
############################################################

export APP=pgbouncer
export APP_VERSION=0.0.1
export MACHINE_TYPE=1_amd64
export APP_IMAGE_NAME=ninjaone/${APP}
export BUILD_DIR=build_docker
export LOGS_FILE=~/logs/build-${APP}-docker-image.log

function build ()
{
    # compile and create pgbouncer executable
    cd ${APP_HOME}
    if [ ! -d ${APP_HOME}/pgbouncer ]; then
	git clone git@github.com:pgbouncer/pgbouncer.git
    fi

    cd ${APP_HOME}/pgbouncer
    git submodule init
    git submodule update
    ./autogen.sh
    ./configure --host=x86_64 --target=x86_64 --without-openssl
    make
}

function package()
{
    # package executable and create deb package
    mkdir -pv ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}/usr/bin
    mv ${APP_HOME}/pgbouncer/pgbouncer ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}/usr/bin/.
    mkdir -p ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}/DEBIAN
    cat <<EOF > ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}/DEBIAN/control
Package: pgbouncer
Version: 0.0.1
Maintainer: Gerry Bennett <gerry.bennett@ninjaone.com>
Depends: libc6
Architecture: amd64
Homepage: https://www.pgbouncer.org/
Description: PGBouncer
EOF
    mkdir -pv ${APP_HOME}/${BUILD_DIR}
    dpkg --build ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}
    
    #
    rm -rf ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}
}

function setup_image()
{
    mv ${APP_HOME}/${APP}_${APP_VERSION}-${MACHINE_TYPE}.deb ${APP_HOME}/${BUILD_DIR}/.
    echo file:///workspace/pgbouncer_0.0.1-1_amd64.deb > ${APP_HOME}/${BUILD_DIR}/Aptfile
    echo worker: pgbouncer > ${APP_HOME}/${BUILD_DIR}/Procfile
}

function build_image ()
{
    echo Building image: ${APP_IMAGE_NAME}
    cd ${APP_HOME}/${BUILD_DIR}
    echo "cd ${APP_HOME}/${BUILD_DIR}"
        # --buildpack eagle/apt-deps@0.1.0 \

    time pack build \
        --buildpack fagiani/apt \
        --buildpack paketo-buildpacks/procfile@5.2.0 \
        -B paketobuildpacks/builder:base \
        ${APP_IMAGE_NAME} \
        -v 2>&1 | tee ${LOGS_FILE}
}

################################################################################
BUILD_STEP="${1}"
echo BUILD_STEP=${BUILD_STEP}
case "${BUILD_STEP}" in
    build*)
        build
    ;;
    package*)
        package
    ;;
    containerize*)
        setup_image
        build_image
    ;;
    all*)
        build
        package
        setup_image
        build_image
    ;;
    *)
        echo "please pass in a command:"
        echo "  build        - this will clone pgbouncer, and build and create an executable."
        echo "  package      - this will generate a debian package"
        echo "  containerize - this will setup a packeto build directory and then create a container image using paketo"
    ;;
esac
