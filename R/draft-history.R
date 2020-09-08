#' Fantasy draft history
#'
#' Return a table of draft picks by season. For snake drafts, display the round
#' and pick of each player; for auctions (salary cap), the nominating team and
#' winning bid.
#'
#' @param lid ESPN League ID.
#' @param old If `FALSE` (default), return only the current season's draft
#'   history. If `TRUE`, return a list with all prior drafts.
#' @param ... Additional API query arguments passed to [httr::GET()].
#' @return A tibble (or list) of draft picks.
#' @examples
#' draft_history(lid = 252353)
#' @importFrom httr GET content
#' @importFrom tibble as_tibble
#' @importFrom dplyr bind_rows
#' @export
draft_history <- function(lid, old = FALSE, ...) {
  b <- if (old) {
    "leagueHistory/"
  } else {
    sprintf("seasons/%s/segments/0/leagues/", format(Sys.Date(), "%Y"))
  }
  a <- paste0("https://fantasy.espn.com/apis/v3/games/ffl/", b, lid)
  data <- httr::content(httr::GET(a, query = list(view = "mDraftDetail", ...)))
  if (old) {
    out <- rep(list(NA), length(data))
    for (i in seq_along(data)) {
      out[[i]] <- parse_draft(data[[i]])
    }
  } else {
    out <- parse_draft(data)
  }
  return(out)
}

parse_draft <- function(data) {
  snake_names <- c("pick", "round", "snake", "team", "player")
  bid_names <- c("pick", "nominator", "team", "bid", "player")
  x <- dplyr::bind_rows(lapply(data$draftDetail$picks, tibble::as_tibble))
  x$type <- type <- data$settings$draftSettings$type
  x$year <- year <- data$seasonId
  n <- length(x)
  if (year < 2019 & type == "SNAKE") {
    x <- x[, c(n, n - 1, 8, 12, 13, 14, 10)]
    names(x)[3:7] <- snake_names
  } else if (year < 2019 & type == "AUCTION") {
    x <- x[, c(n, n - 1, 8, 7, 14, 2, 10)]
    names(x)[3:7] <- bid_names
  } else if (year >= 2019 & type == "SNAKE") {
    stop("Need to test this year & type combo")
  } else if (year >= 2019 & type == "AUCTION") {
    x <- x[, c(n, n - 1, 8, 7, 13, 2, 9)]
    names(x)[3:7] <- bid_names
  }
  return(x)
}

