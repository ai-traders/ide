# ide - isolated development environment

Build/test/release your software in an isolated environment. Currently only docker
 images are supported to provide such an environment.

## Features (specification)
1. Run `ide <command>` which runs a docker container and invokes a `command` inside.
1. Run `ide` which runs a docker container interactively with default (set in
  Dockerfile) command invoked inside.
1. Use different docker images for different tasks by the means of various
 Idefiles.

## Why
1. For Continuous Integration: this moves out your project requirements from CI
 agents and workstation too. As a result CI agent does
 not even need mono, ruby, rake, chefdk, etc. It never needs to execute those
 commands locally. Instead it will always spin-up docker container
 or vm and run commands there. This means:
 * no need to update CI agent deployment whenever your project environment changes
 * CI agent needs only docker daemon and client, ide installed and secrets
  provisioned
2. The docker image used as your project isolated environment can be reused across
 CI agents and workstations.

Thanks to that, we close all configuration problems of a particular project type
 in a single IDE image. You should know what your IDE image is capable of, what
 secrets and configuration it needs. Forgetting identity or config files is one
 of the most frequent
 causes of failed CI jobs. Here we move this problem to the earlier CI stages.

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

### Warnings, limitations
Current implementation limitations:
* works only on local docker host (docker daemon must be installed locally).
* works only on Linux.

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

For debug output set `IDE_LOG_LEVEL=debug`.

### Configuration
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

## Installation
```bash
sudo bash -c "`curl -L http://gitlab.ai-traders.com/lab/ide/raw/master/install.sh`"
```

Or just do what [install.sh](./install.sh) says.

## How to create ide Docker image?
*This is a quite long documentation. You can skip it and go ahead to examples:
 [gitide](http://gitlab.ai-traders.com/lab/gitide) or [chefide](http://gitlab.ai-traders.com/chef/docker-chefide)*

Frequently evolving IDE images are very ok. You should not just start using new
 tools without building and testing new dev image first.

### Name
A convention for all ide docker images names is to end them with `ide`, e.g.:
 * rubyide
 * chefide
 * gitide

### Readme
The IDE image readme should note:
* which configuration or secret files must exist on host
* what is available by default, e.g. must I run `chef exec rake` or can just `rake`,
what is current directory in docker container
* example Idefile
* example command

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
* If you want, you can map any files from `$IDE_IDENTITY/.bashrc.d/` and from
 `/IDE_IDENTITY/profile.d/`, because your
 entrypoint can ensure to run in login shell. If your host's shell is interactive,
 docker will be ran interactive shell too.
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
* Take care of configuration and secrets mapping in `/usr/bin/ide-setup-identity.sh` script.

#### UID GID problem
* The destined uid and gid are the same as the uid and gid of `/ide/work` directory.
 Thanks to [Tom's docker-uid-gid-fix](https://github.com/tomzo/docker-uid-gid-fix)
 project, we are armed with PoC how to achieve this. We change the uid and gid of
 `ide` user with the destined uid and gid.
* When docker image already contains files owned by `ide` user,
  (e.g. `/ide/home`), then after changing uid and gid we have to search for all
  those files and update their ownership.
* Avoid mounting anything into `/ide/work` as root.
* Do it in `/usr/bin/ide-fix-uid-gid.sh` script.

#### ENTRYPOINT
The entrypoint should:
* invoke `ide-setup-identity.sh` and `ide-fix-uid-gid.sh` scripts.
* enable end user to run the docker image interactively or not.
* change the current directory into `/ide/work` (this may be done in
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

  Prefer `sudo` instead, but do remember that **`sudo` must be installed in
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

It would be nice if entrypoint said, which docker image name and tag it uses
 (gitide does that).

#### CMD
Thanks to ENTRYPOINT taking care of all configuration, secrets, ownership, current
 directory, the CMD can be as simple as possible, as if you ran it on fully
 provisioned instance. Example: `rake style:rubocop` or some mono command.

Such a docker image can be ran:
 * **not-interactively**: `docker run --rm -v ${PWD}/examples/gitide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro gitide:0.1.0 "git clone git@git.ai-traders.com:edu/bash.git && ls -la bash"`
 * **interactively**: `docker run -ti --rm -v ${PWD}/examples/gitide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro gitide:0.1.0`
 * **interactively**: `docker run -ti --rm -v ${PWD}/examples/gitide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro gitide:0.1.0 "env && /bin/bash"`

See the [examples](./examples) directory and also:
 * http://gitlab.ai-traders.com/lab/docs/blob/master/ReleaseCycle/DockerImageIDE.md
 * http://gitlab.ai-traders.com/lab/docs/blob/master/ReleaseCycle/DockerImage.md

### Docker in Docker
If your ide docker image should have docker daemon:
 * use overlay docker storage driver (#8149)
 * set `/var/lib/docker` as docker volume (#8268)
 * run such ide docker container with `--privileged`

Without the above, you'll see e.g.:
```
dpkg: error: error removing old backup file '/var/lib/dpkg/status-old': Operation not permitted
E: Sub-process /usr/bin/dpkg returned an error code (2)
```

Examples are: chefide and ideide.

### IDE Docker image release cycle

The release cycle is very similar to the usual docker image release cycle, but
 there are more tests.

### Tests

1. Whenever you build docker image from cookbook, **keep a separate recipe `_ide`**
 so that you can provision only with that recipe and test the configs. You can
 then **test ide configs first**, in order to **fail fast**. Do not install
 anything but those 3 scripts: entrypoint.sh, ide-setup-identity.sh, ide-fix-uid-gid.sh.
 Use fake identity, verify that those files which must be copied are copied,
 verify that entrypoint.sh succeeds (or that it fails from a know cause, e.g.
 that docker daemon is not installed and thus cannot be started). A working rake task:

  ```ruby
  namespace 'itest' do
    desc 'Verify ide configs before the big provisioning, to fail fast'
    task 'ide_configs' do
      ENV['KITCHEN_YAML'] = File.expand_path("#{__FILE__}/../.kitchen.yml")
      Rake.sh('kitchen test config')
    end
  end
  ```
  You have to provide `config` kitchen suite (see chefide). You can test if some
  file was mounted (as docker volume), copied, generated, etc.
  This should be run **before the image is built**.
2. Then run usual tests e.g. that some debian packages are installed.
 Run with test-kitchen, usually with serverspec, use dockerimagerake gem.
3. Run end user tests, they can use ide or not. Using ide here means that ide
 would have to be installed also inside another ide docker image which you use
 to run tests in (e.g. chefide). That could be troublesome because ide changes fast.
 Here you test the end user usage of your ide docker image, with end user
  entrypoint and volumes. Implement them as: **RSpec tests which run ide
  commands and use Idefiles**.
2. In `.kitchen.image.yml` do set **entrypoint which is not the ide entrypoint**!
 When Test-Kitchen cannot start a container, it says only:
 `Error response from daemon: Container <id> is not running`, it does not say why.
 And sometimes you want to allow `entrypoint.sh` to fail (e.g. in the above point,
 when nothing is installed and thus some daemons will not start).
  *(It would be nice if Test-Kitchen would then run `docker logs container_name`,
  I did it in http://gitlab.ai-traders.com/lab/docker-rubyide/blob/master/cookbook-ai_ruby_docker/ChefRakefile.rb#L111
    and it was a very bad and ugly idea but crucial back then, to realize what
  was the error. Maybe I could implement it in https://github.com/marcy-terui/kitchen-docker_cli/blob/master/lib/kitchen/driver/docker_cli.rb#L61*).
  You can set entrypoint in KitchenDockerfile:

  ```ruby
  FROM <%= config[:image] %>

  ENTRYPOINT ["/bin/bash"]
  ```
  Such an entrypoint demands updated docker run command in `.kitchen.yml` file,
  e.g.: `command: -c "/sbin/my_init"` or `-c 'while true; do sleep 1d; done;'`.
  If you don't set command, docker logs will
  show: `/bin/sh: /bin/sh: cannot execute binary file`, because the default
  command set by kitchen-docker_cli is: `sh -c 'while true; do sleep 1d; done;'`.
  Similar, if you set command to `/bin/bash`.
4. In any `.kitchen.yml` files when **mounting docker volumes, always ensure
 absolute path**, and watch out for the gocd issue which does not set PWD env
 variable. Working example is
 ```
  volume:
          - <%= File.dirname(__FILE__) %>/test/integration/dummy_work:/ide/work
          - <%= File.dirname(__FILE__) %>/test/integration/dummy_identity:/ide/identity
 ```
5. Whenever you use dummy identity (dummy configuration and secret files) for tests,
 ensure, that they have proper permissions, e.g. `~/.ssh/id_rsa` has permissions:
 `600`.
5. In Test-Kitchen tests keep 1 spec file named: `a_ide_scripts_spec.rb` so that
 it is run as the first one and it sets ide identity for the rest of the tests.
6. http://gitlab.ai-traders.com/lab/docs/blob/master/ReleaseCycle/DockerImage.md
 applies here.

See also:
* http://gitlab.ai-traders.com/lab/gem-dockerimagerake


## FAQ
> Why not mount `/home/user` as `/home/ide` but as `/ide/work`?

Because `/home/ide` has already some configuration provided by the docker
ide image and mounting it this way would shadow all the provisioned files.

## Development
There is a [Rakefile.rb](./Rakefile.rb) and rake tasks to be used:
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

Git branches apply as in AI-Traders cookbooks or gems: create your feature branch
 from master and if you are ready to have it ci tested, merge your feature branch
 onto ci branch. Then work on ci branch until all tests on ci are passed.

### TODOs
1. Support groups?
1. Apply https://github.com/progrium/bashstyle style guide.
1. Maybe do not use Rubyide to release IDE? This demands implementing OVersion
 in bash. And not using gitrake gem.
