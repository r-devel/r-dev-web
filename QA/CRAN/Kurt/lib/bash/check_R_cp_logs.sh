#! /bin/sh

check_dir="${HOME}/tmp/R.check"
target_dir="/srv/www/r-project/nosvn/R.check"
target_url="http://www.r-project.org/nosvn/R.check"
R_scripts_dir="${HOME}/lib/R/Scripts"

R_flavors=" \
  r-devel-linux-ix86
  r-devel-linux-x86_64
  r-patched-linux-ix86
  r-patched-linux-x86_64
  r-release-linux-ix86
  r-release-macosx-ix86
  r-release-windows-x86_64"

htmlify () {
    cat <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<HTML>
<HEAD>
<TITLE></TITLE>
<META http-equiv="Content-Type" content="text/html; charset=utf-8">
</HEAD>
<BODY>
<PRE>
EOF
    cat ${1}
    cat <<EOF
</PRE>
</BODY>
</HTML>
EOF
}
  
test -w ${target_dir} || exit 1

for flavor in ${R_flavors}; do
  mkdir -p ${target_dir}/${flavor}
  ## Four steps to avoid '/bin/rm: Argument list too long' ...
  rm -f ${target_dir}/${flavor}/*-00check.txt
  rm -f ${target_dir}/${flavor}/*-00install.txt
  rm -f	${target_dir}/${flavor}/*-00check.html
  rm -f ${target_dir}/${flavor}/*-00install.html
  test -d ${check_dir}/${flavor}/PKGS || continue
  check_dirs=`ls -d ${check_dir}/${flavor}/PKGS/*.Rcheck 2>/dev/null`
  for d in ${check_dirs}; do
    test -r ${d}/00check.log || continue
    package=`basename ${d} .Rcheck`
    cp ${d}/00check.log ${target_dir}/${flavor}/${package}-00check.txt
    ## If installation failed, all the check log says is
    ##   Installation failed.
    ##   See '/var/mnt/.....' for details.
    ## which is not too helpful.  Provide the install log as well in
    ## such a case, and massage the check log accordingly.
    ## <NOTE>
    ## We used to grep -E for
    ##   '^\*+ checking whether.*can be installed \.\.\. ERROR$'
    ##   '^\*+ checking whether.*can be installed \.\.\. WARNING$'
    ## but that does not work for CRLF 00check.log files as produced by
    ## Windows.  We could preprocess using sed 's/\r//', but let's keep
    ## things simple and add possible space before the end-of-string.
    ## </NOTE>
    url="${target_url}/${flavor}/${package}-00install.html"
    msg="See '${url}' for details."
    if grep -E \
        '^\*+ checking whether.*can be installed \.\.\. ERROR[[:space:]]*$' \
        ${d}/00check.log > /dev/null; then
      (head -n -1 ${d}/00check.log; echo "${msg}") \
	> ${target_dir}/${flavor}/${package}-00check.txt
      htmlify ${d}/00install.out > \
        ${target_dir}/${flavor}/${package}-00install.html
    ## Also provide the install log and try pointing to it in case there
    ## were installation warnings (only works for R 2.5.0 or better).
    elif grep -E \
        '^\*+ checking whether.*can be installed \.\.\. WARNING[[:space:]]*' \
        ${d}/00check.log > /dev/null; then
      sed "s|^See '.*Rcheck/00install.out' for details.|${msg}|" \
        ${d}/00check.log > \
        ${target_dir}/${flavor}/${package}-00check.txt
      htmlify ${d}/00install.out > \
        ${target_dir}/${flavor}/${package}-00install.html
    ## If running the tests failed, provide the last 13 lines of the
    ## offending test out file.  Only works for 1.8 or better, as this
    ## moves .Rout to .Rout.fail on error, and provided that the tests
    ## results are available, which currently is no longer true when
    ## collecting the results for different flavors on the cran server.
    ## But from 2.4.0, this is also no longer necessary, as R CMD check
    ## now record the same information in the check log.
    elif grep -E '^\*+ checking tests \.\.\. ERROR[[:space:]]*$' \
        ${d}/00check.log > /dev/null; then
      bad_test_out=`ls ${d}/tests/*.fail 2>/dev/null | head -1`
      if test -n "${bad_test_out}"; then
        bad_test_src=`basename ${bad_test_out} out.fail`
        (echo "Running tests/${bad_test_src} failed.";
	  echo "Last 13 lines of output:"; echo;
	  tail -13 ${bad_test_out}) >> \
	  ${target_dir}/${flavor}/${package}-00check.txt
      fi
    fi
  done
  R --vanilla --slave <<-EOF
	source("${R_scripts_dir}/check.R")
	files <- list.files("${target_dir}/${flavor}",
	                    pattern = "-00check.txt\$", full = TRUE)
	for(f in files)
	    write_check_log_as_HTML(f, sub("txt\$", "html", f))
	EOF
done

