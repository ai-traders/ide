### TODO
1. Replace Test-Kitchen with some tool that does not need ruby
2. Do not use Chefide for tests, but an ide docker image with (ruby)+docker,
 ideide?
3. Add a file that will store variables like `ide_username="ide"` or
 `ide_home="/home/ide"`. They could be then sourced by each /etc/ide.d script.
 Perhaps they could be also settable.
