#! /bin/sh

check_dir="${HOME}/tmp/R.check"
target_dir="/srv/ftp/pub/R/src/contrib/"
R_scripts_dir="${HOME}/lib/R/Scripts"

R --slave --no-save <<EOF
  source("${R_scripts_dir}/check.R")
  summary <- check_summary("${check_dir}")
  .saveRDS(summary, file = "${check_dir}/checkSummary.rds")
  write_check_summary_as_HTML(summary, "${check_dir}/checkSummary.html")
  timings <- check_timings("${check_dir}")
  .saveRDS(timings, file = "${check_dir}/checkTimings.rds")
  write_check_timings_as_HTML(timings, "${check_dir}/checkTimings.html")
EOF

for f in checkSummary.html checkTimings.html; do
  if test -f "${check_dir}/${f}"; then
    cp "${check_dir}/${f}" "${target_dir}"
  fi
done
