### TODO
1. Replace Test-Kitchen with some tool that does not need ruby
2. Do not use Chefide for tests, but an ide docker image with (ruby)+docker,
 ideide?
3. Make it work on Alpine Linux (only 50-ide-fix-uid-gid.sh must be additionally ported).
4. If bats tests fail and assertion like this one is used:
```
[ "${lines[2]}" = "ide" ]
```
the actual output is not seen. Make it be seen.
