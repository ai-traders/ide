# the original match matcher does not work, results in:
# /usr/local/bin/shpec: 1: eval: Syntax error: word unexpected (expecting ")")
do_match() {
  actual=$1
  expected=$2

  # Really do quote $actual in order to preserve newlines.
  # Thanks to grep -E we can use extended regex.
  if  echo -e "$actual" | grep -Eo -- "$expected" >> /dev/null ;then
    iecho "$_shpec_green$_shpec_assertion$_shpec_norm"
  else
    : $((_shpec_failures += 1))
         iecho "$_shpec_red$_shpec_assertion"
         iecho "'${actual}' does not match '${expected}'$_shpec_norm"
  fi
}
