VERSION 0.6
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

pgbouncer-binary:
    WORKDIR /code
    RUN apt-get update && apt-get install -y git tzdata gcc build-essential cmake m4 automake libtool pandoc pkg-config libevent-dev python3
    RUN git config --global url."https://github.com/".insteadOf 'git@github.com:'
    COPY pgbouncer pgbouncer
    RUN cd pgbouncer && git submodule init && git submodule update
    RUN cd pgbouncer && ./autogen.sh
    RUN cd pgbouncer && ./configure --without-openssl
    RUN cd pgbouncer && make
    SAVE ARTIFACT pgbouncer/pgbouncer AS LOCAL build/pgbouncer

pgbouncer-package:
    WORKDIR pgbouncer-binary
    RUN mkdir -p /package/pgbouncer_0.0.1-1_amd64/DEBIAN
    RUN mkdir -p /package/pgbouncer_0.0.1-1_amd64/usr/bin
    COPY files/control /package/pgbouncer_0.0.1-1_amd64/DEBIAN/.
    COPY +pgbouncer-binary/pgbouncer /package/pgbouncer_0.0.1-1_amd64/usr/bin/.
    RUN dpkg --build /package/pgbouncer_0.0.1-1_amd64
    SAVE ARTIFACT /package/pgbouncer_0.0.1-1_amd64.deb AS LOCAL build/pgbouncer_0.0.1-1_amd64.deb

generate-pgp-key:
    WORKDIR /pgp-key
    RUN apt-get update && apt-get install -y gpg
    RUN echo "%echo Generating an example PGP key
Key-Type: RSA
Key-Length: 4096
Name-Real: example
Name-Email: example@example.com
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit" > example-pgp-key.batch
    RUN gpg --no-tty --batch --gen-key example-pgp-key.batch
    RUN gpg --armor --export example > pgp-key.public
    RUN gpg --armor --export-secret-keys example > pgp-key.private
    SAVE ARTIFACT pgp-key.public
    SAVE ARTIFACT pgp-key.private

create-repo:
    WORKDIR /apt-repo
    RUN apt-get update && apt-get install -y dpkg-dev
    COPY files/generate-release.sh /root/bin/.
    RUN mkdir -p ./pool/main/
    RUN mkdir -p ./dists/stable/main/binary-amd64
    COPY +pgbouncer-package/pgbouncer_0.0.1-1_amd64.deb ./pool/main/binary-amd64/.

    # generate Packages and Packages.gz
    RUN dpkg-scanpackages --arch amd64 pool/ > dists/stable/main/binary-amd64/Packages
    RUN cat dists/stable/main/binary-amd64/Packages | gzip -9 > dists/stable/main/binary-amd64/Packages.gz

    # generate Release
    WORKDIR /apt-repo/dists/stable
    RUN /root/bin/generate-release.sh > Release

    # sign Release
    COPY +generate-pgp-key/pgp-key.private /.
    RUN cat /pgp-key.private | gpg --import
    RUN cat /apt-repo/dists/stable/Release | gpg --default-key example -abs > /apt-repo/dists/stable/Release.gpg
    RUN cat /apt-repo/dists/stable/Release | gpg --default-key example -abs --clearsign > /apt-repo/dists/stable/InRelease

    SAVE ARTIFACT /apt-repo AS LOCAL build/example-apt-repo

repo-server:
    RUN apt-get update && apt-get install -y python3
    WORKDIR /www
    COPY +create-repo/apt-repo /www/apt-repo
    CMD ["python3", "-m", "http.server"]


test:
    COPY +generate-pgp-key/pgp-key.public /example.pgp
    COPY files/docker-compose.yml .
    WITH DOCKER --compose docker-compose.yml --load=repo-server:latest=+repo-server
        RUN \
            echo "deb [arch=amd64 signed-by=/example.pgp] http://127.0.0.1:8000/apt-repo stable main" > /etc/apt/sources.list.d/example.list && \
            apt-get update && \
            apt-get install -y pgbouncer && \
            pgbouncer
    END

pack:
    RUN apt-get update
    RUN apt-get install -y software-properties-common
    RUN add-apt-repository ppa:cncf-buildpacks/pack-cli
    RUN apt-get update
    RUN apt-get install pack-cli

    COPY +generate-pgp-key/pgp-key.public /example.pgp
    COPY files/docker-compose.yml .
    COPY files/paketo_build paketo_build
    WITH DOCKER --compose docker-compose.yml --load=repo-server:latest=+repo-server
        RUN \
            echo "deb [arch=amd64 signed-by=/example.pgp] http://127.0.0.1:8000/apt-repo stable main" > /etc/apt/sources.list.d/example.list && \
            apt-get update 2>&1 | tee pack.log && \
            cd paketo_build && \
            pack build --buildpack fagiani/apt --buildpack paketo-buildpacks/procfile@5.2.0 -B paketobuildpacks/builder:base test/pgbouncer && \
            cd - 2>&1 | tee pack.log && \
            docker save  --output test_pgbouncer.tar test/pgbouncer 2>&1 | tee pack.log && \
            ls -al
    END
    SAVE ARTIFACT pack.log AS LOCAL build/logs/pack.log
    SAVE ARTIFACT test_pgbouncer.tar AS LOCAL build/test_pgbouncer.tar