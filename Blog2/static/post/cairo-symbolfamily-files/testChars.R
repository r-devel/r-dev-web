## TestChars() function (below) from
## https://stackoverflow.com/questions/60656445/how-to-fix-degree-symbol-not-showing-correctly-in-r-on-linux-fedora-31

TestChars <- function(...) {
    info = l10n_info()
    r <- c(32:126, 160:254)
    par(pty = "s")
    plot(c(-1,10), c(20,260),
         type = "n", xlab = "", ylab = "", xaxs = "i", yaxs = "i")
    grid(11, 24, lty = 1)
    mtext(paste("MBCS:", info$MBCS, "  UTF8:", info$`UTF-8`,
                "  Latin:", info$`Latin-1`))
    for (i in r)
        try(points(i%%10, 10*i%/%10, pch = i, font = 5,...))
}

