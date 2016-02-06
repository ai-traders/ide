# the original match matcher does not work, results in:
# /usr/local/bin/shpec: 1: eval: Syntax error: word unexpected (expecting ")")
do_match() {
  actual=$1
  expected=$2
  if case ${actual} in *"${expected}"*) true;; *) false;; esac; then
      printf %s\\n "'${actual}' contains '${expected}'"
      iecho "$_shpec_green$_shpec_assertion$_shpec_norm"
  else
      printf %s\\n "'${actual}' does not contain '${expected}'"
      : $((_shpec_failures += 1))
           iecho "$_shpec_red$_shpec_assertion"
           iecho "${actual}' does not contain '${expected}$_shpec_norm"
  fi
}
