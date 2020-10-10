#' Merge fantasy data
#'
#' This is a shortcut for the base [merge()] method that does not reorder
#' columns or rows and returns the merged data as a tibble.
#'
#' @param x,y Fantasy data frames to be merged together.
#' @param ... Arguments passed to [merge()].
#' @return A merged tibble.
#' @examples
#' team_roster(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
ffl_merge <- function(x, y, ...) {
  out <- merge(x, y, sort = FALSE, ...)[, union(names(x), names(y))]
  tibble::as_tibble(out)
}
