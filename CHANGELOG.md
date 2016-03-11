# 0.4.2 (11 Mar 2016)

* more readme on docker-compose driver
* development:
   * #8933 use ideide 0.1.0 with docker-compose installed
   * #8935 bump version file automatically

# 0.4.1 (11 Mar 2016)

* #8932 fix: ide does not preserve exit status when not-interactive

# 0.4.0 (11 Mar 2016) (released by mistake as 0.3.1)

* #8598 support docker-compose driver
* remove all groups logic (it was never fully implemented)

# 0.3.0 (8 Mar 2016)

* #8744 stop docker container when running not-interactively and pressing ctrl+c.
 Due to this, IDE will use specified names for docker containers.
* add option `--force_not_interactive` so that if we run from terminal and our
 shell is interactive, we can still force ide to run docker container without
 `-ti` options. It is necessary for testing ide.
 The other way round, `--force_interactive`, would make no sense, because if your
 shell is already not-interactive, you cannot make it interactive.
* the environment file produced by ide has similar name to the docker container
* the environment file produced by ide is removed in the end

# 0.2.0 (7 Mar 2016)

* #8494 support graphical mode

# 0.1.2 (7 Mar 2016)

#8906 No changes in ide code, but:
* moved gitide into a separate git repository
* updated readme so that docs on how to create an ide docker image
 are all here

# 0.1.1 (17 Feb 2016)

* #8783 save environment variables to a file containing random number

# 0.1.0 (09 February 2016)

* `IDE_HOME` replaced with `IDE_IDENTITY`
* implemented shpec matcher "do_match", because "match" has error
 (shpec files cannot be in test directory or else custom matcher won't be read)
* IDE_ENV_ settings are obsolete
* all variables will be preserved, but some are blacklisted. When a variable,
 e.g. ABC=123 is blacklisted, then it will be preserved as IDE_ABC=123.
* #8707 split ide source code into 2 files: ide and ide_functions to make testing easier
* #8208 Make docker run command visible not only in debug log
* #8399 gitide should mount ~/.gitconfig
* #8732 ide run interactively if current terminal is interactive
* #8733 ide released by ci agent

# 0.0.3 (02 January 2016)

Allow to specify no command - use docker's default then.

# 0.0.2 (10 December 2015)

Quotes are not needed, you can run: `ide echo sth`

# 0.0.1 (10 December 2015)

Initial release
