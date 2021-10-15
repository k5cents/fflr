#' Call the ESPN Fantasy API
#'
#' Use [httr::GET()] to make a request to the ESPN API and return the parsed
#' list from the JSON data. The function uses [httr::RETRY()], so the call will
#' repeat up to three times if there is a failure.
#'
#' @inheritParams ffl_id
#' @param view Character vector of specific API "views" which describe the data
#'   returned (e.g., "mRoster", "mSettings").
#' @param leagueHistory logical; Should the `leagueHistory` version of the API
#'   be called? If `TRUE`, a list of results is returned, with one element for
#'   each historical year of the league.
#' @param seasonId Integer year of NFL season. By default, the season is
#'   currently set to 2021. Use a recent year or set `leagueHistory` to `TRUE`
#'   to obtain all past data.
#' @param scoringPeriodId Integer week of NFL season. By default, `NULL` will
#'   use the current week (see [ffl_week()]). Scoring periods are always one
#'   week in length, whereas matchups might be longer.
#' @param ... Additional queries passed to [httr::GET()]. Arguments are
#'   converted to a named list and passed to `query` alongside `view`.
#' @examples
#' \dontrun{
#' ffl_api()
#' }
#' @return A single JSON string.
#' @importFrom httr RETRY accept_json add_headers user_agent http_type content
#'   http_error status_code
#' @importFrom jsonlite fromJSON
#' @keywords internal
#' @export
ffl_api <- function(leagueId = ffl_id(), view = NULL, leagueHistory = FALSE,
                    seasonId = 2021, scoringPeriodId = NULL, ...) {
  dots <- list(..., scoringPeriodId = scoringPeriodId)
  age_path <- ifelse(
    test = isTRUE(leagueHistory),
    yes = "leagueHistory",
    no = sprintf("seasons/%i/segments/0/leagues", seasonId)
  )
  view <- as.list(view)
  names(view) <- rep("view", length(view))
  if (!is.null(names(dots))) {
    view <- c(view, dots)
  }
  try_json(
    url = "https://fantasy.espn.com",
    path = paste("apis/v3/games/ffl", age_path, leagueId, sep = "/"),
    query = view,
    leagueHistory = leagueHistory
  )
}

try_json <- function(url, path = "", query = NULL, leagueHistory = NULL) {
  resp <- httr::RETRY(
    verb = "GET",
    url = ifelse(
      test = is.null(path) | !nzchar(path),
      yes = url,
      paste(url, paste(path, collapse = "/"), sep = "/")
    ),
    query = query,
    httr::accept_json(),
    httr::user_agent("https://github.com/kiernann/fflr/"),
    terminate_on = c(400:417)
  )
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return JSON", call. = FALSE)
  }
  raw <- httr::content(resp, as = "text", encoding = "UTF-8")
  parsed <- jsonlite::fromJSON(raw)
  if (httr::http_error(resp) && any(grepl("message", names(parsed)))) {
    if (!is.null(leagueHistory) && isTRUE(leagueHistory)) {
      parsed$message <- paste(parsed$message, "(No League History?)")
    }
    stop(
      sprintf(
        "ESPN Fantasy API request failed [%s]\n%s",
        httr::status_code(resp), parsed$message
      ),
      call. = FALSE
    )
  } else {
    return(parsed)
  }
}
