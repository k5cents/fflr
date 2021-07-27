#' Find your ESPN fantasy league ID
#' @param leagueId Numeric league ID. Defaults to `Sys.getenv("ESPN_LEAGUE_ID")`
#'   set with [Sys.setenv()] or from your `.Renviron` file. Alternatively, pass
#'   any URL from an ESPN fantasy website and automatically extract the ID.
#' @examples
#' fflr_id(leagueId = "252353")
#' fflr_id(leagueId = Sys.getenv("ESPN_LEAGUE_ID"))
#' fflr_id("https://fantasy.espn.com/football/team?leagueId=252353&teamId=6")
#' @export
fflr_id <- function(leagueId = Sys.getenv("ESPN_LEAGUE_ID")) {
  stopifnot(!grepl("\\D", leagueId) || grepl("^http", leagueId))
  if (identical(leagueId, "")) {
    warning("No league ID found, see help(fflr_id)", call. = FALSE)
  } else if (grepl("^http", leagueId)) {
    pattern <- regexpr(pattern = "leagueId\\=\\d{2,}", text = leagueId)
    leagueId <- gsub("\\D", "", regmatches(leagueId, m = pattern))
  }
  return(as.character(leagueId))
}
