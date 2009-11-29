library(grid)
x11(width=4, height=1)
grid.text("Shaded", gp=gpar(cex=5, fontface="italic", fontfamily="serif"))
cap <- grid.cap()
# Generate a gradient
gradient <- matrix(hcl(240, 60, seq(0, 100, length=nrow(cap))),
                   ncol=ncol(cap), nrow=nrow(cap))
# Clip the gradient using the text!
gradient[cap == "white"] <- "white"
grid.newpage()

png("textGradient.png", width=dim(gradient)[2], height=dim(gradient)[1])
grid.raster(gradient, width=1)
dev.off()
