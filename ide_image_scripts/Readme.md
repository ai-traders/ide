# IDE image scripts

A set of helpful scripts to transform a docker image into an IDE docker image.

## Usage

### What does it do and why use it
The `src/install.sh` script is meant to be invoked inside a docker container
 which you want to transform into an IDE docker image. It will:
  1. install some scripts needed for docker entrypoint to work
  2. add ide linux user and group.

It works on Debian/Ubuntu/Alpine Linux.

Real example: https://github.com/ai-traders/docker-ideide

### Installation
```
git clone --depth 1 --single-branch  https://github.com/ai-traders/ide.git
./ide/ide_image_scripts/src/install.sh
rm -r ./ide
```
If you want to install from a specified tag, e.g. `0.7.0`, add: `-b 0.7.0` option
 to `git clone` command.

On Alpine Linux ignore the: `Creating mailbox file: No such file or directory`
 message.

## Development
### Tests

There are Test-Kitchen tests with 2 tests suites, which run on Ubuntu and Alpine Linux:
 * default -- installs only default ide configuration files
 * ssh -- installs default ide configuration files and ensures that `~/.ssh/id_rsa`
 file is copied into ide docker container

The tests framework is: BATS. To run 1 tests set:
```bash
ide # we need ruby + docker daemon
cd ide_image_scripts
bundle install
bundle exec kitchen converge default-alpine
bundle exec kitchen verify default-alpine
bundle exec kitchen destroy default-alpine
exit
```
To run all the tests suites:
```
ide "cd ide_image_scripts && bundle install && bundle exec rake kitchen:all"
```

### TODO
1. Replace Test-Kitchen with some tool that does not need ruby.
