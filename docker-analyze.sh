#!/usr/bin/env bash

usage() {
    >&2 echo "Usage: ./docker-analyze.sh
    [-h|--help]
    --analysisDir <path to analysis home>
    --analysisMain <path to analysis main>
    --programDir <path to program home>
    --programMain <path to program main>
    [--absolutePath (indicates that programMain is an absolute path to a system-wide script like npm)]
    [--imageName <name of NodeProf Docker image>]
    [-- [arguments to program]]"
}

ANALYSIS_DIR=""
ANALYSIS_MAIN=""
PROGRAM_DIR=""
PROGRAM_MAIN=""
PROGRAM_ARGS=""
ABSOLUTE_PATH=false

DOCKER_IMAGE_NAME=nodeprof

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
    --imageName)
    DOCKER_IMAGE_NAME="$2"
    shift
    shift
    ;;
    --absolutePath)
    ABSOLUTE_PATH=true
    shift
    ;;
    --)
    shift # to get rid of the `--` argument
    PROGRAM_ARGS=${@:1}
    break
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
# String, String -> String
# remove the first string from the beginning of the second string
# strip_dir_from_front_of_path() {
#     
# }
ANALYSIS_DIR=$(canonicalize "$ANALYSIS_DIR")
PROGRAM_DIR=$(canonicalize "$PROGRAM_DIR")

# Ensure the Docker container exists before we attempt to use it.
if ! (docker images | grep -q "$DOCKER_IMAGE_NAME")
then
    >&2 echo "The NodeProf Docker image '$DOCKER_IMAGE_NAME' has not yet been built. Please run docker-build.sh in a shell and re-try this command after."
    exit 1
fi

# compute path to program inside docker container
if [[ $ABSOLUTE_PATH  ]]; then
    DOCKER_PROGRAM_COMMAND="${PROGRAM_MAIN}"
else
    DOCKER_PROGRAM_COMMAND="node /root/program/${PROGRAM_MAIN}"
fi

docker run --rm \
       -v $PROGRAM_DIR:/root/program \
       -v $ANALYSIS_DIR:/root/analysis \
       -it \
       ${DOCKER_IMAGE_NAME}:latest \
       bash -c \
       "(cd /root/program; \
        NODEPROF_HOME=/root/nodeprof \
        NODEPROF_ANALYSIS_PATH=/root/analysis/$ANALYSIS_MAIN \
        /root/bin/instrument ${DOCKER_PROGRAM_COMMAND} ${PROGRAM_ARGS})"
