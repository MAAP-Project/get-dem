#!/usr/bin/env bash

set -eou pipefail

conda env update --solver libmamba "$@"
