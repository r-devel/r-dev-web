library(ggplot2)
library(grid)

simple_scatter <- function(vp=viewport()) {
    p <- ggplot(mpg) + 
        geom_point(aes(x = displ, y = hwy, colour = drv)) + 
        labs(
            title = "this is a simple scatterplot",
            subtitle = "one panel, few data"
        )
    print(p, vp=vp)
}
simple_box <- function(vp=viewport()) {
    p <- ggplot(mpg) + 
        geom_boxplot(aes(x = drv, y = hwy, fill = drv)) + 
        labs(
            title = "this is a simple boxplot",
            subtitle = "one panel, few data"
        )
    print(p, vp=vp)
}

complex_scatter <- function(vp=viewport()) {
    p <- ggplot(diamonds) + 
        geom_point(aes(x = carat, y = price, colour = cut)) + 
        facet_wrap(~cut) + 
        labs(
            title = "this is a complex scatterplot",
            subtitle = "many panels, large data"
        )
    print(p, vp=vp)
}
complex_box <- function(vp=viewport()) {
    p <- ggplot(diamonds) + 
        geom_boxplot(aes(x = color, y = price, fill = cut)) + 
        facet_wrap(~cut) + 
        labs(
            title = "this is a complex boxplot",
            subtitle = "many panels, large data"
        )
    print(p, vp=vp)
}

png("grid-new-units-files/ggplot2.png", width=800, height=800)
simple_scatter(viewport(x=0, y=.5, width=.5, height=.5,
                        just=c("left", "bottom")))
simple_box(viewport(x=.5, y=.5, width=.5, height=.5,
                    just=c("left", "bottom")))
complex_scatter(viewport(x=0, y=0, width=.5, height=.5,
                         just=c("left", "bottom")))
complex_box(viewport(x=.5, y=0, width=.5, height=.5,
                     just=c("left", "bottom")))
dev.off()


devoid::void_dev()
result <- bench::mark(simple_scatter(), simple_box(),
                      complex_scatter(), complex_box(), 
                      check = FALSE, iterations = 10)
dev.off()
result$version <- gsub(" .+", "", paste(getRversion(), result$expression))
saveRDS(result, paste0("grid-new-units-files/ggplot2-timing-", getRversion(), ".rds"))


