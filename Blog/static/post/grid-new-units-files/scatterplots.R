library(ggplot2)
library(grid)

testPlot <- function(f) {
    print(f())
}
graphicsPlot <- function() {
    plot(price ~ carat, diamonds, pch=16, col=rgb(0,0,0,.2))
}
ggPlot <- function() {
    ggplot(diamonds) +
        geom_point(aes(x=carat, y=price), alpha=.2)
}

png("grid-new-units-files/scatterplots.png", width=600, heigh=300)
par(fig=c(0, .5, 0, 1), mar=c(5, 4, 1, 1), mex=.7, cex.axis=.7)
graphicsPlot()
print(ggPlot(), vp=viewport(x=.5, width=.5, just="left"))
dev.off()

png(tempfile(fileext=".png"))
result <- bench::mark(graphics=testPlot(graphicsPlot), 
                      ggplot2=testPlot(ggPlot), 
                      iterations=10, check=FALSE)
dev.off()
png(paste0("grid-new-units-files/scatterplots-timing-", getRversion(), ".png"),
    width=600, height=300)
autoplot(result)
dev.off()
