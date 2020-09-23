#' Return list data from API JSON
#' @inheritParams draft_picks
#' @param view The API "view" for data to be returned.
#' @importFrom jsonlite fromJSON
ffl_api <- function(lid = NULL, old = FALSE, view = NULL, ...) {
  a <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  b <- if (old) {
    "leagueHistory/"
  } else {
    sprintf("seasons/%s/segments/0/leagues/", format(Sys.Date(), "%Y"))
  }
  x <- list(view = view, ...)
  names(x)[names(x) == "week"] <- "scoringPeriodId"
  c <- paste(paste(names(x), x, sep = "="), collapse = "&")
  data <- jsonlite::fromJSON(paste0(a, b, lid, "?", c))
  return(data)
}
