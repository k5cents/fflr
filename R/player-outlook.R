#' Player outlooks
#'
#' All available weekly ESPN outlook writeups for NFL players.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @return A tibble of player outlooks.
#' @examples
#' player_outlook()
#' @importFrom tibble as_tibble
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom httr GET add_headers accept_json content
#' @export
player_outlook <- function(lid = getOption("lid")) {
  if (is.null(lid)) lid <- 252353
  xff <- list(
    players = list(
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
  p <- jsonlite::fromJSON(httr::content(g, "text"))
  if (length(p) == 2) {
    p <- p$players
  }
  y <- max(p$player$stats[[1]]$seasonId)
  w <- length(p$player$outlooks$outlooksByWeek)
  outlooks <- as.vector(t(as.data.frame(p$player$outlooks$outlooksByWeek)))
  out <- tibble::tibble(
    year = y,
    week = rep(seq(w), length(outlooks)/w),
    id = rep(p$player$id, each = w),
    first = rep(p$player$firstName, each = w),
    last = rep(p$player$lastName, each = w),
    outlook = outlooks
  )
  out[!is.na(out$outlook), ]
}
