#' Extended qualitative color palettes
#'
#' This color palette combined the `Dark2` and `Set1` paletts from the Brewer
#' color system. Each of these palettes has 8 distinct qualitative colors. This
#' function combines the two palettes to provide enough distinct fill colors to
#' identify the 16 weeks of the NFL regular reason.
#'
#' @return A `ggplot2` object to define the fill of a plot.
#' @importFrom ggplot2 scale_fill_manual
#' @importFrom RColorBrewer brewer.pal
#' @export
scale_fill_fantasy <- function(variables) {
  pal <- c(
    RColorBrewer::brewer.pal(n = 8, name = "Dark2"),
    RColorBrewer::brewer.pal(n = 8, name = "Set1")
  )
  ggplot2::scale_fill_manual(values = pal)
}
