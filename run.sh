#!/usr/bin/env bash

set -eou pipefail

# This is intended for running DPS jobs.  It maps positional-only arguments to
# the argument structure expected by the `get_dem.py` script.

function stderr() {
    echo "$@" 1>&2
}

function usage() {
    stderr "usage: $0 bbox compute scalene_args"
    stderr ""
    stderr "Fetch DEM tiles within a bounding box from the Copernicus DEM in"
    stderr "the AWS Open Data registry, stitch them together with GDAL, and"
    stderr "create a single GeoTIFF DEM at 'output/dem.tif'."
    stderr ""
    stderr "positional arguments:"
    stderr "  bbox      Bounding box in the format 'LEFT BOTTOM RIGHT TOP'."
    stderr "            Space-separated string of four numbers (i.e. must be"
    stderr "            enclosed in quotes). The numbers are in decimal degrees."
    stderr "            Example: '-156 18.8 -154.7 20.3' (note the quotes)"
    stderr "  compute   (optional) Flag to perform compute-intensive,"
    stderr "            multi-core linear algebra computations on the"
    stderr "            DEM raster, for benchmarking compute.  To enable, pass"
    stderr "            any truthy value (case-insensitive): true, yes, on, or 1."
    stderr "            Otherwise, pass '' or any non-truthy value to disable."
    stderr "  scalene_args"
    stderr "            (optional) Arguments to pass to the 'scalene' profiler."
    stderr "            Pass the desired arguments as a single string enclosed"
    stderr "            in quotes. Example: '--json --outfile output/profile.json'"
    stderr ""
}

function parse_flag() {
    # If the first argument is "truthy" (case-insensitive), echo the second argument.
    [[ ${1,,} =~ true|yes|on|1 ]] && echo "${2}" || echo ""
}

function parse_args() {
    n_expected_args=3

    if [[ $# -ne ${n_expected_args} ]]; then
        usage
        stderr ""
        stderr "ERROR: Expected ${n_expected_args} arguments, but got $#:" "$@"

        if [[ $# -gt $n_expected_args ]]; then
            stderr "Did you forget to enclose your arguments in quotes?"
        fi

        exit 1
    fi

    # arg 1: bounding box
    # Split the bounding box string into an array of values
    IFS=' ' read -r -a bbox <<<"${1}"

    # arg 2: compute flag
    # If the second argument is any "truthy" value, include the compute flag
    compute_flag=$(parse_flag "${2}" "--compute")

    # arg 3: scalene_args
    # Split the scalene_args string into an array of values
    IFS=' ' read -r -a scalene_args <<<"${3}"
}

# Get path to the directory containing this script
basedir=$(dirname "$(readlink -f "$0")")

# Per NASA MAAP DPS convention, all outputs MUST be written under a directory
# named 'output' relative to the current working directory.  Once the DPS job
# finishes, MAAP will copy everything from 'output' to a directory under
# 'my-private-bucket/dps_output'. Everything else on the instance will be lost.
output_dir="${PWD}"/output

parse_args "$@"

set -x

# sardem requires HOME to be set, so if it is not set, set it to /home/ops
# shellcheck disable=SC2086
AWS_NO_SIGN_REQUEST=YES HOME=${HOME:-/home/ops} \
    conda run --live-stream --name dem \
    scalene "${scalene_args[@]}" --- \
    "${basedir}"/get_dem.py \
    ${compute_flag} \
    --bbox "${bbox[@]}" \
    --output-dir "${output_dir}"
