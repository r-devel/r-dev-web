\name{formulasFrame}
\alias{formulasFrame}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Model frames for multiple formulas}
\description{
  Constructs model frames for multiple formulas simultaneously, so that recycling, missing value removal, and subsetting are compatible across all 
formulas.  
}
\usage{
formulasFrame(formulas, data = parent.frame(), na.action = getOption("na.action"), subset = NULL, check.env = FALSE, one.frame = TRUE)
}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{formulas}{A list of formulas}
  \item{data}{A data frame to look up variables}
  \item{na.action}{Name of an \code{na.action} function}
  \item{subset}{Subset to use}
  \item{check.env}{If \code{TRUE}, warn when formulas don't have the same environment }
  \item{one.frame}{If \code{TRUE}, return a single data frame, otherwise return a list of data frames}
}

\value{
 A data frame or list of data frames
}
\note{
This function is designed to simplify the avoidance of scoping anomalies in modelling functions, by allowing all the variables that are looked up in a data argument to be specified as formulas}

\seealso{ \code{\link{model.frame}} }

\examples{
  data(trees)
  trees[3,3]<-NA
  formulasFrame(list(log(Volume)~log(Height)+log(Width),~Width), subset=1:10, data=trees)

  formulasFrame(list(log(Volume)~log(Height)+log(Width),~Width), data=trees,subset=1:10, one.frame=FALSE)

}
\keyword{utilities }% at least one, from doc/KEYWORDS
