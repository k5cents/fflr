#' Player outlooks
#'
#' All available weekly ESPN outlook writeups for NFL players.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @param limit The limit of players to return, `""` or `NULL` returns all.
#'   Defaults to 50, which is the default limit used by ESPN. Removing the limit
#'   can make the request take a long time.
#' @return A tibble of player outlooks.
#' @examples
#' player_outlook()
#' @importFrom tibble as_tibble
#' @importFrom jsonlite toJSON
#' @importFrom httr GET add_headers accept_json content
#' @export
player_outlook <- function(lid = getOption("lid"), limit = 50) {
  if (is.null(lid)) lid <- 252353
  if (is.null(limit)) limit <- ""
  xff <- list(
    players = list(
      limit = limit,
      sortPercOwned = list(
        sortAsc = FALSE,
        sortPriority = 1
      )
    )
  )
  g <- httr::GET(
    httr::accept_json(),
    httr::add_headers(
      `X-Fantasy-Filter` = jsonlite::toJSON(
        x = xff,
        auto_unbox = TRUE
      )
    ),
    query = list(view = "kona_player_info"),
    url = paste0(
      "https://fantasy.espn.com/apis/v3/games/ffl",
      "/seasons/2020/segments/0/leagues/", lid
    )
  )
  p <- try_api(httr::content(g, "text"))
  if (length(p) == 2) {
    p <- p$players
  }
  y <- max(p$player$stats[[1]]$seasonId)
  w <- length(p$player$outlooks$outlooksByWeek)
  x <- p$player$outlooks$outlooksByWeek
  x$`0` <- p$player$seasonOutlook
  x <- x[c(length(x), 1:length(x) - 1)]
  outlooks <- as.vector(t(as.data.frame(x)))
  out <- tibble::tibble(
    year = y,
    week = rep(seq(0, w), length(outlooks)/(w + 1)),
    id = rep(p$player$id, each = w + 1),
    first = rep(p$player$firstName, each = w + 1),
    last = rep(p$player$lastName, each = w + 1),
    outlook = outlooks
  )
  out[!is.na(out$outlook), ]
}
