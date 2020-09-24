#' All fantasy players
#'
#' List all available players.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @return A tibble of players.
#' @examples
#' all_players()
#' @importFrom tibble as_tibble
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom httr GET add_headers accept_json content
#' @export
all_players <- function(lid = NULL) {
  if (is.null(lid)) lid <- 252353
  xff <- list(
    players = list(
      sortPercOwned = list(
        sortAsc = FALSE,
        sortPriority = 1
      ),
      filterStatsForTopScoringPeriodIds = list(
        value = 2,
        additionalValue = c("002020", "102020", "002019", "1120203", "022020")
      )
    )
  )
  g <- httr::GET(
    httr::accept_json(),
    httr::add_headers(
      `X-Fantasy-Filter` = jsonlite::toJSON(
        x = xff,
        auto_unbox = TRUE)
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
  } else {
    stop("API error")
  }
  z <- tibble::tibble(
    player = p$player$id,
    next_wk = NA_real_, last_wk = NA_real_,
    last_szn = NA_real_, this_szn = NA_real_
  )
  y <- max(p$player$stats[[1]]$seasonId)
  if (!(y %in% c(2020:2021))) {
    stop("players from last seasons not available")
  }
  for (i in seq_along(p$player$stats)) {
    s <- p$player$stats[[i]]
    if (length(unique(s$scoringPeriodId)) < 3) {
      next("player doesn't have stats from last week")
    }
    if (sum(s$seasonId == y - 1) > 1) {
      next("player just joined, mostly last season")
    }
    w <- max(s$scoringPeriodId)
    z$last_wk[i] <- s$appliedTotal[s$statSourceId == 0 & s$statSplitTypeId == 1 & s$scoringPeriodId == w - 1]
    z$next_wk[i] <- s$appliedTotal[s$statSourceId == 1 & s$statSplitTypeId == 1 & s$scoringPeriodId == w]
    z$this_szn[i] <- s$appliedTotal[s$id == paste0("00", y)]
    if (length(unique(s$seasonId)) > 1) {
      z$last_szn[i] <- s$appliedTotal[s$id == paste0("00", y - 1)]
    }
  }
  out <- data.frame(
    player = p$player$id,
    first = p$player$firstName,
    last = p$player$lastName,
    pro  = nfl_teams$nfl[match(p$player$proTeamId, nfl_teams$team)],
    pos = factor(
      x = p$player$defaultPositionId,
      levels = c(1:5, 16),
      labels = c("QB", "RB", "WR", "TE", "KI", "DS")
    ),
    status = abbreviate(p$player$injuryStatus, minlength = 1),
    start = p$player$ownership$percentStarted/100,
    rost = p$player$ownership$percentOwned/100,
    change = round(p$player$ownership$percentChange, digits = 3),
    prk = p$ratings$`0`$positionalRanking,
    fpts = p$ratings$`0`$totalRating,
    aav = p$player$ownership$auctionValueAverage,
    adp = p$player$ownership$averageDraftPosition
  )
  out <- merge(out, z, by = "player", sort = FALSE)
  return(tibble::as_tibble(out))
}
