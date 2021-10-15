#' Player news
#'
#' The free and premium ESPN stories on given players. A maximum of 50 stories
#' can be returned at a time.
#'
#' @inheritParams player_info
#' @param parseHTML Should HTML stories be parsed with [xml2::read_html()]?
#' @return A data frame of news stories.
#' @examples
#' player_news(playerId = "15847")
#' @importFrom tibble tibble
#' @family player functions
#' @export
player_news <- function(playerId, parseHTML = FALSE) {
  dat <- try_json(
    url = "https://site.api.espn.com/apis/fantasy/v2/games/ffl/news/players",
    query = list(playerId = playerId)
  )
  if (dat$resultsCount == dat$resultsLimit) {
    warning("Feed limit of 50 reached")
  }
  x <- dat$feed$story
  x[is.na(x)] <- dat$feed$description[is.na(x)]
  if (isTRUE(parseHTML)) {
    if (is_installed("xml2")) {
      is_html <- grep("^<.*>", dat$feed$story)
      x[is_html] <- lapply(as.list(x)[is_html], xml2::read_html)
    } else {
      stop("Package \"xml2\" needed to parse HTML stories")
    }
  } else {
    x <- gsub("\"", "'", x)
  }
  tibble::tibble(
    id = dat$feed$playerId,
    published = ffl_timestamp(dat$feed$published),
    type = dat$feed$type,
    premium = dat$feed$premium,
    headline = gsub("\"", "'", dat$feed$headline),
    body = x
  )
}
