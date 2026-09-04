Before <- function(d = 14) 
{
    b = Sys.Date() + d
    if(b >= as.Date("2026-09-21") && b < as.Date("2026-09-27"))
        b = as.Date("2026-09-27")
#    if(b < as.Date("2026-08-21")) b = as.Date("2026-08-21")
    b
}
