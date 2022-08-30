#!/usr/bin/sh

earthly -P +pgbouncer-binary
earthly -P +pgbouncer-package
earthly -P +generate-pgp-key
earthly -P +create-repo
earthly -P +repo-server
earthly -P +pack
