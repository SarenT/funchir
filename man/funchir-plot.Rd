\name{funchir-plot}
\alias{tile.axes}
\alias{rel_coord}
\alias{xdev2in}
\alias{ydev2in}
\alias{xydev2in}
\title{ Convenience Functions for Plotting }
\description{
   \code{tile.axes} is used in for loops to generate axes in a multi-panel plot with shared x & y axes (within row and column).

   \code{xdev2in} is the inverse of \code{graphics::xinch}; namely, it converts from plotting device units into inches.
}
\usage{
   tile.axes(n, M, N, params = list(x = list(), y = list()),
             use.x = TRUE, use.y = TRUE)
   rel_coord(ax, lambda = 0)
   xdev2in(x = 1)
   ydev2in(y = 1)
   xydev2in(xy = 1)
}
\arguments{
  \item{n}{ Integer. Cell in \code{mfrow} to which to apply the axes; fills by \emph{row}, following base functionality.}
  \item{M}{ Integer. Number of rows specified in \code{mfrow}. }
  \item{N}{ Integer. Number of columns specified in \code{mfrow}. }
  \item{ax}{ Either \code{"x"} or \code{"y"}; axis for which we're specifying coordinates. }
  \item{lambda}{ Either a mixing weight, giving the percentage of the way between the lower and higher endpoint of the specified axis (0 : smaller endpoint, 1 : larger endpoint), or one of the following relative position characters: \code{c("top", "bottom", "left", "right")}. }
  \item{params}{ A length-2 \code{list}. \code{params$x} is a \code{list} of parameters to be passed to the x-axis. \code{params$y} is a \code{list} of parameters to be passed to the y-axis. }
  \item{use.x}{ \code{logical}. Should the x-axis be printed? }
  \item{use.y}{ \code{logical}. Should the y-axis be printed? }
  \item{x}{ \code{numeric} value to convert into inches (along the horizontal axis). }
  \item{y}{ \code{numeric} value to convert into inches (along the vertical axis). }
  \item{xy}{ \code{numeric} value to convert into inches (along both axes simultaneously). }
}
\details{
  \code{tile.axes} provides a simple way to incorporate the plotting of axes into a loop which creates the plots in a matrix of plots (e.g., by using \code{par(mfrow=c(2, 2))}) \emph{when the axes are shared by all plots}. x axes are only printed on the bottom row of plots, and y axes are only printed on the first column of plots--this saves potentially wasted / white space by eliminating redundant axes, yet can still be done in a loop.

  \code{rel_coord} gives a simple way to place text, labels, etc. in a plot by specifying only relative coordinates. The first form mimics the flexibility of \code{\link{legend}}, which accepts such relatively-defined positions as \code{"top"} and \code{"left"}. For example, specifying \code{lambda = "right"} will return an x coordinate close to the right endpoint of the currently defined axes. Alternatively, an exact proportion can be supplied -- if the desired coordinate is 75\% of the way to the right endpoint, for example, specify \code{rel_coord("x", .75)}.

  Some graphics functions specify some arguments with units in inches (namely, \code{graphics::arrows}' \code{length} argument). \code{graphics::xinch} provides the inverse functionality enabling conversion from inches into plotting units; up to numerical accuracy, then, \code{graphics::xinch(xdev2in(x)) == x}.
  }
\seealso{
  \code{\link{xinch}}
}
\examples{
  smpl <- rnorm(100)

  par(mfrow = c(2, 1), mar = c(0, 0, 0, 0), oma=c(5, 4, 4, 2) + .1)
  for (ii in 1:2){
    hist(smpl[sample(length(smpl), 100, rep = TRUE)], xaxt = "n", yaxt = "n")
    tile.axes(ii, 2, 1)
  }
}
