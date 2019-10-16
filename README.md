This repo contains Docker-related files for NodeProf. It contains scripts to be run *inside* the Docker container, along with housing cloned NodeProf repos.

Its directory structure is roughly:

```
docker-nodeprof/   # For everything Docker-related
  nodeprof-repos/  # For NodeProf repos
    vanilla/       # Vanilla version, created after running docker-build.sh
      nodeprof.js/ # Actual clone
    <other-tag>/   # Other version, created by you
      nodeprof.js/ # Actual clone
  # Scripts
  docker-build.sh
  docker-analyze.sh
  ...
```
