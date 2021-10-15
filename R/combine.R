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
  old <- bind_df(fun(..., leagueHistory = TRUE), .id = NULL)
  new <- fun(..., leagueHistory = FALSE)
  n_old <- ncol(old)
  n_new <- ncol(new)
  if (n_new > n_old) {
    old <- balance_col(old, new)
  } else if (n_old > n_new) {
    new <- balance_col(new, old)
  }
  bind_df(list(old, new))
}

balance_col <- function(small, big) {
  n_small <- length(small)
  nm_diff <- setdiff(names(big), names(small))
  n_diff <- length(nm_diff)
  small <- cbind(small, matrix(ncol = n_diff))
  names(small)[seq(n_small + 1, ncol(small))] <- nm_diff
  return(small)
}
