# the original match matcher does not work, results in:
# /usr/local/bin/shpec: 1: eval: Syntax error: word unexpected (expecting ")")
do_match() {
  actual=$1
  expected=$2
  echo "aaaaaaaaa"
  echo $actual
  echo $expected
  # http://askubuntu.com/questions/299710/how-to-determine-if-a-string-is-a-substring-of-another-in-bash
  if case ${actual} in *"${expected}"*) true;; *) false;; esac; then
      iecho "$_shpec_green$_shpec_assertion$_shpec_norm"
  else
      : $((_shpec_failures += 1))
           iecho "$_shpec_red$_shpec_assertion"
           iecho "${actual}' does not contain '${expected}$_shpec_norm"
  fi
}
