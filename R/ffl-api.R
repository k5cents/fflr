#' Return list data from API JSON
#'
#' A generic call to the API using [jsonlite::fromJSON()] with nested data
#' set to simplify. Use "week" and "year" as shortcuts for "scoringPeriodId"
#' and "seasonId" respectively. Setting `old` equal to `TRUE` uses the
#' "leagueHistory" API instead of accessing 2020 season data.
#'
#' @inheritParams draft_picks
#' @param view The API "view" for data to be returned.
#' @importFrom jsonlite fromJSON
#' @export
ffl_api <- function(lid = getOption("lid"), old = FALSE, view = NULL, ...) {
  if (is.null(lid)) {
    stop("no league ID found, define argument or use options()")
  }
  a <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  b <- if (old) {
    "leagueHistory/"
  } else {
    "seasons/2020/segments/0/leagues/"
  }
  if (is.null(view)) {
    x <- list(...)
  } else {
    x <- list(view = view, ...)
  }
  names(x)[names(x) == "week"] <- "scoringPeriodId"
  names(x)[names(x) == "year"] <- "seasonId"
  y <- unlist(x)
  if (is.null(y)) {
    y <- list()
  } else {
    names(y) <- gsub("\\d", "", names(y))
  }
  c <- paste(paste(names(y), y, sep = "="), collapse = "&")
  data <- jsonlite::fromJSON(paste0(a, b, lid, "?", c))
  return(data)
}
