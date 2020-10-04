#' Player news
#'
#' The free and premium ESPN stories on given players. A maximum of 50 stories
#' can be returned at a time.
#'
#' @param id A vector of player ID numbers.
#' @param parse Should HTML stories be parsed with [xml2::read_html()]?
#' @return A tibble of news stories.
#' @examples
#' player_news(15847)
#' @importFrom tibble tibble
#' @importFrom jsonlite fromJSON
#' @export
player_news <- function(id, parse = FALSE) {
  api_base <- "https://site.api.espn.com"
  api_path <- "/apis/fantasy/v2/games/ffl/news/players?playerId="
  id_all <- paste(id, collapse = "&playerId=")
  d <- fromJSON(paste0(api_base, api_path, id_all))
  if (d$resultsCount == d$resultsLimit) {
    warning("Feed limit of 50 reached")
  }
  x <- d$feed$story
  x[is.na(x)] <- d$feed$description[is.na(x)]
  if (isTRUE(parse)) {
    if (!requireNamespace("xml2", quietly = TRUE)) {
      stop("Package \"xml2\" needed to parse HTML stories", call. = FALSE)
    } else {
      is_html <- grep("^<.*>", d$feed$story)
      x[is_html] <- lapply(as.list(x)[is_html], xml2::read_html)
    }
  } else {
    x <- gsub("\"", "'", x)
  }
  tibble::tibble(
    id = d$feed$playerId,
    published = ffl_timestamp(d$feed$published),
    type = d$feed$type,
    premium = d$feed$premium,
    headline = gsub("\"", "'", d$feed$headline),
    body = x
  )
}

ffl_timestamp <- function(x) {
  as.POSIXlt(x, tz = "UTC", format = "%Y-%m-%dT%H:%M:%S")
}
