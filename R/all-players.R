#' All fantasy players
#'
#' List all available players.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @param week The scoring period to return, defaults to [ffl_week()].
#' @param limit The limit of players to return, `""` or `NULL` returns all.
#'   Defaults to 50, which is the default limit used by ESPN. Removing the limit
#'   can make the request take a long time.
#' @return A tibble of players.
#' @examples
#' \dontrun{
#' all_players()
#' }
#' @importFrom tibble as_tibble
#' @importFrom jsonlite toJSON
#' @importFrom httr GET add_headers accept_json content
#' @export
all_players <- function(lid = getOption("lid"), week = ffl_week(), limit = 50) {
  if (is.null(lid)) lid <- 252353
  if (is.null(limit)) limit <- ""
  xff <- list(
    players = list(
      limit = limit,
      sortPercOwned = list(
        sortAsc = FALSE,
        sortPriority = 1
      ),
      filterStatsForTopScoringPeriodIds = list(
        value = 2,
        additionalValue = c(
          "002020", "102020", "002019", "022020", sprintf("112020%s", week)
        )
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
  z <- tibble::tibble(
    id = p$player$id,
    next_wk = NA_real_, last_wk = NA_real_,
    last_szn = NA_real_, this_szn = NA_real_
  )
  y <- max(p$player$stats[[1]]$seasonId)
  for (i in seq_along(p$player$stats)) {
    s <- p$player$stats[[i]][-2]
    if (is.null(s)) {
      next("player states are null can skip")
    }
    names(s)[1:7] <- c("stat", "id", "pro", "w", "y", "source", "split")
    if (length(unique(s$w)) < 3) {
      next("player doesn't have stats from last week")
    }
    if (sum(s$y == y - 1) > 1) {
      next("player just joined, mostly last season")
    }
    w <- max(s$w)
    w_last <- which(s$source == 0 & s$split == 1 & s$w == w - 1)
    if (length(w_last) == 1) {
      z$last_wk[i] <- s$stat[w_last]
    } else {
      z$last_wk[i] <- NA
    }
    w_next <- which(s$source == 1 & s$split == 1 & s$w == w)
    if (length(w_next) == 1) {
      z$next_wk[i] <- s$stat[w_next]
    } else {
      z$next_wk[i] <- NA
    }
    z$this_szn[i] <- s$stat[s$id == paste0("00", y)]
    if (length(unique(s$y)) > 1) {
      z$last_szn[i] <- s$stat[s$id == paste0("00", y - 1)]
    }
  }
  out <- data.frame(
    stringsAsFactors = FALSE,
    id = p$player$id,
    first = p$player$firstName,
    last = p$player$lastName,
    pro  = fflr::nfl_teams$abbrev[match(p$player$proTeamId, fflr::nfl_teams$team)],
    pos = pos_abbrev(p$player$defaultPositionId),
    status = abbreviate(p$player$injuryStatus, minlength = 1),
    start = p$player$ownership$percentStarted/100,
    rost = p$player$ownership$percentOwned/100,
    change = round(p$player$ownership$percentChange, digits = 3),
    prk = p$ratings$`0`$positionalRanking,
    fpts = p$ratings$`0`$totalRating,
    aav = p$player$ownership$auctionValueAverage,
    adp = p$player$ownership$averageDraftPosition
  )
  out <- merge(out, z, by = "id", sort = FALSE)
  out <- cbind(year = y, week, out)
  tibble::as_tibble(out)
}
