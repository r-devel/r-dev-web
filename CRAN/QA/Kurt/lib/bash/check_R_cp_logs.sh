#! /bin/sh

check_dir="${HOME}/tmp/R.check"
target_dir="/srv/www/nosvn/R.check"
target_url="https://www.r-project.org/nosvn/R.check"
R_scripts_dir="${HOME}/lib/R/Scripts"

R_flavors=" \
  r-devel-linux-x86_64-debian-clang
  r-devel-linux-x86_64-debian-gcc
  r-devel-linux-x86_64-fedora-clang
  r-devel-linux-x86_64-fedora-gcc
  r-devel-windows-x86_64
  r-patched-linux-x86_64
  r-release-linux-x86_64
  r-release-macos-arm64
  r-release-macos-x86_64
  r-release-windows-x86_64
  r-oldrel-macos-arm64
  r-oldrel-macos-x86_64
  r-oldrel-windows-x86_64
"

test -w ${target_dir} || exit 1

for flavor in ${R_flavors}; do
  timestamp="${check_dir}/.cache/${flavor}/t_max.rds"
  test -d "${target_dir}/${flavor}" && test -f "${timestamp}" && \
    test "${target_dir}/${flavor}" -nt "${timestamp}" && continue
  case "${flavor}" in
      *windows*)
	  mycat=iconv_from_latin1_to_utf8 ;;
      *)
	  mycat=cat ;;
  esac      
  mkdir -p ${target_dir}/${flavor}
  ## Use for loops to avoid '/bin/rm: Argument list too long' ...
  for f in ${target_dir}/${flavor}/*-00check.txt; do rm -f ${f}; done
  for f in ${target_dir}/${flavor}/*-00install.txt; do rm -f ${f}; done
  for f in ${target_dir}/${flavor}/*-00check.html; do rm -f ${f}; done
  for f in ${target_dir}/${flavor}/*-00install.html; do rm -f ${f}; done
  test -d ${check_dir}/${flavor}/PKGS || continue
  check_dirs=`ls -d ${check_dir}/${flavor}/PKGS/*.Rcheck 2>/dev/null`
  for d in ${check_dirs}; do
    test -r ${d}/00check.log || continue
    ## A real check log should start with '* using log directory': skip
    ## everything else.
    (head -1 ${d}/00check.log | grep -q '^\* using log directory') || continue
    package=`basename ${d} .Rcheck`
    if test -f ${d}/00install.out; then
      cp ${d}/00install.out \
         ${target_dir}/${flavor}/${package}-00install.txt
      ## We used to grep -E for
      ##   '^\*+ checking whether.*can be installed \.\.\. ERROR$'
      ##   '^\*+ checking whether.*can be installed \.\.\. WARNING$'
      ## but that does not work for CRLF 00check.log files as produced by
      ## Windows.  We could preprocess using sed 's/\r//', but let's keep
      ## things simple and add possible space before the end-of-string.
      url="${target_url}/${flavor}/${package}-00install.html"
      msg="See '${url}' for details."
      if grep -E '^\*+ checking whether.*can be installed \.\.\. *(\[.*\])? *(ERROR|WARNING)[[:space:]]*$' \
	      ${d}/00check.log > /dev/null; then
	sed "s|^See ['‘].*Rcheck/00install.out['’] for details.|${msg}|" \
            ${d}/00check.log > \
            ${target_dir}/${flavor}/${package}-00check.txt
      else
	sed -E "s@(^\*+ checking whether.*can be installed \.\.\. *(\[.*\])? *OK[[:space:]]*$)@\1\n$msg@" \
            ${d}/00check.log > \
            ${target_dir}/${flavor}/${package}-00check.txt
      fi
    else
      cp ${d}/00check.log \
	 ${target_dir}/${flavor}/${package}-00check.txt
    fi
  done
  ## <FIXME>
  ## Should this unlink the .txt files after converting them to HTML?
  ## </FIXME>
  R --vanilla --slave <<-EOF
	source("${R_scripts_dir}/check.R")
	oldwin <- grepl("windows-ix86+x86_64", "${flavor}")
	encoding <- if(oldwin) "latin1" else "UTF-8"
	files <- list.files("${target_dir}/${flavor}",
	                    pattern = "-00install.txt\$", full.names = TRUE)
	for(f in files)
	    write_install_log_as_HTML(f, sub("txt\$", "html", f), encoding)
	files <- list.files("${target_dir}/${flavor}",
	                    pattern = "-00check.txt\$", full.names = TRUE)
	for(f in files)
	    write_check_log_as_HTML(f, sub("txt\$", "html", f), oldwin)
	EOF
done

### Local Variables: ***
### mode: sh ***
### sh-basic-offset: 2 ***
### End: ***
