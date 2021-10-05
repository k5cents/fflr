#' Get ESPN fantasy league ID
#'
#' Retrieve league ID from global options, as an input, or from a URL.
#'
#' Since many users request data from the same ESPN league when using this
#' package, you can use this function to set, call, or extract the unique
#' ESPN league ID. By default, this function uses `getOption("fflr.leagueId")`
#' to look for a default league ID defined in your `options()`. If no such
#' option exists, and one is provided to the `leagueId` argument, the option
#' will be temporarily defined for your current session. If a URL starting with
#' `http` is provided, the numeric league ID will be extracted, defined as the
#' temporary option, and returned as a character string.
#'
#' @param leagueId Numeric league ID or ESPN fantasy page URL. Defaults to
#'   `getOption("fflr.leagueId")`. Function fails if no ID is found.
#' @param overwrite logical; If an `fflr.leagueId` option exists, should it be
#'   temporarily changed for your current session.
#' @examples
#' options(fflr.leagueId = "42654852")
#' ffl_id()
#' ffl_id(
#'   leagueId = "https://fantasy.espn.com/football/team?leagueId=252353",
#'   overwrite = TRUE
#' )
#' @return A numeric `leagueId` as a character vector with length one.
#' @export
ffl_id <- function(leagueId = getOption("fflr.leagueId"), overwrite = FALSE) {
  if (is.null(leagueId)) {
    stop("No `fflr.leagueId` option found, set with `options()` or `ffl_id()`")
  } else if (grepl("^http", leagueId)) {
    pattern <- regexpr(pattern = "leagueId\\=\\d{2,}", text = leagueId)
    leagueId <- gsub("\\D", "", regmatches(leagueId, m = pattern))
  }
  if (overwrite || is.null(getOption("fflr.leagueId"))) {
    message(sprintf("Temporarily set `fflr.leagueId` option to %s", leagueId))
    options(fflr.leagueId = leagueId)
  }
  return(as.character(leagueId))
}
