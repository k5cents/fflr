#' Fantasy league members
#'
#' The ESPN team owner users belonging to a fantasy football league.
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
      data$members[[i]] <- data$members[[i]][, c(4, 1:3)]
    }
  } else {
    data$members <- tibble::as_tibble(data$members)
    names(data$members) <- member_cols
    data$members$year <- data$seasonId
    data$members <- data$members[, c(4, 1:3)]
  }
  return(data$members)
}
