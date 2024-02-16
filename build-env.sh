#!/usr/bin/env bash

set -eou pipefail

basedir=$(dirname "$(readlink -f "$0")")

set -x  # echo on
conda env update --solver libmamba --file "${basedir}"/environment.yml "$@"
