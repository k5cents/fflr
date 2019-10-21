#' @title Turn Nested Lists to Tibble Rows
#' @description Call [purrr::map_df()] and [tibble::as_tibble()] on a nested
#'   list.
#' @param l A list object whose sub-elements should be converted to rows and
#'   bound into a single tibble.
#' @return A nested list of API results.
#' @examples
#' m <- fantasy_data(lid = 252353)
#' form_tibble(l = m$members)
#' @importFrom tibble as_tibble
#' @importFrom purrr map_df
#' @export
form_tibble <- function(l) {
  purrr::map_df(.x = l, .f = tibble::as_tibble)
}
