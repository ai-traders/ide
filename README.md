# ide - isolated development environment

Build/test/release your software in an isolated environment. Currently only docker
 images are supported to provide such an environment.

## Features (specification)
1. End user can run `ide <command>` and this will run a docker container and
 invoke a `command` inside.
1. End user can use different docker images for different tasks. - not supported right now

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
ide [--group] COMMAND  
```
Example command:
```bash
ide --group=ruby rake style:rubocop
```
Example configuration:
```
IDE_RUBY_DOCKER_IMAGE="rubydev:0.1.0"
IDE_RUBY_ENV_ABC=1
```
The `group` is not required, and: **`group`s are not supported right now**.
 Use the default group by invoking:
```bash
ide COMMAND
```
e.g.:
```bash
ide rake style:rubocop
```
with configuration
```
IDE_DOCKER_IMAGE="rubydev:0.1.0"
IDE_ENV_ABC=1
```

About groups, see the description in Configuration section.

### What happens
1. IDE determines that "ruby" `group` is needed and therefore docker image rubydev:0.1.0
1. IDE tries to pull rubydev:0.1.0.
2. IDE creates a container from rubydev:0.1.0 image with the following command:
```
docker run --rm -v ${IDE_WORK}:/ide/work -v ${IDE_HOME}:/ide/identity \
  -e ABC=1 ${IDE_DOCKER_IMAGE} \
  "cd /ide/work && rake style:rubocop"
```
4. IDE runs rake style:rubocop in the container in the /ide/work directory.

## Installation
TODO!

## Configuration
The whole configuration is put in `Idefile`. It is an environment variable style
 file (e.g `IDE_DRIVER=docker`). It should be put in a root directory of your
 project.

Supported variables:
* `IDE_DRIVER`, supported values: docker, docker-compose (won’t be implemented now), vagrant (won’t be implemented now), defaults to docker – will run docker run command
* `IDE_HOME`, what on localhost should be mounted into container as /ide/identity, defaults to `HOME`
* `IDE_WORK`, what on localhost should be mounted into container as /ide/work,
 this is your working copy, your project repository; defaults to current directory
* `IDE_ENV_ABC=1`, will result in setting `ABC=1` inside the container
* `IDE_DOCKER_IMAGE`, the only required setting, docker image (or in the future maybe openstack image) to use
* `IDE_DOCKER_OPTIONS="--privileged"` will append the string into docker run command. This is a fallback, because I can’t predict all the ide usage but I think such a fallback will be needed.

In order to allow end user to use different docker images for different tasks,
 groups are introduced. Example for `BUILD` group:
```
IDE_BUILD_DOCKER_IMAGE="mono-3.2.8"
IDE_BUILD_ENV_ABC=1
```

Setting the variables without `groups` can be treated as a fallback - configuration
 for a default `group`.

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
`IDE_HOME` directory will be ro mounted as `/ide/identity` (with all settings
 and secrets). This may be trouble to support beside docker containers.
So if your docker image already has `/ide/work` or `/ide/identity`, they will
 be overridden.

 Entrypoint should fail if `IDE_WORK`or `IDE_HOME` directories do not exist.

### CMD and ENTRYPOINT
#### Configuration and secrets
The entrypoint must take care of mapping any settings and secrets files from
 `/ide/identity/` into `/home/ide/`. Also map any files from `ide/identity/.bashrc.d/`
 into `/etc/profile.d/`, because in docker we will run not-interactively, but as
 a logged linux user. All these mappings should be done by **copying** and changing
 ownership and setting permissions to `ide` user.

Thanks to that, we close all configuration problems of a particular project type
 in a single IDE image. You should know what your IDE image is capable of, what
 secrets it needs. Forgetting identity or config files is one of the most frequent
 causes of failed CI jobs. Here we move this problem to the earlier CI stages.
 Entrypoint should fail (or raise or exit with status 1) if any obligatory config
 or secret file does not exist (it should tell which files are missing).

The IDE image readme should note:
 * which configuration or secret files are needed
 * what is available by default, e.g. must I run `chef exec rake` or can just `rake`

Frequently evolving IDE images are very ok. You should not just start using new
 tools without building and testing new dev image first.

Do it in `ide-setup-identity.sh` script.
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
 also change the current directory into `/ide/work`.

#### CMD
Thanks to ENTRYPOINT taking care of all configuration, secrets, ownership, current
 directory, the CMD can be as simple as possbile, as if you ran it on fully
 provisioned instance. Example: `rake style:rubocop` or some mono command.


See the [examples](./examples) directory.
