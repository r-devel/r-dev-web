library(grid)
library(pixmap)

# Method for converting "pixmapRGB" class to "raster" object
as.raster.pixmapRGB <- function(x) {
    nr <- nrow(x@red)
    r <- rgb((x@red), (x@green), (x@blue))
    dim(r) <- x@size
    r
}

logo <- read.pnm(system.file("pictures/logo.ppm", package="pixmap")[1])

png("Rlogo.png", height=240)
par(mfrow=c(1, 2), mar=rep(0, 4))
plot(logo)
mtext("pixmap::addlogo()", side=3, line=-1.5)
grid.clip()
grid.raster(logo, .75, .5, width=.5)
grid.text("grid.raster()", x=.75, y=unit(1, "npc") - unit(1, "lines"))
dev.off()
