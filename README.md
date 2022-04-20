# docker-nodeprof

This repo contains a Dockerfile for [NodeProf](https://github.com/Haiyang-Sun/nodeprof.js). Shell scripts have been provided to automate the process of (a) building NodeProf, and (b) analyzing programs.

## Getting started

1. Install Docker. On Linux, install it with your package manager. On Mac, download it [here](https://download.docker.com/mac/stable/Docker.dmg).
2. In a shell, run `./docker-build.sh`.
3. In a shell, run `./docker-analyze-file.sh analysis.js program.js` to analyze a program named `program.js` with a NodeProf analysis named `analysis.js`.
  - Note: this only works if your program and analysis don't import anything. See [here](#advanced-usage).

## Advanced usage

The `docker-analyze-file.sh` script only works if the program and the analysis do not import other scripts.

If either your analysis or your program grows to more than 1 file, use the `docker-analyze.sh` script. This script provides more flexibility in what files get mounted into the Docker container.

If you need even more flexibility, you can use this image directly with `docker run` to execute arbitrary shell commands. See the `Dockerfile` itself for

## Project structure

Its directory structure is roughly:

```
docker-nodeprof/   # For everything Docker-related
  nodeprof-repos/  # For NodeProf repos
    vanilla/       # Vanilla version, created after running docker-build.sh
      nodeprof.js/ # Actual clone
    <other-tag>/   # Other version, created by you
      nodeprof.js/ # Actual clone
  # Scripts to automate Docker machinery
  docker-build.sh
  docker-analyze.sh
  ...
```
