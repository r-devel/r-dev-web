source("d:/Rcompile/CRANpkg/make/check_diffs.R")

save_results("3.1")
save_results("3.2")
save_results("3.3")

try(check_results_diffs("3.1", flavor = "oldrel"))
try(check_results_diffs("3.2", flavor = "release")) 
try(check_results_diffs("3.3", flavor = "devel", 
Sys.Date(), date.old = Sys.Date()-1)) # devel oder prerel

send_checks("3.1", Sys.Date(), Sys.Date()-1, send_external = FALSE)
send_checks("3.2", Sys.Date(), Sys.Date()-1, send_external = FALSE)
send_checks("3.3", Sys.Date(), Sys.Date()-1, send_external = Sys.getenv("Kurt") == "Kurt")


#check_results_diffs("3.0", date.new = Sys.Date(), date.old = Sys.Date()-2, windir = "D:\\Rcompile\\CRANpkg\\win", flavor = "release")
#send_checks("3.0", Sys.Date(), Sys.Date()-2, send_external = FALSE)
