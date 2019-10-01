#' @title Get Fantasy Current Data
#' @description Call [httr::GET()] on the ESPN Fantasy Football API.
#' @param lid The ESPN Leaugue ID.
#' @param ... Query arguments passed to [httr::GET()] `query` argument (coerced
#'   as a single list).
#' @param current logical; if `TRUE` the v3 API (for 2019 and later) will be
#'   used; if `FALSE` the _historical_ API will be used.
#' @return A nested list of API results.
#' @examples
#' ffl_get(lid = 252353, view = "members")
#' @importFrom httr GET content
#' @export
ffl_get <- function(lid, ..., current = TRUE) {
  url <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  if (current) {
    api <- paste0(url, "seasons/2019/segments/0/leagues/", lid)
  } else {
    api <- paste0(url, "leagueHistory/", lid)
  }
  data <- httr::content(httr::GET(url = api, query = list(...)))
  return(data)
}


