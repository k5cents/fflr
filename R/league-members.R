#' Fantasy league members
#'
#' Return the ESPN user names, unique owner IDs, and their manager status.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of league members.
#' @examples
#' league_members(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
league_members <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, ...)
  member_cols <- c("user", "owners", "lm")
  if (old) {
    for (i in seq_along(data$members)) {
      data$members[[i]] <- tibble::as_tibble(data$members[[i]])
      names(data$members[[i]]) <- member_cols
      data$members[[i]]$year <- data$seasonId[i]
    }
  } else {
    data$members <- tibble::as_tibble(data$members)
    names(data$members) <- member_cols
    data$members$year <- data$seasonId
  }
  return(data$members)
}
