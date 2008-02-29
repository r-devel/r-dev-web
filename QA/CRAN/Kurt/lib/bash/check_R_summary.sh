#! /bin/sh

check_dir="${HOME}/tmp/R.check"
write_dir="${check_dir}/web"
target_dir="/srv/ftp/pub/R/web/checks"
R_scripts_dir="${HOME}/lib/R/Scripts"

rm -rf "${write_dir}" && mkdir "${write_dir}"

R --slave --no-save <<EOF
  source("${R_scripts_dir}/check.R")
  .saveRDS(check_flavors_db, file = "${write_dir}/check_flavors.rds")
  write_check_flavors_db_as_HTML(out = "${write_dir}/check_flavors.html")
  results <- check_results_db("${check_dir}")
  .saveRDS(results, file = "${write_dir}/check_results.rds")
  write_check_results_db_as_HTML(results, "${write_dir}")
EOF

## for f in \
##     check_results.rds check_results.html \
##     check_timings.rds check_timings.html check_timings_*.html ;
## do
##   if test -f "${check_dir}/${f}"; then
##     cp "${check_dir}/${f}" "${target_dir}"
##   fi
## done

rm -rf "${target_dir}" && mv "${write_dir}" "${target_dir}"
