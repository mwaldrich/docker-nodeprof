#!/usr/bin/env bash

usage(){
    >&2 echo "Usage: ./docker-analyze-file.sh <analysis> <program to instrument>"
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

# Get directory of THIS script. This will be used to execute
# the `docker-analyze.sh` script, which should be located in
# the same directory as this script.
SCRIPT_DIRECTORY="$(dirname ${BASH_SOURCE[0]})"

"${SCRIPT_DIRECTORY}"/docker-analyze.sh --analysisDir $(dirname $1) \
                    --analysisMain $(basename $1) \
                    --programDir $(dirname $2) \
                    --programMain $(basename $2)
