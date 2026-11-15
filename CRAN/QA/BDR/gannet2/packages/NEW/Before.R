Before <- function(d = 14) 
{
    b = Sys.Date() + d
    if(b >= as.Date("2026-12-22") && b < as.Date("2027-01-11"))
        b = as.Date("2027-01-11")
#    if(b < as.Date("2026-08-21")) b = as.Date("2026-08-21")
    b
}
