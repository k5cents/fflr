#' @title Turn Nested Lists to Tibble Rows
#' @description Call [purrr::map_df()] and [tibble::as_tibble()] on a nested
#'   list.
#' @param l A list object whose sub-elements should be converted to rows and
#'   bound into a single tibble.
#' @return A nested list of API results.
#' @examples
#' m <- ffl_get(lid = 252353)
#' map_tbl(l = m$members)
#' @importFrom tibble as_tibble
#' @importFrom purrr map_df
#' @export
map_tbl <- function(l) {
  purrr::map_df(.x = l, .f = tibble::as_tibble)
}
