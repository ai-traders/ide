* add more logging in entrypoint in IDE docker images #16815

### 0.10.3 (2018-Jun-09)

* set default for ide_work variable used inside ide docker image #12045

### 0.10.2 (2017-Dec-26)

* reuse clean_func function

### 0.10.1 (2017-Dec-24)

* do not create the directory `/tmp/ide` for saving environment variables.
 Instead: use files starting with: `/tmp/ide-environment-...`, because there may
 be 2 users sharing /tmp directory and we could not set proper permissions of
 /tmp/ide without sudo (same permissions as /tmp directory has) #12181.
* add `LC*` to IDE_VARS_BLACKLIST #11705

### 0.10.0 (2017-Dec-24)

* stop requiring Idefile #9919 (but some variables must be set,
   e.g. IDE_DOCKER_IMAGE)

### 0.9.0 (2017-Jul-17)

* add option IDE_WORK_INNER, which defaults to `/ide/work`
* export IDE_WORK_INNER, so that it is preserved into a docker container created
 by IDE and we can set ide_work="${IDE_WORK_INNER}" (backwards compatibility for
 ide_image_scripts)

### 0.8.3 (2017-Jun-06)

* \#11167 set 777 permissions on directory: /tmp/ide, so that many users of one OS can
 use ide

### 0.8.2 (2017-Apr-16)

* readme reordered, almost 100 lines less
* use shellcheck 0.4.6 and fix style issues
* test on Ubuntu and Alpine, in 2 docker images: ideide and ideide-alpine
* test on docker 1.12.6 and docker-compose 1.12.0

### 0.8.1 (2017-Apr-16)

* development:
  * do not use ruby for development
  * GoCD pipeline in yaml (was in json)
  * rename dummyide used in tests to example-ide

### 0.8.0 (13 Apr 2017)

* \#10871 implemented option: "--quiet", so that we can save a command output into
 a bash variable, like: `version=$(ide some-command-to-get-version)`. Any log
 messages of level info in ide docker image `entrypoint.sh` should then go to stderr.

 In the future we could redirect all the log messages to stderr and switch test framework
 from: shpec to: bats, because in shpec we have to do `message=$(my-command)`
 and this will not catch stderr, while: `run` from bats catches the stdout and stderr.
 Or should we not? Shpec is more explicit, I'll have to add `2>&1` to get the same
 effect.
* log_error shows line numbers
* remove environment file even if --dryrun set (because it was created
  even if --dryrun set)

### 0.7.3 (8 Apr 2017)

* \#10066 warn if:
  * running as root
  * IDE_WORK directory is owned by root
* \#10188 Fix bug: Ide is leaving garbage networks. In practice it concerns
 only docker-compose driver and only if using docker-compose file v2.
* Remove docker networks created in the past by ide if no container uses them
* Use alpine:3.5 instead of alpine:3.4

### 0.7.2 (2 Apr 2017)

* Quote docker run command arguments if they contain white spaces. This is in
 order to allow more complicated docker run commands like:
 `ide --dryrun -- -c "echo aaa"`. Without this change `echo aaa` would not be
 quoted and the whole command would be invalid.

### 0.7.1 (31 Mar 2017)

* GH:\#1, TP:\#10811 support double dash (--) as end of options marker
* do not add double quotes if a docker container command already contains
 double quotes (that would make the command not valid)
* remove `source` added by mistake in 0.7.0 in ide_image_scripts entrypoint

### 0.7.0 (7 Mar 2017)

* \#10674 even if any file in /etc/ide.d/ directory was not executable,
 make it executable in entrypoint.sh. Because user may forget to make a script
 executable.
* \#10690 add nvidia-docker IDE driver.

### 0.6.2 (22 Nov 2016)

* \#10078 fix a bug when validating docker-compose v2 yaml file
* \#10078 fix a bug that resulted in error when running `ide -c pull`
 if using docker-compose v2 yaml file

### 0.6.1 (14 Oct 2016)

* \#9920 when --no_rm is set, generate iderc.txt with container name and
 iderc file with `IDE_RUN_ID=<container name>`
* keep `ide --version` option in order not to surprise end user

### 0.6.0 (13 Sep 2016)

* \#9865; #9707 ide pull command implemented
* better itests - replaced some rake tasks with shpec integration tests
* \#9865 added alias for --force_not_interactive option: --not_i
* \#9890 fixed bug: IDE adds space at the end of docker command
* added unit tests for running IDE with docker command:
 * without quotes vs with double quotes vs with single quotes
 * one-word vs multi-word
* \#9864 ide with configurable --no_rm for docker driver
* \#9888 fix shpec do_match and do_not_match matchers by adding --, so that
  grep string pattern is not misunderstood for grep options and remove
  workarounds (additional spaces in tests).
* \#9889 refactor IDE to differenciate commands and options
* \#9891 order unit and integration tests, put them into directories

### 0.5.0 (2 Sep 2016)

* \#9728 add scripts to help make IDE docker image
* use ideide:1.0.1 docker image to test IDE (instead of 3 different, 2 of them
  private docker images)
* replace 2 InnerRakefiles and Rakefile with 2 Rakefiles
* update gems dependencies
* \#9740 add local_install.sh
* \#9749 do not depend on external and private docker images: gitide, build dummyide
 instead, for testing purposes only

### 0.4.4 (11 Mar 2016)

* do not `git push` to ci branch when bumping version or else CI
 pipeline will run in a loop

### 0.4.3 (11 Mar 2016)

* fix failing tests, which were false positive on CI due to:
 \#8932 fix: ide does not preserve exit status when not-interactive

## 0.4.2 (11 Mar 2016)

* more readme on docker-compose driver
* development:
   * \#8933 use ideide 0.1.0 with docker-compose installed
   * \#8935 bump version file automatically

### 0.4.1 (11 Mar 2016)

* \#8932 fix: ide does not preserve exit status when not-interactive

### 0.4.0 (11 Mar 2016) (released by mistake as 0.3.1)

* \#8598 support docker-compose driver
* remove all groups logic (it was never fully implemented)

### 0.3.0 (8 Mar 2016)

* \#8744 stop docker container when running not-interactively and pressing ctrl+c.
 Due to this, IDE will use specified names for docker containers.
* add option `--force_not_interactive` so that if we run from terminal and our
 shell is interactive, we can still force ide to run docker container without
 `-ti` options. It is necessary for testing ide.
 The other way round, `--force_interactive`, would make no sense, because if your
 shell is already not-interactive, you cannot make it interactive.
* the environment file produced by ide has similar name to the docker container
* the environment file produced by ide is removed in the end

### 0.2.0 (7 Mar 2016)

* \#8494 support graphical mode

### 0.1.2 (7 Mar 2016)

\#8906 No changes in ide code, but:
* moved gitide into a separate git repository
* updated readme so that docs on how to create an ide docker image
 are all here

### 0.1.1 (17 Feb 2016)

* \#8783 save environment variables to a file containing random number

### 0.1.0 (09 February 2016)

* `IDE_HOME` replaced with `IDE_IDENTITY`
* implemented shpec matcher "do_match", because "match" has error
 (shpec files cannot be in test directory or else custom matcher won't be read)
* IDE_ENV_ settings are obsolete
* all variables will be preserved, but some are blacklisted. When a variable,
 e.g. ABC=123 is blacklisted, then it will be preserved as IDE_ABC=123.
* \#8707 split ide source code into 2 files: ide and ide_functions to make testing easier
* \#8208 Make docker run command visible not only in debug log
* \#8399 gitide should mount ~/.gitconfig
* \#8732 ide run interactively if current terminal is interactive
* \#8733 ide released by ci agent

### 0.0.3 (02 January 2016)

Allow to specify no command - use docker's default then.

### 0.0.2 (10 December 2015)

Quotes are not needed, you can run: `ide echo sth`

### 0.0.1 (10 December 2015)

Initial release
