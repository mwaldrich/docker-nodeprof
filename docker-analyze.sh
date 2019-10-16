#!/usr/bin/env bash

usage() {
    >&2 echo "Usage: ./docker-analyze.sh
    [-h|--help]
    [--analysisDir <path to analysis home>]
    [--analysisMain <path to analysis main>]
    [--programDir <path to program home>]
    [--programMain <path to program main>]"
}

ANALYSIS_DIR=""
ANALYSIS_MAIN=""
PROGRAM_DIR=""
PROGRAM_MAIN=""

INPUT_FILE=""
OUTPUT_FILE=""
DOCKER_OPTIONS=""
DOCKER_IMAGE_NAME=""
MX_OPTIONS=""

# Parse arguments.
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    usage
    exit 0
    ;;
    --analysisDir)
    ANALYSIS_DIR="$2"
    shift
    shift
    ;;
    --analysisMain)
    ANALYSIS_MAIN="$2"
    shift
    shift
    ;;
    --programDir)
    PROGRAM_DIR="$2"
    shift
    shift
    ;;
    --programMain)
    PROGRAM_MAIN="$2"
    shift
    shift
    ;;
    # Unknown argument
    *)
    usage
    exit 1
esac
done

# If the user did not specify enough information, print the usage and
# terminate.
if [[ -z "$ANALYSIS_DIR" ]] || [[ -z "$ANALYSIS_MAIN" ]] || [[ -z "$PROGRAM_DIR" ]] ||  [[ -z "$PROGRAM_MAIN" ]]
then
    usage
    exit 1
fi

# Docker doesn't allow relative paths when mounting volumes, so we must ensure
# INPUT_FILE and OUTPUT_FILE are absolute. We can do this by canonicalizing
# both paths.
canonicalize() {
    readlink -f "$@"
}
ANALYSIS_DIR=$(canonicalize "$ANALYSIS_DIR")
PROGRAM_DIR=$(canonicalize "$PROGRAM_DIR")

DOCKER_IMAGE_NAME=nodeprof

# Ensure the Docker container exists before we attempt to use it.
if ! (docker images | grep -q "$DOCKER_IMAGE_NAME")
then
    >&2 echo "The NodeProf Docker image '$DOCKER_IMAGE_NAME' has not yet been built. Please run docker-build.sh in a shell and re-try this command after."
    exit 1
fi

docker run --rm \
       -v $PROGRAM_DIR:/root/program \
       -v $ANALYSIS_DIR:/root/analysis \
       ${DOCKER_IMAGE_NAME}:latest \
       bash -c \
       "(cd /root/program; \
       /root/mx/mx -p /root/nodeprof/ jalangi \
         --analysis /root/analysis/$ANALYSIS_MAIN \
         /root/program/$PROGRAM_MAIN)"
