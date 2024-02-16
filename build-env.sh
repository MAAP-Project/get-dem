#!/usr/bin/env bash

set -eou pipefail

basedir=$(dirname "$(readlink -f "$0")")

conda env create --solver libmamba -f "${basedir}"/environment.yml
