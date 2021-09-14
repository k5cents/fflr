#' All fantasy players
#'
#' List all available players.
#'
#' @inheritParams ffl_id
#' @param scoringPeriodId A scoring period to return, defaults to [ffl_week()].
#' @param limit The limit of players to return. Use `""` or `NULL` to return
#'   all. Defaults to 50, which is the default limit used by ESPN. Removing the
#'   limit can make the request take a long time.
#' @return A data frame of players.
#' @examples
#' \dontrun{
#' all_players()
#' }
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom httr RETRY add_headers accept_json content
#' @export
all_players <- function(leagueId = ffl_id(), scoringPeriodId = ffl_week(),
                        limit = 50) {
  if (is.null(leagueId)) leagueId <- "42654852"
  if (is.null(limit)) limit <- ""
  all_get <- httr::RETRY(
    verb = "GET",
    url = paste0(
      "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2021/segments/0/leagues/",
      leagueId
    ),
    query = list(view = "kona_player_info"),
    httr::accept_json(),
    httr::add_headers(
      `X-Fantasy-Filter` = jsonlite::toJSON(
        x = list(
          players = list(
            limit = limit,
            sortPercOwned = list(
              sortAsc = FALSE,
              sortPriority = 1
            ),
            filterStatsForTopScoringPeriodIds = list(
              value = 2,
              additionalValue = c(
                "002021",
                "102021",
                "002020",
                "022020",
                sprintf("112021%i", scoringPeriodId),
                "022021"
              )
            )
          )
        ),
        auto_unbox = TRUE
      )
    )
  )
  pl <- jsonlite::fromJSON(httr::content(all_get, as = "text"))
  pl <- pl$players
  z <- data.frame(
    id = pl$player$id,
    next_wk = NA_real_,
    last_wk = NA_real_,
    last_szn = NA_real_,
    this_szn = NA_real_
  )
  y <- max(pl$player$stats[[1]]$seasonId)
  for (i in seq_along(pl$player$stats)) {
    s <- pl$player$stats[[i]][-2]
    if (is.null(s)) {
      next("player states are null can skip")
    }
    if (length(unique(s$scoringPeriodId)) < 3) {
      next # player doesn't have stats from last week
    }
    # if (sum(s$seasonId == y - 1) > 1) {
    #   next # player just joined, mostly last season
    # }
    w <- max(s$scoringPeriodId[s$seasonId == y])
    w_last <- which(s$statSourceId == 0 & s$statSplitTypeId == 1 & s$scoringPeriodId == w - 1)
    if (length(w_last) == 1) {
      z$last_wk[i] <- s$appliedTotal[w_last]
    } else {
      z$last_wk[i] <- NA
    }
    w_next <- which(s$statSourceId == 1 & s$statSplitTypeId == 1 & s$w == w)
    if (length(w_next) == 1) {
      z$next_wk[i] <- s$appliedTotal[w_next]
    } else {
      z$next_wk[i] <- NA
    }
    z$this_szn[i] <- s$appliedTotal[s$id == paste0("00", y)]
    if (length(unique(s$seasonId)) > 1) {
      z$last_szn[i] <- s$appliedTotal[s$id == paste0("00", y - 1)]
    }
  }
  out <- as_tibble(pl$player)
  out$draftRanksByRankType <- NULL
  out$rankings <- NULL
  out$proTeamId <- pro_abbrev(out$proTeamId)
  out$defaultPositionId <- pos_abbrev(out$defaultPositionId)
  out$injuryStatus <- substr(out$injuryStatus, 1, 1)
  out$percentOwned <- out$ownership$percentOwned
  out$percentChange <- out$ownership$percentChange
  out$percentStarted <- out$ownership$percentStarted
  out$auctionValueAverage <- out$ownership$auctionValueAverage
  out$averageDraftPosition <- out$ownership$averageDraftPosition
  out$ownership <- NULL

  out <- data.frame(
    stringsAsFactors = FALSE,
    id = pl$player$id,
    firstName = pl$player$firstName,
    lastName = pl$player$lastName,
    proTeam = pro_abbrev(pl$player$proTeamId),
    defaultPositionId = pos_abbrev(pl$player$defaultPositionId),
    injuryStatus = substr(pl$player$injuryStatus, 1, 1),
    percentStarted = pl$player$ownership$percentStarted/100,
    percentOwned = pl$player$ownership$percentOwned/100,
    percentChange = pl$player$ownership$percentChange,
    positionalRanking = pl$ratings$`0`$positionalRanking,
    totalRating = pl$ratings$`0`$totalRating,
    auctionValueAverage = pl$player$ownership$auctionValueAverage,
    averageDraftPosition = pl$player$ownership$averageDraftPosition
  )

  out <- merge(out, z, by = "id", sort = FALSE)
  out <- cbind(seasonId = y, scoringPeriodId, out)
  as_tibble(out)
}

#' Individual player information
#'
#' @param playerId A single player ID number.
#' @return A list or row of a single player's information.
#' @examples
#' player_info(playerId = 15847)
#' @importFrom tibble as_tibble
#' @export
player_info <- function(playerId) {
  if (as.numeric(playerId) < 0) {
    stop("no information available for defenses")
  }
  dat <- try_json(
    url = paste0(
      "http://sports.core.api.espn.com/",
      "v2/sports/football/leagues/nfl/seasons/2021/athletes/", playerId
    )
  )
  out <- list(
    id = playerId,
    firstName = dat$firstName,
    lastName = dat$lastName,
    positionId = dat$position$abbreviation,
    jersey = dat$jersey,
    weight = dat$weight,
    height = dat$height,
    age = dat$age,
    dateOfBirth = dat$dateOfBirth,
    birthPlace = paste(
      dat$birthPlace$city,
      dat$birthPlace$state,
      sep = ", "
    ),
    debutYear = dat$debutYear,
    draftSelection = dat$draft$selection
  )
  out <- out[!sapply(out, is.null)]
  out <- out[sapply(out, function(x) length(x) > 0)]
  if ("dateOfBirth" %in% names(out)) {
    out$dateOfBirth <- as.Date(out$dateOfBirth)
  }
  as_tibble(out)
}
