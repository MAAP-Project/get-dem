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

prefix="${CONDA_ROOT:-${HOME}/.conda}/envs/dem"

set -x # echo on
PIP_REQUIRE_VENV=0 conda env update --prefix "${prefix}" \
    --quiet --prune --solver libmamba --file "${basedir}"/environment.yml \
    "${conda_args[@]}"
set +x # echo off

if [ "${dev}" -eq 1 ]; then
    set -x # echo on
    PIP_REQUIRE_VENV=0 conda env update --prefix "${prefix}" \
        --quiet --solver libmamba --file "${basedir}"/environment-dev.yml \
        "${conda_args[@]}"
    "${CONDA_EXE:-conda}" run --prefix "${prefix}" \
        python -Xfrozen_modules=off -m ipykernel install \
        --user --name dem --display-name "Get DEM (Python)"
    set +x # echo off
fi
