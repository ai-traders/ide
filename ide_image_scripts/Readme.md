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
If you want to install from a specified tag, e.g. `0.8.0`, add: `-b 0.8.0` option
 to `git clone` command.

On Alpine Linux ignore the: `Creating mailbox file: No such file or directory`
 message.

## Development
Build and test ide docker images:
```
$ ide
cd ide_image_scripts
./tasks itest_build_images
./tasks itest
```

There are integration tests, which test the end user use cases. They test that
 `ide <some-command>` is invocable and return valid exit status and correct
  output. We test here 2 images: Ubuntu and Alpine.
