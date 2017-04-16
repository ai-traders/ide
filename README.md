# ide - isolated development environment

Build/test/release your software in an **isolated, reproducible, well-defined** environment.

This project is more about **conventions and best practices** than actual code.

## TL;DR

Any application should be built/tested by running:

```
git clone <project-url>
ide <build-command>
```

**regadless of installed software** on the host where this was called.

`ide` is the *magical* command wrapping `docker` that will
   * fetch development environment image(s)
   * create environment where development tasks can be executed
   * mount volumes from host to container(s)

## Use cases

This project will prove to be useful in the following cases:

1. You have applications/projects that have complex and/or frequently changing
development dependencies.
2. You work on multitude of projects and it is impossible to have all dependencies
installed on your laptop/workstation.
3. To ensure developers have the same development tools that CI agents.
4. To have reproducible builds.
5. Reduce time needed by developers to setup their development environment to 0.

### Common problems solved

If you apply to IDE conventions, you'll find these, commonly occuring problems
in all organizations solved:

1. I need to setup my workstation to develop *application X*, how do I do that?
2. I just developed new feature in *application X* on my laptop, all tests passed,
but when submitted to CI system, some tests fail.
3. CI agents are always out of date. They have missing, old or conflicting dependencies installed.
Someone repeatedly wastes time on provisioning tools to CI agents.

## Requirements and responsibilities

The above benefits sound appealing, but they come at a cost. If you want to
develop applications IDE-style you'll be committing to:

1. Run **all** your builds in `docker`. By developers and by CI agents.
2. Version your docker images with all development tools.
3. In each project there must be an **Idefile** which unambiguously points
a **correct** development environment - the one that is **sufficient for exactly
this particular commit**.

## Features (specification)

Currently only docker
 images are supported to provide such an environment.

1. Run `ide <command>` which runs a docker container and invokes a `command` inside.
1. Run `ide` which runs a docker container interactively with default (set in
  Dockerfile) command invoked inside.
1. Use different docker images for different tasks by the means of various
 Idefiles.

## Why
1. To move out a project requirements from CI agents and workstation.
 As a result, CI agent does not need mono, ruby, rake, chefdk, etc.
 It never needs to execute those commands locally.
 Instead it will always spin-up docker container
 or vm and run commands there. This means:
 * no need to update CI agent deployment whenever your project environment changes
 * CI agent needs only docker daemon and client, ide installed and secrets
  provisioned
2. The docker image used as your project isolated environment can be reused across
 CI agents and workstations.

Thanks to that, we close all configuration problems of a particular
 project type in a single IDE image. You should know what your IDE image is
 capable of, what secrets and configuration it needs. Forgetting configuration
 or secret files was one of the most frequent causes of failed CI jobs for us.

## Usage
Run it from bash terminal:
```bash
ide [-c COMMAND] [options]
```
Without setting a docker or docker-compose command among options, a docker container
 will be run with default docker image command.

For more CLI options run:
```
$ ide --help
Usage: ide [-c COMMAND] [options] [CMD]
  --command | -c        Set IDE command, supported: run, pull, help, version.
                        Should be passed as first option. Default: run.
      -c run            Run docker or docker-compose run command.
      -c pull           Pull docker images specified in Idefile, do not run docker run, do not verify Idefile.
      -c help           Help. Display this message and quit.
      -c version        Version. Print version number and quit.

  Options for run command:
  --idefile /path/to/Idefile         Specify IDEFILE, default is: ./Idefile
  --dryrun                           Do not pull docker image, do not run docker run, verify Idefile. Unset by default.
  --force_not_interactive | --not_i  Do not run docker containers interactively.
  --no_rm                            Do not remove docker container after run. Unset by default.
                                     Implemented for docker driver only. Generates ./iderc file with container name.
  CMD                                Command to be run in docker container. Unset by default.

  Options for pull command:
  --idefile /path/to/Idefile         Specify IDEFILE, default is: ./Idefile
  --dryrun                           Do not pull docker image, do not run docker run, verify Idefile. Unset by default.
```

### Real example
Keep an `./Idefile`, e.g. like this:
```
IDE_DOCKER_IMAGE="xmik/ideide:1.0.3"
IDE_DOCKER_OPTIONS="--privileged"
```
and then run:
```bash
ide rake style:rubocop
```

### What happens
1. IDE determines that docker image xmik/ideide:1.0.3 is needed
1. IDE pulls xmik/ideide:1.0.3.
1. IDE decides which environment variables must be preserved into docker container
 and which must be escaped with a prefix `IDE_`. They are saved to a file e.g.
 `/tmp/ide/environment-2016-02-08_17-56-19-78638303`.
1. IDE creates a container from xmik/ideide:1.0.3 image with the following command:
    ```
    docker run --rm -v ${IDE_WORK}:/ide/work -v ${IDE_IDENTITY}:/ide/identity \
      --env-file /tmp/ide/environment-2016-02-08_17-56-19-78638303 ${IDE_DOCKER_IMAGE} \
      "rake style:rubocop"
    ```
    If your terminal was running interactively, then `-ti` is added to `docker run`
    command.
1. IDE runs `rake style:rubocop` in the container in the `/ide/work` directory.


For debug output set `IDE_LOG_LEVEL=debug`.

### Warnings, limitations
Current implementation limitations:
* works only on local docker host (docker daemon must be installed locally).
* works only on Linux.

### Configuration
The whole configuration is put in an Idefile. It is an environment variable style
 file (e.g `IDE_DRIVER=docker`). It should be put in a root directory of your
 project.

Supported variables:
* `IDE_DRIVER`, supported values: `docker`, `docker-compose`, `nvidia-docker`.
 Default: `docker` – will run docker run command
* `IDE_IDENTITY`, what on localhost should be mounted into container as
`/ide/identity`, defaults to `HOME`
* `IDE_WORK`, what on localhost should be mounted into container as
`/ide/work`, this is your working copy, your project repository;
defaults to current directory. Thanks to this, your project's code is visible
inside the container (so its has code to work on) and you can see any container's
 work result (code changes).
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

#### `docker` driver example configuration
Idefile:
```
IDE_DOCKER_IMAGE="xmik/ideide:1.0.3"
IDE_DOCKER_OPTIONS="--privileged"
```

#### `nvidia-docker` driver example configuration
Idefile:
```
IDE_DRIVER="nvidia-docker"
IDE_DOCKER_IMAGE="some_nvidia_image:latest"
```
This driver differs from `docker` driver in 1 way only: instead of `docker run`
 command, it uses `nvidia-docker run`. You have to have installed: [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

#### `docker-compose` driver example configuration
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
  image: "xmik/ideide:1.0.3"
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
    image: "xmik/ideide:1.0.3"
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

## Installation
The only dependency is Bash and Docker.

There are several ways of installing IDE, choose one:
1. Run:
    ```bash
    sudo bash -c "`curl -L https://raw.githubusercontent.com/ai-traders/ide/master/install.sh`"
    ```
2. Just do what [install.sh](./install.sh) says.
3. Use [ide cookbook](http://gogs.ai-traders.com/ide/cookbook-ide).
4. Run:
    ```bash
    git clone --depth 1 --single-branch https://github.com/ai-traders/ide.git
    ./ide/local_install.sh
    rm -r ./ide
    ```
    If you want to install from a specified tag, e.g. `0.7.2`, add: `-b 0.7.2` option
    to `git clone` command.

## How to create ide Docker image?
*This is a quite long documentation. You can skip it and go ahead to examples:
 [gitide](https://github.com/ai-traders/docker-gitide) or
 [ideide](https://github.com/ai-traders/docker-ideide)
 [example-ide](test/docker-example-ide),
 some images or test tools are not open source (yet)*

There is an `ide_image_scripts/install.sh` script which helps create ide Docker
 image. See: `ide_image_scripts/Readme.md`.

Frequently evolving IDE images are very ok. You should not just start using new
 tools without building and testing new dev image first.

### Name
A convention for all ide docker images names is to end them with `ide`, e.g.:
 * rubyide
 * chefide
 * gitide
 * someverylongname-ide

### Readme
The IDE image readme should note:
* which configuration or secret files must exist on host
* what is available by default, e.g. must I run `chef exec rake` or can just `rake`,
what is current directory in docker container
* example Idefile
* example command
* what is the development process

### Linux user
Docker image must have an `ide` user (actually any not-root user is fine, use
 `ide` user for convention only). It's recommended to use uid and gid 1000,
  because there is a convention that main (human) linux user has uid and gid 1000.

### Directories
If your docker image already has `/ide/work` or `/ide/identity`, they will
 be overridden, because:
   * `IDE_WORK` directory will be mounted as `/ide/work`.
   * `IDE_IDENTITY` directory will be ro mounted as `/ide/identity` (with all settings
 and secrets). This may be troublesome to support beside docker containers.

 Entrypoint should fail if `IDE_WORK`or `IDE_IDENTITY` directories do not exist.

### CMD and ENTRYPOINT
#### Configuration and secrets
* Map any settings and secrets files from IDE_IDENTITY into `/home/ide/`. Do it
 by **copying** and changing ownership and setting permissions to `ide` user.
 Do it e.g. in **`/etc/ide.d/scripts/20-ide-setup-identity.sh` script**.
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

#### UID GID problem
* The destined uid and gid are the same as the uid and gid of `/ide/work` directory.
 Thanks to [Tom's docker-uid-gid-fix](https://github.com/tomzo/docker-uid-gid-fix)
 project, we are armed with PoC how to achieve this. We change the uid and gid of
 `ide` user with the destined uid and gid.
 This is done by `/etc/ide.d/scripts/50-ide-fix-uid-gid.sh` script.
* When docker image already contains files owned by `ide` user,
  (e.g. `/ide/home`), then after changing uid and gid we have to search for all
  those files and update their ownership.
* Avoid mounting anything into `/ide/work` as root.

#### ENTRYPOINT
The entrypoint should:
* source any scripts from `/etc/ide.d/variables/*`.
* invoke any scripts from `/etc/ide.d/scripts/*`.
* enable end user to run the docker image interactively or not.
* change the current directory into `/ide/work` (this may be done in
 `/home/ide/.profile`).
* it could say which docker image name and tag it runs in.

##### Examples
You can choose `su` command to change user from root to ide. Disadvantage: the
 only possible command to invoke interactively is `/bin/bash`
 (https://aitraders.tpondemand.com/entity/8189 ). Example `su` command:
```bash
su - ide -c "$@"
```

Prefer `sudo` instead, but do remember that **`sudo` must be installed in
the docker image**. Example `sudo` command:
```bash
sudo -E -H -u ide /bin/bash -lc "$@"
```

Working example is in [entrypoint.sh](ide_image_scripts/src/entrypoint.sh)

If you want to run your ide docker image without using its default entrypoint, run e.g.:
```
docker run --rm -ti --entrypoint=/bin/bash example-ide:0.0.1 -c "/bin/bash"
```

#### CMD
Thanks to ENTRYPOINT taking care of all configuration, secrets, ownership, current
 directory, the CMD can be as simple as possible, as if you ran it on fully
 provisioned instance. Example: `rake style:rubocop` or some mono command.

Such a docker image can be run:
 * **not-interactively**: `docker run --rm -v ${PWD}/test/example-ide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro example-ide:0.0.1 "bash --version"`
 * **interactively**: `docker run -ti --rm -v ${PWD}/test/example-ide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro example-ide:0.0.1`
 * **interactively**: `docker run -ti --rm -v ${PWD}/test/example-ide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro example-ide:0.0.1 "env && /bin/bash"`

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

Examples are: chefide and ideide.

### IDE Docker image release cycle

*This is strongly work in progress and below information is obsolete*

The release cycle is very similar to the [usual docker image release cycle](http://gogs.ai-traders.com/platform/docs/src/master/ReleaseCycle/DockerImage.md),
 but there are more tests.

### Tests and build

#### ide_configs tests (Test-Kitchen tests on base docker image + recipe)
Whenever you build **ide docker image from cookbook**, **test ide configs
first**, in order to **fail fast**. How:
   * **keep a separate recipe `_ide`**. It won't install
   anything but those 3 scripts: entrypoint.sh, ide-setup-identity.sh, ide-fix-uid-gid.sh and create ide user.
   * **use fake identity**: you can have many directories with dummy identity. Some should have sth wrong e.g. be missing some secrets.
   Those dummy identities will be mounted as docker volumes.
   * verify that `ide-setup-identity.sh` works: files which must be mapped are mapped, or if not, then that clear message is shown.
   * verify that `entrypoint.sh` succeeds (or that it fails from a know cause, e.g. that docker daemon is not installed and thus cannot be started).

A working rake task:

```ruby
namespace 'itest' do
  desc 'Verify ide configs before the big provisioning, to fail fast'
  task 'ide_configs' do
    ENV['KITCHEN_YAML'] = File.expand_path("#{__FILE__}/../.kitchen.yml")
    Rake.sh('kitchen test config')
  end
end
```
You have to provide `config` kitchen suite(s) (see [chefide .kitchen.yml](http://gogs.ai-traders.com/chef/docker-chefide/blob/master/cookbook-ai_docker_chefdev/.kitchen.yml)). Run those
tests run **before the image is built**, on you docker base image.
In `.kitchen.yml` file, when **mounting docker volumes, always ensure
 absolute path**, and watch out for the gocd issue which does not set PWD env
 variable. Working example is
 ```
  volume:
          - <%= File.dirname(__FILE__) %>/test/integration/dummy_work:/ide/work
          - <%= File.dirname(__FILE__) %>/test/integration/dummy_identity:/ide/identity
 ```

#### Build docker image
Now build the docker image. You should use dockerimagerake gem, it will
 generate `imagerc` file after successful build.

#### Test-kitchen tests on docker image
After **docker image is built**, run usual test-kitchen tests e.g. that some
debian packages are installed. You can run them using a rake task like
`rake itest:kitchen:platform-suite`
or `source imagerc && chef exec bundle exec kitchen verify platform-suite`.
If your ide docker
image requires some `IDE_` environment variable, you have to set it in
`.kitchen.image.yml`, [example](http://gogs.ai-traders.com/chef/docker-chefide/blob/master/cookbook-ai_docker_chefdev/.kitchen.yml#L18).
In `.kitchen.image.yml` set **entrypoint which is not the ide entrypoint**!
When Test-Kitchen cannot start a container, it says only:
`Error response from daemon: Container <id> is not running`, it does not say why.
And sometimes you want to allow `entrypoint.sh` to fail (e.g. in the above point,
when nothing is installed and thus some daemons will not start).
 You can set entrypoint in KitchenDockerfile:

 ```ruby
 FROM <%= config[:image] %>

 ENTRYPOINT ["/bin/bash"]
 ```
 Such an entrypoint demands updated docker run command in `.kitchen.yml` file,
 e.g.: `command: -c "/sbin/my_init"` or `-c 'while true; do sleep 1d; done;'`
 (I tested both).
 If you don't set command, docker logs will
 show: `/bin/sh: /bin/sh: cannot execute binary file`, because the default
 command set by kitchen-docker_cli is: `sh -c 'while true; do sleep 1d; done;'`.
 Similarly, if you set command to `/bin/bash`.

#### End user tests (RSpec)
Put them into `test/integration/end_user`.

Here you test the end user usage of your ide docker image, with end user
entrypoint and volumes. Implement them as: **RSpec tests which run docker run
commands and mount identity and work directories as docker volumes**. You can
 use the same dummy identities as in ide_configs tests.
 If your ide docker
image requires some `IDE_` environment variable, you have to set it in docker
run commands.

Those tests can use ide or just docker run command. (*Using ide here means that ide
 would have to be installed also inside another ide docker image which you use
 to run tests in (e.g. chefide). That could be troublesome because ide changes fast.*)

#### General advices
* Whenever you use dummy identity (dummy configuration and secret files) for tests,
 it would be nice to ensure, that they have proper permissions, e.g. `~/.ssh/id_rsa`
  has permissions: `600`. Git does not preserve `600` permissions.
* In Test-Kitchen tests keep 1 spec file named: `a_ide_scripts_spec.rb` so that
 it is run as the first one and it sets ide identity for the rest of the tests.
 (I think `01_ide_scripts_spec.rb` is not run as the first one).
* see also: http://gogs.ai-traders.com/docker/gem-dockerimagerake

## FAQ
> Why not mount `/home/user` as `/home/ide` but as `/ide/work`?

Because `/home/ide` has already some configuration provided by the docker
ide image and mounting it this way would shadow all the provisioned files.

## Development
Run tests this way:
```
$ ide
./tasks style
./tasks unit
./tasks itest_build_example-ide
./tasks itest

./tasks itest_install
./tasks itest_local_install
cd ide_image_scripts && ./tasks itest_build_images && ./tasks itest
```
The `tasks` file contains guidelines how to install testing software.

### Unit tests
Unit tests run either bash functions or invoke ide command with `--dryrun`
 option. They never create any docker containers or pull/create docker images.

### Contributions
**Should you contribute a PR, just create your feature branch from master.**

Git branching that leads to new release: create your feature branch(es) from master
 and if you are ready to have it ci-tested, merge your feature branch(es)
 onto ci branch. Then, work on ci branch until all tests on ci are passed.

### TODOs
1. Apply https://github.com/progrium/bashstyle style guide.

## License

This project is licensed under the [GNU Lesser General Public License v3.0](http://choosealicense.com/licenses/lgpl-3.0/) license.
