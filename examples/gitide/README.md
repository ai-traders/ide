# gitide

Example docker image construction and usage for IDE project.

## Configuration
Those files are used inside gitide docker image:
1. `~/.ssh/config` -- it must exist locally (on docker host), if it doesn't contain
 any secrets, then it could be entirely generated inside docker container (but
 currently is not)
2. `~/.ssh/id_rsa` -- it must exist locally, because it is a secret
2. `~/.gitconfig` -- if exist locally, will be copied
3. `/home/ide/.profile` -- will be generated on docker container start, in order
 to ensure current directory is `/ide/work`.

## Usage
By default current directory is `/ide/work`. Example command:
```bash
ide "git clone git@git.ai-traders.com:edu/bash.git && ls -la bash && pwd"
```
