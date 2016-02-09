# gitide

Example docker image construction and usage for IDE project.

## Configuration
Those files are used inside gitide docker image:
1. `~/.ssh/config` -- will be generated on docker container start
2. `~/.ssh/id_rsa` -- it must exist locally, because it is a secret
2. `~/.gitconfig` -- if exists locally, will be copied
3. `/home/ide/.profile` -- will be generated on docker container start, in
   order to ensure current directory is `/ide/work`.

## Usage
Example Idefile:
```
IDE_DOCKER_IMAGE="gitide:0.1.1"
```

By default current directory in docker container is `/ide/work`. Example command:
```bash
ide "git clone git@git.ai-traders.com:edu/bash.git && ls -la bash && pwd"
```
