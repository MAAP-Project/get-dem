#!/usr/bin/env bash

set -eou pipefail

basedir=$(dirname "$(readlink -f "$0")")

set -x  # echo on
PIP_REQUIRE_VENV=0 conda env update --solver libmamba --file "${basedir}"/environment.yml "$@"
