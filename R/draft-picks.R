#' Fantasy draft history
#'
#' Return a table of draft picks by season. For snake drafts, display the round
#' and pick of each player; for auctions (salary cap), the nominating team and
#' winning bid.
#'
#' @param lid ESPN League ID, defaults to `getOption("lid")`. Use
#'   `options(lid = <League ID>)` to set your league ID; put that line in your
#'   `.Rprofile` file to set the option at start up.
#' @param old If `FALSE` (default), return only the current season's data. If
#'   `TRUE`, return a list with all prior seasons.
#' @param ... Additional API query arguments. Use "week" and "year" as a
#'   shorthand for "ScoringPeriodId" and "seasonId" respectively.
#' @return A tibble (or list) of draft picks.
#' @examples
#' draft_picks(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
draft_picks <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = "mDraftDetail", ...)
  if (old) {
    out <- rep(list(NA), length(data$seasonId))
    for (i in seq_along(out)) {
      x <- tibble::as_tibble(data$draftDetail$picks[[i]])
      x$type <- t <- data$settings$draftSettings$type[[i]]
      x$year <- y <- data$seasonId[[i]]
      out[[i]] <- parse_draft(x, year = y, type = t)
    }
  } else {
    x <- tibble::as_tibble(data$draftDetail$picks)
    x$type <- t <- data$settings$draftSettings$type
    x$year <- y <- data$seasonId
    out <- parse_draft(x, year = y, type = t)
  }
  return(out)
}

parse_draft <- function(x, year = NULL, type = NULL, nm = NULL) {
  n <- length(x)
  if (year < 2019 & type == "SNAKE") {
    x <- x[, c(n, n - 1, 8, 12, 13, 14, 10)]
    names(x)[3:7] <- c("pick", "round", "snake", "team", "id")
  } else if (year < 2019 & type == "AUCTION") {
    x <- x[, c(n, n - 1, 8, 7, 14, 2, 10)]
    names(x)[3:7] <- c("pick", "nominator", "team", "bid", "id")
  } else if (year >= 2019 & type == "SNAKE") {
    x <- x[, c(n, n - 1, 8, 11:13, 9)]
    names(x)[3:7] <- c("pick", "round", "snake", "team", "id")
  } else if (year >= 2019 & type == "AUCTION") {
    x <- x[, c(n, n - 1, 8, 7, 13, 2, 9)]
    names(x)[3:7] <- c("pick", "nominator", "team", "bid", "id")
  }
  return(x)
}

