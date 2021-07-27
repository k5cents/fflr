#' Call the ESPN Fantasy API
#'
#' Use [httr::GET()] to make a request to the ESPN API and return the parsed
#' list from the JSON data. The function uses [httr::RETRY()], so the call will
#' repeat up to three times if there is a failure.
#'
#' @param path Character vector of API path elements to append to
#'   `/apis/v3/games/ffl`.
#' @param query Additional queries also passed, possibly `seasonId` or similar.
#' @param ... Arguments passed to [jsonlite::fromJSON()] for parsing.
#' @inheritParams fflr_id
#' @inheritParams fflr_id
#' @examples
#' \dontrun{
#' fflr_api()
#' }
#' @return A single JSON string.
#' @importFrom httr RETRY accept_json add_headers user_agent http_type content
#'   http_error status_code
#' @importFrom jsonlite fromJSON
#' @keywords internal
#' @export
fflr_api <- function(path = "", query = NULL, leagueId = fflr_id(), ...) {
  resp <- httr::RETRY(
    verb = "GET",
    url = "https://fantasy.espn.com",
    path = c("apis", "v3", "games", "ffl", path),
    query = query,
    httr::accept_json(),
    httr::user_agent("https://github.com/kiernann/fflr/"),
    terminate_on = c(400:417)
  )
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return JSON", call. = FALSE)
  }
  raw <- httr::content(resp, as = "text", encoding = "UTF-8")
  parsed <- jsonlite::fromJSON(raw, ...)
  if (httr::http_error(resp) && "message" %in% names(parsed)) {
    stop(
      sprintf(
        "ESPN Fantasy API request failed [%s]\n%s",
        httr::status_code(resp), parsed$message
      ),
      call. = FALSE
    )
  }
  parsed
}
