#!/usr/bin/env bash

usage(){
    >&2 echo "Usage: ./docker-run-file.sh <analysis> <program to instrument>"
}

if [[ $# -ne 3 ]]; then
    usage
    exit 1
fi

./docker-analyze.sh --analysisDir $(dirname $1) \
                    --analysisMain $(basename $1) \
                    --programDir $(dirname $2) \
                    --programMain $(basename $2)
