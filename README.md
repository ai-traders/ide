# ide - isolated development environment

Build/test/release your software in an isolated environment. Currently only docker
 images are supported to provide such an environment.

## Features (specification)
1. End user can run `ide <command>` and this will run a docker container and
 invoke a `command` inside.
1. End user can run `ide` and this will run a docker container interactively with
 default (set in Dockerfile) command invoked inside.
1. End user can use different docker images for different tasks. He can use
 different Idefiles for this purpose.

## Why
1. For Continuous Integration: this moves out your project requirements from CI
 agents (only linux at this point) and workstation too. As a result CI agent does
 not even need mono, ruby, rake, chefdk, etc. because CI agent would never need
 to execute those commands locally, instead it would always spin-up docker container
 or vm and run commands there. This means:
 * no need to update CI agent deployment whenever your project environment changes
 * CI agent needs only docker daemon and client, ide installed and secrets
  provisioned
2. The docker image used as your project isolated environment can be reused across
 CI agents and workstations.

## Usage
Run it from bash terminal:
```bash
ide [--idefile IDEFILE] [COMMAND]
```
Example command:
```bash
ide rake style:rubocop
```
Example configuration:
```
IDE_DOCKER_IMAGE="rubyide:0.1.0"
```

Without setting a `COMMAND`, a docker container will be run with default
 docker image command.

### Warnings
Due to current requirements, it only works on local docker host (docker daemon
 must be installed locally).

### What happens
1. IDE determines that docker image rubyide:0.1.0 is needed
1. IDE pulls rubyide:0.1.0.
1. IDE decides which environment variables must be preserved into docker container
 and which must be escaped with a prefix `IDE_`. They are saved to a file e.g.
 `/tmp/ide/environment-2016-02-08_17-56-19`.
1. IDE creates a container from rubyide:0.1.0 image with the following command:
```
docker run --rm -v ${IDE_WORK}:/ide/work -v ${IDE_IDENTITY}:/ide/identity \
  --env-file /tmp/ide/environment-2016-02-08_17-56-19 ${IDE_DOCKER_IMAGE} \
  "rake style:rubocop"
```
  If your terminal was running interactively, then `-ti` is added to `docker run`
  command.
1. IDE runs rake style:rubocop in the container in the /ide/work directory.

### Quick start
See the [Rakefile.rb](./Rakefile.rb). The example there serves also as integration
 test and concerns `gitide` docker image. Run:
```
# build docker image
$ rake itest:build_gitide
$ cd examples/gitide
# run the actual ide command
$ ../../ide "git clone git@git.ai-traders.com:edu/bash.git && ls -la bash"
```

or run the rake task if you prefer:
```
$ rake itest:test_gitide
```

For debug output set `IDE_LOG_LEVEL=debug`.

## Installation
```bash
sudo bash -c "`curl -L http://gitlab.ai-traders.com/lab/ide/raw/master/install.sh`"
```

Or just do what [install.sh](./install.sh) says.

## Configuration
The whole configuration is put in `Idefile`. It is an environment variable style
 file (e.g `IDE_DRIVER=docker`). It should be put in a root directory of your
 project.

Supported variables:
* `IDE_DRIVER`, supported values: docker, docker-compose (won’t be implemented now),
 vagrant (won’t be implemented now), defaults to docker – will run docker run command
* `IDE_DOCKER_IMAGE`, the only required setting, docker image (or in the future
 maybe openstack image) to use
* `IDE_DOCKER_OPTIONS="--privileged"` will append the string into docker run command.
 This is a fallback, because I can’t predict all the ide usage but I think such a fallback will be needed.
* `IDE_IDENTITY`, what on localhost should be mounted into container as
 `/ide/identity`, defaults to `HOME`
* `IDE_WORK`, what on localhost should be mounted into container as /ide/work,
 this is your working copy, your project repository; defaults to current directory.
 In order to let container see your working copy so that is has code to work on,
 and, in order to let you later see any container's work result (code changes).


## Docker image specification
### Name
A convention for all ide docker images names is to end them with `ide`, e.g.:
 * rubyide
 * chefide
 * gitide

### Linux user
Docker image must have an `ide` user (actually any not-root user is fine, use
 `ide` user for convention only). It's recommended to use uid and gid 1000. There
 is a convention that main (human) linux user has uid and gid 1000.

### Directories
`IDE_WORK` directory will be mounted as `/ide/work`.
`IDE_IDENTITY` directory will be ro mounted as `/ide/identity` (with all settings
 and secrets). This may be trouble to support beside docker containers.
So if your docker image already has `/ide/work` or `/ide/identity`, they will
 be overridden.

 Entrypoint should fail if `IDE_WORK`or `IDE_IDENTITY` directories do not exist.

### CMD and ENTRYPOINT
#### Configuration and secrets
The entrypoint must take care of mapping any settings and secrets files from
 IDE_IDENTITY into `/home/ide/`. Also you can map any files from `$IDE_IDENTITY/.bashrc.d/`
 into `/etc/profile.d/`, because in docker we will run as
 a logged linux user. All these mappings should be done by **copying** and changing
 ownership and setting permissions to `ide` user.

Thanks to that, we close all configuration problems of a particular project type
 in a single IDE image. You should know what your IDE image is capable of, what
 secrets and configuration it needs. Forgetting identity or config files is one of the most frequent
 causes of failed CI jobs. Here we move this problem to the earlier CI stages.
 Entrypoint should fail (or raise or exit with status 1) if any obligatory config
 or secret file does not exist (it should tell which files are missing).
 In order to limit the requirements put on docker host, it seems better to generate
 configuration files instead of requiring them to exist on docker host (unless
 impossible or uncomfortable or configuration files contain secrets).

**Advice:** if you copy from IDE_IDENTITY whole directories like `.ssh` or `.chef`,
 it is usually better to first copy the whole directory (so that any secrets
 are copied) and then (either or not) generate some configs.

**Watch out for symlinks**: https://aitraders.tpondemand.com/entity/8464 . E.g.
  if you have dotfiles repository and you have such symlinks in your HOME like:
  `/home/user/.gitconfig -> /home/user/code/dotfiles/.gitconfig`, it is not a standard
  symlink, so when copying files from IDE_IDENTITY to `/home/ide`, you would copy
  `/ide/identity/.gitconfig`, not `/ide/identity/code/dotfiles/.gitconfig`. Note
  that inside docker container this symlink is: `/ide/identity/.gitconfig -> /home/user/code/dotfiles/.gitconfig`
  and `/home/user/code/dotfiles/.gitconfig` does not exist.
  The only known workaround: do not have symlinks, use plain files.

The IDE image readme should note:
 * which configuration or secret files are needed
 * what is available by default, e.g. must I run `chef exec rake` or can just `rake`

Frequently evolving IDE images are very ok. You should not just start using new
 tools without building and testing new dev image first.

Take care of configuration and secrets mapping in `ide-setup-identity.sh` script.

#### UID GID problem
The destined uid and gid are the same as the uid and gid of `/ide/work` directory.
 Thanks to [Tom's docker-uid-gid-fix](https://github.com/tomzo/docker-uid-gid-fix)
 project, we are armed with PoC how to achieve this. We change the uid and gid of
 `ide` user with the destined uid and gid. You should avoid mounting anything into
 `/ide/work` as root. When docker image already contains files owned by `ide` user,
 (e.g. `/ide/home`), then after changing uid and gid we have to search for all
 those files and update their ownership.

Do it in `ide-fix-uid-gid.sh` script.

#### ENTRYPOINT
The entrypoint should invoke `ide-setup-identity.sh` and `ide-fix-uid-gid.sh` scripts.
 It should enable end user to run the docker image interactively or not. It should
 also change the current directory into `/ide/work` (this may be done in
 `/home/ide/.profile`).

 If you choose `su` command to change user from root to ide, then you will have
 problems that the only possible command to invoke interactively is `/bin/bash`
 (https://aitraders.tpondemand.com/entity/8189 ). Example entrypoint.sh with `su`:
```bash
#!/bin/bash
set -e
if [ -t 0 ] ; then
    /usr/bin/ide-setup-identity.sh
    /usr/bin/ide-fix-uid-gid.sh
    echo "ide init finished (interactive shell)"

    set +e
    # No "-c" option
    su - ide
else
    /usr/bin/ide-setup-identity.sh
    /usr/bin/ide-fix-uid-gid.sh
    echo "ide init finished (not interactive shell)"

    su - ide -c "$@"
fi
```

  You can instead use `sudo`, but do remember that **`sudo` must be installed in
  the docker image**. Example entrypoint.sh:
```bash
#!/bin/bash
set -e
/usr/bin/ide-setup-identity.sh
/usr/bin/ide-fix-uid-gid.sh

if [ -t 0 ] ; then
    # interactive shell
    echo "ide init finished (interactive shell)"
    set +e
else
    # not interactive shell
    echo "ide init finished (not interactive shell)"
    set -e
fi

sudo -E -H -u ide /bin/bash -lc "$@"
```

It would be nice if entrypoint said, which docker image name and tag it uses.

#### CMD
Thanks to ENTRYPOINT taking care of all configuration, secrets, ownership, current
 directory, the CMD can be as simple as possible, as if you ran it on fully
 provisioned instance. Example: `rake style:rubocop` or some mono command.

Such a docker image can be ran:
 * **not-interactively**: `docker run --rm -v ${PWD}/examples/gitide/work:/ide/work -v ${HOME}:/ide/identity:ro gitide:0.1.0 "git clone git@git.ai-traders.com:edu/bash.git && ls -la bash"`
 * **interactively**: `docker run -ti --rm -v ${PWD}/examples/gitide/work:/ide/work -v ${HOME}:/ide/identity:ro gitide:0.1.0`
 * **interactively**: `docker run -ti --rm -v ${PWD}/examples/gitide/work:/ide/work -v ${HOME}:/ide/identity:ro gitide:0.1.0 "env && /bin/bash"`

See the [examples](./examples) directory.

## Development
There is a `Rakefile.rb` and rake tasks to be used:
```
$ rake style
$ rake unit
$ rake itest:build_gitide
$ rake itest:test_gitide_dryrun
$ rake itest:test_gitide
```
The `Rakefile.rb` contains guidelines how to install testing software. If you wish,
 you can invoke them without rake.

Style guides:
 * https://github.com/progrium/bashstyle

### TODO
1. Support groups?
1. Apply https://github.com/progrium/bashstyle style guide.
