#' @title Get Fantasy Current Data
#' @description Call [httr::GET()] on the ESPN Fantasy Football API.
#' @param lid The ESPN Leaugue ID.
#' @param ... Query arguments passed to [httr::GET()] `query` argument (coerced
#'   as a single list).
#' @return A nested list of API results.
#' @examples
#' ffl_get(lid = 252353, view = "members")
#' @importFrom httr GET content
#' @export
ffl_get <- function(lid, ...) {
  api <- paste0("https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leagues/", lid)
  data <- httr::content(httr::GET(url = api, query = list(...)))
  return(data)
}
