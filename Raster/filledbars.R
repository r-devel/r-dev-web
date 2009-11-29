library(grid)
png("filledBars.png", height=300)
red.gradient <- matrix(hcl(0, 80,
                           rev(c(rep(30, 5), rep(40, 5),
                                 rep(50, 5), rep(60, 5),
                                 rep(70, 5), rep(80, 5)))),
                       byrow=TRUE, ncol=5)

year <- c(1993, 1996, 1998, 2001)
minpop <- c(20, 50, 50, 115)
maxpop <- c(50, 240, 240, 150)

# grid.newpage()
pushViewport(plotViewport(),
             viewport(xscale=c(1991, 2003), yscale=c(0, 250)))
grid.xaxis(at=year)
grid.yaxis()
grid.rect()
# white bars
grid.rect(x=unit(year, "native"), y=0,
          width=unit(1, "native"), height=unit(maxpop, "native"),
          just="bottom", gp=gpar(fill="white"))
for (i in 1:length(year)) {
    grid.clip(x=unit(year[i], "native"), y=0,
              width=unit(1, "native"), height=unit(maxpop[i], "native"),
              just="bottom")
    # pattern fill
    grid.raster(red.gradient, width=1.5, height=1.5)
}
grid.clip()
# redo bar borders
grid.rect(x=unit(year, "native"), y=0,
          width=unit(1, "native"), height=unit(maxpop, "native"),
          just="bottom", gp=gpar(fill=NA))
popViewport(2)
grid.clip()
grid.text("Estimated Population (max.) of Bengal Tigers\n(in Bhutan)",
          y=unit(1, "npc") - unit(2, "lines"))
dev.off()
