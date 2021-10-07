#' Combine league history with current season
#'
#' Runs a function `fun` twice, once with the `leagueHistory` set to `TRUE` and
#' once set to `FALSE`. Combined the output of both runs into a single data
#' frame.
#'
#' @param fun A function with the `leagueHistory` argument.
#' @param ... Additional arguments passed to the function used in `fun`.
#' @return A data frame of combined outputs.
#' @examples
#' combine_history(tidy_scores, leagueId = "252353")
#' @export
combine_history <- function(fun, ...) {
  stopifnot(is.function(fun))
  if (!("leagueHistory" %in% names(formals(fun)))) {
    stop("leagueHistory is not an argument of this function")
  }
  old <- fun(..., leagueHistory = TRUE)
  old <- bind_df(old, .id = NULL)
  new <- fun(..., leagueHistory = FALSE)
  bind_df(list(old, new))
}
