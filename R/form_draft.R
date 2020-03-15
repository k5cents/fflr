#' Format a league draft
#'
#' Take a league's list of draft picks and use [purrr::map_df()] to apply
#' [draft_entry()] and return a single tibble per league.
#'
#' @param draft The `draftDetail` list returned by [draft_entry()].
#' @return A tibble with a row for every draft pick.
#' @examples
#' data <- fantasy_draft(lid = 252353)
#' form_draft(draft = data$draftDetail)
#' @importFrom purrr map_df
#' @importFrom dplyr arrange mutate
#' @importFrom rlang .data
#' @export
form_draft <- function(draft) {
  draft$picks %>%
    purrr::map_df(draft_entry) %>%
    dplyr::arrange(.data$overall)
}
