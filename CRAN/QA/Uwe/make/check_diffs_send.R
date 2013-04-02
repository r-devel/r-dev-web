source("d:/Rcompile/CRANpkg/make/check_diffs.R")

save_results("2.15")
save_results("3.0")

try(check_results_diffs("2.15"))
try(check_results_diffs("3.0"))

send_checks("2.15", Sys.Date(), Sys.Date()-1, send_external = FALSE)
send_checks("3.0", Sys.Date(), Sys.Date()-1, send_external = Sys.getenv("Kurt") == "Kurt")
