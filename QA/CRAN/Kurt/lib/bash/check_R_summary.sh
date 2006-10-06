#! /bin/sh

check_dir="${HOME}/tmp/R.check"
target_dir="/home/ftp/pub/R/src/contrib/"
R_scripts_dir="${HOME}/lib/R/Scripts"

R --slave --no-save <<EOF
  source("${R_scripts_dir}/check.R")
  write_check_summary_as_HTML(check_summary("${check_dir}"),
                              "${check_dir}/checkSummary.html")
  write_check_timings_as_HTML(check_timings("${check_dir}"),
                              "${check_dir}/checkTimings.html")
EOF

for f in checkSummary.html checkTimings.html; do
  if test -f "${check_dir}/${f}"; then
    cp "${check_dir}/${f}" "${target_dir}"
  fi
done
