#!/usr/bin/env bash

set -eou pipefail

basedir=$(dirname "$(readlink -f "$0")")
dev=0
conda_args=()

while ((${#})); do
    case "${1}" in
    --dev)
        dev=1
        ;;
    *)
        conda_args+=("${1}")
        ;;
    esac

    shift
done

set -x # echo on
PIP_REQUIRE_VENV=0 conda env update --prune --solver libmamba --file "${basedir}"/environment.yml "$@"
set +x # echo off

if [ "${dev}" -eq 1 ]; then
    set -x # echo on
    PIP_REQUIRE_VENV=0 conda env update --solver libmamba --file "${basedir}"/environment-dev.yml "$@"
    set +x # echo off
fi
