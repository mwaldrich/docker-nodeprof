#!/usr/bin/env sh

# Used to build/rebuild the Docker container.

VANILLA_GIT_REPO_URL='https://github.com/Haiyang-Sun/nodeprof.js.git'

# Function to print usage.
usage() {
    >&2 echo "Usage: ./docker-build.sh [-h|--help] [--repo <repo path>] [--imageName <Docker image name>]"
    >&2 echo ""
    >&2 echo "If --repo is not specified, it will default to \`vanilla/nodeprof.js\`, and it will be fetched automatically from ${VANILLA_GIT_REPO_URL}."
    >&2 echo ""
    >&2 echo "If --imageName is not specified, it will default to \`nodeprof\`."
}

# Default values of variables
REPO_PATH="nodeprof-clones/vanilla/nodeprof.js"
CUSTOM_REPO_PATH=0
DOCKER_IMAGE_NAME=nodeprof

# Ensure `nodeprof-clones/` exists.
mkdir -p nodeprof-clones

# Parse arguments.
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -h|--help)
            usage
            exit 0
            ;;
        --repo)
            REPO_PATH="$2"
            CUSTOM_REPO_PATH=1
            shift
            shift
            ;;
        --imageName)
            DOCKER_IMAGE_NAME="$2"
            shift
            shift
            ;;
        # Unknown argument
        *)
            usage
            exit 1
            ;;
    esac
done

# If the user didn't specify a custom NodeProf repository path,
# assume they wanted to use the default version.
# We will now ensure this repo exists and is up to date.
if [[ $CUSTOM_REPO_PATH = 0 ]]; then
    GIT_REPO=$VANILLA_GIT_REPO_URL
    REPO_NAME=nodeprof.js
    LOCAL_LOCATION=nodeprof-clones/vanilla
    REPO_PATH="${LOCAL_LOCATION}/${REPO_NAME}"

    # Actually clone NodeProf.
    mkdir -p $LOCAL_LOCATION

    # Clone/pull from the repository as necessary.
    if [ ! -d ${REPO_PATH}/.git ]
    then
        (cd $LOCAL_LOCATION; git clone $GIT_REPO)
    else
        (cd $LOCAL_LOCATION/$REPO_NAME; git pull)
    fi
fi

# Build the image.
docker build -t $DOCKER_IMAGE_NAME \
       --build-arg nodeprof_repo=$REPO_PATH \
       .
