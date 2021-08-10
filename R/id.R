#' Find your default ESPN fantasy league ID
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
#' @examples
#' ffl_id(leagueId = "252353")
#' ffl_id(leagueId = getOption("fflr.leagueId"))
#' ffl_id("https://fantasy.espn.com/football/team?leagueId=252353&teamId=6")
#' @export
ffl_id <- function(leagueId = getOption("fflr.leagueId")) {
  if (is.null(leagueId)) {
    stop("No `fflr.leagueId` option found, set with `options()` or `ffl_id()`")
  } else if (grepl("^http", leagueId)) {
    pattern <- regexpr(pattern = "leagueId\\=\\d{2,}", text = leagueId)
    leagueId <- gsub("\\D", "", regmatches(leagueId, m = pattern))
  } else if (!grepl("\\D", leagueId) & is.null(getOption("fflr.leagueId"))) {
    message(sprintf("Temporarily set `fflr.leagueId` option to %s", leagueId))
    options(fflr.leagueId = leagueId)
  }
  return(as.character(leagueId))
}
