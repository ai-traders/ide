# ide - isolated development environment

Build/test/release your software in an **isolated, reproducible, well-defined** environment.
This project is more about **conventions and best practices** than actual code.

## Installation
There are several ways of installing `ide`, **choose one**:
1. Run:
    ```bash
    sudo bash -c "`curl -L https://raw.githubusercontent.com/ai-traders/ide/master/install.sh`"
    ```
2. Just do what [install.sh](./install.sh) says.
3. Use private [ide cookbook](http://gogs.ai-traders.com/ide/cookbook-ide).
4. Run:
    ```bash
    git clone --depth 1 --single-branch https://github.com/ai-traders/ide.git
    ./ide/local_install.sh
    rm -r ./ide
    ```
    If you want to install from a specified tag, e.g. `0.8.0`, add: `-b 0.8.0` option
    to `git clone` command.

### Dependencies
* Bash
* Docker

## Usage
Create a file: `./Idefile`, e.g. like this:
```
IDE_DOCKER_IMAGE="xmik/ideide:3.0.1"
IDE_DOCKER_OPTIONS="--privileged"
```

**Idefile** points to a development environment - the one that is **suitable
 for exactly this particular commit**.

### Run not interactively
Run:
```bash
$ ide bats --version
17-04-2017 16:07:55 IDE info: docker command will be:
docker run --rm -v /home/ewa/code/ide:/ide/work -v /home/ewa:/ide/identity:ro --env-file="/tmp/ide/environment-ide-ide-2017-04-17_16-07-55-85219559" -v /tmp/.X11-unix:/tmp/.X11-unix --privileged -ti --name ide-ide-2017-04-17_16-07-55-85219559 xmik/ideide:3.0.1 "shpec --version"
Unable to find image 'xmik/ideide:3.0.1' locally
3.0.1: Pulling from xmik/ideide
# pulling docker image
usermod: no changes
ide init finished (interactive shell)
using ideide:3.0.1
Bats 0.4.0
```

What happens:
1. IDE determines that docker image xmik/ideide:3.0.1 is needed
1. IDE creates a container from xmik/ideide:3.0.1 image with the following command:
   ```
   docker run --rm -v ${IDE_WORK}:/ide/work -v ${IDE_IDENTITY}:/ide/identity:ro \
     --env-file /tmp/ide/environment-2016-02-08_17-56-19-78638303 ${IDE_DOCKER_IMAGE} \
     "bats --version"
   ```
1. IDE runs `bats --version` in the container in the `/ide/work` directory.

### Run Interactively
Run:
```bash
$ ide
17-04-2017 16:10:06 IDE info: docker command will be:
docker run --rm -v /home/ewa/code/ide:/ide/work -v /home/ewa:/ide/identity:ro --env-file="/tmp/ide/environment-ide-ide-2017-04-17_16-10-05-40045882" -v /tmp/.X11-unix:/tmp/.X11-unix --privileged -ti --name ide-ide-2017-04-17_16-10-05-40045882 xmik/ideide:3.0.1
usermod: no changes
ide init finished (interactive shell)
using ideide:3.0.1
ide@fac6c0976cd1:/ide/work$ echo hello
hello
ide@fac6c0976cd1:/ide/work$ whoami
ide
ide@fac6c0976cd1:/ide/work$ exit
exit
$
```

What happens:
1. IDE determines that docker image xmik/ideide:3.0.1 is needed
1. IDE creates a container from xmik/ideide:3.0.1 image with the following command:
   ```
   docker run --rm -v ${IDE_WORK}:/ide/work -v ${IDE_IDENTITY}:/ide/identity:ro \
     --env-file /tmp/ide/environment-2016-02-08_17-56-19-78638303 ${IDE_DOCKER_IMAGE}
   ```
1. IDE runs the default command for a docker image, it is `/bin/bash` for `xmik/ideide`.


### Warnings, limitations
Current implementation limitations:
* works only on local docker host (docker daemon must be installed locally).
* works only on Linux (tested on Ubuntu and Alpine).

### Advanced usage
For debug output set `IDE_LOG_LEVEL=debug`.

```bash
$ ide --help
Usage: /usr/bin/ide [-c COMMAND] [options]
  --command  | -c                    Set IDE command, supported: run, pull, help, version.
                                     Should be passed as first option. Default: run.

  -c run                             Run docker or docker-compose run command.
  -c pull                            Pull docker images specified in Idefile, do not run docker run, do not verify Idefile.
  -c help    | --help                Help. Display this message and quit.
  -c version | --version             Version. Print version number and quit.

  Options for run command:
  --idefile /path/to/Idefile         Specify IDEFILE, default is: ./Idefile
  --dryrun                           Do not pull docker image, do not run docker run, verify Idefile.
                                     Unset by default.
  --force_not_interactive | --not_i  Do not run docker containers interactively.
  --no_rm                            Do not remove docker containers after run. Unset by default.
                                     Implemented for docker driver only. Generates ./iderc and ./iderc.txt
                                     files with container name.
  CMD                                Command to be run in a docker container. Unset by default.

  Options for pull command:
  --idefile /path/to/Idefile         Specify IDEFILE, default is: ./Idefile
  --dryrun                           Do not pull docker image, do not run docker run, verify Idefile.
                                     Unset by default.
```


### Configuration
Configuration is kept in an Idefile. It is an environment variable style
 file (e.g `IDE_DRIVER=docker`). It should be put in a root directory of your
 project.

Supported variables:
* `IDE_DRIVER`, supported values: **docker**, **docker-compose**, **nvidia-docker**.
 Default: **docker**
* `IDE_IDENTITY`, **a directory on localhost** to be read-only mounted into container as
`/ide/identity`, defaults to `HOME`
* `IDE_WORK`, **a directory on localhost** to be read-write mounted into container as
`IDE_WORK_INNER` directory. This is your working copy, your project repository.
Defaults to current directory. Thanks to this, your project's code is visible
inside the container (so its has code to work on) and you can see any container's
 work result (code changes).
* `IDE_WORK_INNER`, **a directory in docker container** to which `IDE_WORK` local
 directory is mounted. Defaults to `/ide/work`.
* variables only for **docker driver**:
  * `IDE_DOCKER_IMAGE`, the only required setting, docker image (or in the future
   maybe openstack image) to use
  * `IDE_DOCKER_OPTIONS` will append the string into docker run command. This is
  a fallback, because I can’t predict all the ide usage but I think such
  a fallback will be needed. Use it e.g. to set `--privileged` or publish ports.
  * if `DISPLAY` environment variable is set (to anything at all), then you can use ide
  with graphical applications.
* variables only for **docker-compose driver**:
  * `IDE_DOCKER_COMPOSE_FILE`, the file used by docker-compose. Default: `docker-compose.yml`.
  * `IDE_DOCKER_COMPOSE_OPTIONS` will append the string into docker-compose run
   command. This is a fallback, because I can’t predict all the ide usage but I
   think such a fallback will be needed. Use it e.g. to set `--service-ports`.

#### docker driver example configuration
Idefile:
```
IDE_DOCKER_IMAGE="xmik/ideide:3.0.1"
IDE_DOCKER_OPTIONS="--privileged"
```

#### nvidia-docker driver example configuration
Idefile:
```
IDE_DRIVER="nvidia-docker"
IDE_DOCKER_IMAGE="some_nvidia_image:latest"
```
This driver differs from `docker` driver in 1 way only: instead of `docker run`
 command, it uses `nvidia-docker run`. You have to have installed: [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

#### docker-compose driver example configuration
Example Idefile for docker-compose driver:
```bash
IDE_DRIVER="docker-compose"
```
Example docker-compose.yml version 1:
```yml
alpine:
  image: "alpine:3.5"
  entrypoint: ["/bin/sh", "-c"]
  # Uncomment this if you want to test with long running command
  # I chose short running command because it is faster to stop this container.
  # command: ["while true; do sleep 1d; done;"]
  command: ["true"]
default:
  image: "xmik/ideide:3.0.1"
  links:
  - alpine
  volumes:
  - ${IDE_IDENTITY}:/ide/identity:ro
  - ${IDE_WORK}:/ide/work
  env_file:
  - ${ENV_FILE}
```
It **has to** contain: "IDE_IDENTITY", "IDE_WORK", "ENV_FILE", mount the
 IDE_IDENTITY with `:ro` and contain a "default" docker container.
 If you want other containers, in docker-compose.yml file, to be ran too, you
 have to link them like above.

Example docker-compose.yml version 2:
```yml
version: '2'
services:
  alpine:
    image: "alpine:3.5"
    entrypoint: ["/bin/sh", "-c"]
    # Uncomment this if you want to test with long running command
    # I chose short running command because it is faster to stop this container.
    # command: ["while true; do sleep 1d; done;"]
    command: ["true"]
  default:
    image: "xmik/ideide:3.0.1"
    depends_on:
    - alpine
    volumes:
    - ${IDE_IDENTITY}:/ide/identity:ro
    - ${IDE_WORK}:/ide/work
    env_file:
    - ${ENV_FILE}
```
The same requirements apply as for docker-compose.yml version 1, but here you can
 also use `depends_on` docker-compose configuration.

## Why
We believe any project should be built/tested by running:
```bash
git clone <project-url>
ide <development-command>
```

**regadless of software installed** on the host where this was called.

### Use cases and common problems solved

`ide` is useful when:
1. **Your project often changes** and needs different development environment all the time (e.g.
 newer java, more development tools, environment configuration changes). Installing
 those on a workstation could pollute it. Installing anything without a script not reproducible at all. Reprovisioning the whole workstation is neither safe nor comfortable.
1. Your code **compiled a month ago** on your workstation, but it does not now.
 That build is not reproducible.
1. **You have a new computer/hardware/OS**. Without `ide`, you'd have to provision
 all the tools from the beginning at once (even if you already don't need a half of them).
1. Your project is **complex and needs a lot of tools** to be developed (e.g. Ruby
  and Chef and Cpp and Mono). It can be hard to install them all on one workstation.
  With `ide`, you can have many Idefiles, each one pointing to different
  development environment.
1. You work on many projects and it is **impossible to have all the versions of
 development tools installed on your workstation**.
1. Your **code works on your machine**. But it does not work on some Continuous Integration.
 Your workstation and CI agent should use the same
 environment. Your project should specify which environment it needs.
 Same if there are many developers - each one should use the same environment.
 Forgetting configuration or secret files was one of the most frequent causes of failed CI jobs for us.
1. You want to show case your code to others, but don't want to force them
 to install and setup all the dependencies/development tools. Now, they can
 just run: `ide`.
1. You want to experiment, but don't want to pollute your workstation and
 you want to work on local code base. Use `ide` interactively.

`ide` wraps `docker`. It will
  * fetch development/dependencies tools
  * ensure environment configuration
  * mount volumes from host to container(s), so that source code is on your
  workstation, but the environment is in docker image

Using `ide` there is **no need to update CI agents/workstations whenever your
 project environment changes**. You only need Docker/Docker-compose, Bash and
 ide installed and some secrets available. Thanks to that, we close all configuration problems of a particular
project type in a single ide docker image.

## How to create an ide Docker image?
If you want to create a Docker image that can be used by ide, the best is to see
 [ideide](https://github.com/ai-traders/docker-ideide) and treat it as example.

First, **choose a name**. A convention for all ide docker images names is to end with 'ide', e.g.:
  * rubyide
  * cppide
  * someverylongname-ide

Then, **write a readme** to help you decide:
  * which configuration or secret files must exist on host (in IDE_IDENTITY directory)
  * what is available by default, e.g. must I run `chef exec rake` or can just `rake`,
  what is current directory in docker container
  * example Idefile
  * example command
  * what is the development process

Then, read [ide_image_scripts/Readme.md](ide_image_scripts/Readme.md) and use
 [ide_image_scripts/install.sh](ide_image_scripts/install.sh) script in your
 Dockerfile. The script helps with:

### UID GID problem and a Linux user
When we mount a volume from localhost into a docker container:
```
$ docker run -ti -v $(pwd)/test/integration:/tmp/ide-test alpine:3.5 /bin/sh
/ # ls -la /tmp/ide-test/
total 12
drwxrwxr-x    3 1000     1000          4096 Mar  7 11:24 .
drwxrwxrwt    1 root     root          4096 Apr 17 16:55 ..
drwxrwxr-x    2 1000     1000          4096 Apr 16 16:10 shpec
```
The files owner has the same UID and GID as the files owner on localhost (docker host).

Ide Docker image must have some not-root user. Use ide user for convention.
 Its uid and gid should be: 1000, because there is a convention that main (human)
 linux user has uid and gid 1000.

We need to:
  * ensure `/ide/work` and ide user home are owned by ide user with
  the uid and gid of `/ide/work` directory
  * if docker image already contains files owned by `ide` user,
    (e.g. `/ide/home`), then after changing uid and gid we have to search for all
    those files and update their ownership.
  * avoid mounting anything into `/ide/work` as root.

Thanks to [Tom's docker-uid-gid-fix](https://github.com/tomzo/docker-uid-gid-fix)
 project, we are armed with PoC how to achieve this. We change the uid and gid of
 `ide` user with the destined uid and gid. This is done by `/etc/ide.d/scripts/50-ide-fix-uid-gid.sh` script.

### ENTRYPOINT
The entrypoint should:
  * source any scripts from `/etc/ide.d/variables/*`.
  * invoke any scripts from `/etc/ide.d/scripts/*`.
  * enable end user to run the docker image interactively or not.
  * change the current directory into `/ide/work` (this may be done in
  `/home/ide/.profile`).
  * it could say which docker image name and tag it runs in.

#### Configuration and secrets management
  * Entrypoint should map any settings and secrets files from IDE_IDENTITY into
   `/home/ide/`. Do it by **copying** and changing ownership and setting permissions
   to `ide` user. Do it e.g. in **`/etc/ide.d/scripts/20-ide-setup-identity.sh` script**.
  * If you want, you can map any files from `${IDE_IDENTITY}/.bashrc.d/` and from
   `${IDE_IDENTITY}/profile.d/`, because your
   entrypoint can ensure to run in login shell. If your host's shell is interactive,
   docker will be ran interactively too.
  * Exit with non 0 status if any obligatory config or secret file does not exist
   (tell which files are missing).
  * In order to limit the requirements put on docker host, it seems better to generate
   configuration files instead of requiring them to exist on docker host (unless
   impossible or uncomfortable or configuration files contain secrets).
  * It is usually better to first copy the whole configuration directory like
   `.ssh` or `.chef`, so that any secrets are copied and then (either or not)
    generate some configs.
  * **Watch out for symlinks**: https://aitraders.tpondemand.com/entity/8464 . E.g.
    if you have dotfiles repository and you have such symlinks in your HOME like:
    `/home/user/.gitconfig -> /home/user/code/dotfiles/.gitconfig`, inside docker
    container this symlink is: `/ide/identity/.gitconfig -> /home/user/code/dotfiles/.gitconfig`
    and `/home/user/code/dotfiles/.gitconfig` does not exist.
    The only known workaround: do not have symlinks, use plain files.

#### ENTRYPOINT example
You can choose `sudo` command to change user from root to ide. Example `sudo` command:
```bash
sudo -E -H -u ide /bin/bash -lc "$@"
```

Working example is in [entrypoint.sh](ide_image_scripts/src/entrypoint.sh)

If you want to run your ide docker image without using its default entrypoint, run e.g.:
```
docker run --rm -ti --entrypoint=/bin/bash example-ide:0.0.1 -c "/bin/bash"
```

### CMD
Thanks to ENTRYPOINT taking care of all configuration, secrets, ownership, current
 directory, the CMD can be as simple as possible, as if you ran it on fully
 provisioned instance. Example: `rake style:rubocop` or some mono command.

### Docker in Docker
If your ide docker image should have docker daemon:
 * use overlay docker storage driver (#8149)
 * set `/var/lib/docker` as docker volume (#8268)
 * run such ide docker container with `--privileged`, set `IDE_DOCKER_OPTIONS="--privileged"`

Without the above, you'll see e.g.:
```
dpkg: error: error removing old backup file '/var/lib/dpkg/status-old': Operation not permitted
E: Sub-process /usr/bin/dpkg returned an error code (2)
```

### ide Docker image release cycle
Frequently evolving IDE images are very ok. You should not just start using new
tools without building and testing new dev image first.

I recommend to use local `tasks` file, just like the one ideide uses. Example tasks:
```
./tasks build # run docker build
./tasks itest # run integration tests
./tasks publish # run docker push
```

The most important is to test the end user use cases, that e.g. `ide rake build`
 will really compile your code and produce an artifact.

### Additional advice
1. It is nice to separate installing ide configs from your ide docker image logic.
 You should not mess them together in one docker RUN directive in a Dockerfile.
 You can even have 2 Dockerfiles:
   * one to just install and test ide docker image configs
   * another, which end user logic. It should use the docker image built by the 1st Dockerfile.
1. Whenever you use dummy identity (dummy configuration and secret files) for tests,
 it would be nice to ensure, that they have proper permissions, e.g. `~/.ssh/id_rsa`
  has permissions: `600`. Git does not preserve `600` permissions.

## FAQ
> Why not mount `/home/user` as `/home/ide` but as `/ide/work`?

Because `/home/ide` in ide docker image can already have some configuration
 and mounting it this way would override all the provisioned files.

## Development and contributions
1. Make changes in a feature branch, created from a git tagged commit in master branch.
1. You run tests:
    ```bash
    $ ./tasks style
    ```
    And the following tasks you can run using either default Idefile, on Ubuntu:
    ```bash
    $ ide
    ./tasks unit
    ./tasks itest_build_exampleide
    ./tasks itest

    ./tasks itest_install
    ./tasks itest_local_install
    cd ide_image_scripts && ./tasks itest_build_images && ./tasks itest
    ```
    or on Alpine:
    ```bash
    $ ide --idefile Idefile.alpine
    # same as for default Idefile
    ```
    The `tasks` file contains guidelines how to install testing software if you can't
    run in ide docker image.
1. If you decide that your code is ready, create a PR. Your job as a contributor
 is done.

Then:
1. Maintainer merges PR(s) into master branch.
1. Maintainer runs locally:
    * `./tasks bump` to bump the patch version fragment by 1 OR
    * e.g. `./tasks bump 1.2.3` to bump to a particular version
  Version is bumped in Changelog, ide_version file and OVersion backend.
1. Everything is pushed to master onto private git server.
1. CI server (GoCD) tests and releases IDE.
1. After successful CI server pipeline, an maintainer pushes master to github.

## License

This project is licensed under the [GNU Lesser General Public License v3.0](http://choosealicense.com/licenses/lgpl-3.0/) license.
