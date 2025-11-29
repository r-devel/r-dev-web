Before <- function(d = 14) 
{
    b = Sys.Date() + d
    if(b >= as.Date("2025-12-23") && b < as.Date("2026-01-15")) b = as.Date("2026-01-15")
    b
}
