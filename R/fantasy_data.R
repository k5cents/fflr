#' @title Get Fantasy Data
#' @description Call [httr::GET()] on the ESPN Fantasy Football API.
#' @param lid The ESPN Leaugue ID.
#' @param ... Query arguments passed to [httr::GET()] `query` argument (coerced
#'   as a single list).
#' @param current logical; if `TRUE` the v3 API (for 2019 and later) will be
#'   used; if `FALSE` the _historical_ API will be used.
#' @return A nested list of API results.
#' @examples
#' fantasy_data(lid = 252353, view = "members")
#' @importFrom httr GET content
#' @export
fantasy_data <- function(lid, ..., current = TRUE) {
  url <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  if (current) {
    api <- paste0(url, "seasons/2019/segments/0/leagues/", lid)
  } else {
    api <- paste0(url, "leagueHistory/", lid)
  }
  data <- httr::content(httr::GET(api, query = list(...)))
  return(data)
}

#' @title Get Fantasy Roster Data
#' @description Call [httr::GET()] on the ESPN Fantasy Football API with the
#'   `view` set to "roster."
#' @param lid The ESPN Leaugue ID.
#' @param ... Query arguments passed to [httr::GET()] `query` argument (coerced
#'   as a single list).
#' @param current logical; if `TRUE` the v3 API (for 2019 and later) will be
#'   used; if `FALSE` the _historical_ API will be used.
#' @return A nested list of API results.
#' @examples
#' fantasy_roster(lid = 252353)
#' @importFrom httr GET content
#' @export
fantasy_roster <- function(lid, ..., current = TRUE) {
  url <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  if (current) {
    api <- paste0(url, "seasons/2019/segments/0/leagues/", lid)
  } else {
    api <- paste0(url, "leagueHistory/", lid)
  }
  data <- httr::content(httr::GET(api, query = list(view = "roster", ...)))
  return(data)
}

#' @title Get Fantasy Member Data
#' @description Call [httr::GET()] on the ESPN Fantasy Football API with the
#'   `view` set to "members"
#' @param lid The ESPN Leaugue ID.
#' @param ... Query arguments passed to [httr::GET()] `query` argument (coerced
#'   as a single list).
#' @param current logical; if `TRUE` the v3 API (for 2019 and later) will be
#'   used; if `FALSE` the _historical_ API will be used.
#' @return A nested list of API results.
#' @examples
#' fantasy_roster(lid = 252353)
#' @importFrom httr GET content
#' @export
fantasy_members <- function(lid, ..., current = TRUE) {
  url <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  if (current) {
    api <- paste0(url, "seasons/2019/segments/0/leagues/", lid)
  } else {
    api <- paste0(url, "leagueHistory/", lid)
  }
  data <- httr::content(httr::GET(api, query = list(view = "members", ...)))
  return(data)
}

#' @title Get Fantasy Matchup Data
#' @description Call [httr::GET()] on the ESPN Fantasy Football API with the
#'   `view` set to "mMatchup"
#' @param lid The ESPN Leaugue ID.
#' @param ... Query arguments passed to [httr::GET()] `query` argument (coerced
#'   as a single list).
#' @param current logical; if `TRUE` the v3 API (for 2019 and later) will be
#'   used; if `FALSE` the _historical_ API will be used.
#' @return A nested list of API results.
#' @examples
#' fantasy_roster(lid = 252353)
#' @importFrom httr GET content
#' @export
fantasy_matchup <- function(lid, ..., current = TRUE) {
  url <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  if (current) {
    api <- paste0(url, "seasons/2019/segments/0/leagues/", lid)
  } else {
    api <- paste0(url, "leagueHistory/", lid)
  }
  data <- httr::content(httr::GET(api, query = list(view = "mMatchup", ...)))
  return(data)
}
