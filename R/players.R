#' Find fantasy players
#'
#' Filter fantasy players by their position, availability, professional team,
#' and/or injury status. Sort and limit the responses in the same way as is
#' done in the ESPN Fantasy Football website.
#'
#' @inheritParams ffl_id
#' @param sort The column from which to sort the data. Options match those on
#'   the ESPN website:
#'   * "PLAYER" = Alphabetical by player name
#'   * "PROJ" = Projection is ESPN’s projected fantasy score for a player’s
#'   upcoming game.
#'   * "SCORE" = Actual score for `scoringPeriodId`
#'   * "OPRK" = Opponent Rank shows how a player’s upcoming NFL opponent
#'   performs against that player’s position. Low numbers mean it may be a
#'   tough opponent; high numbers an easier opponent.
#'   * "START" = Start Percentage shows the number of fantasy leagues a player
#'   is started in divided by the number of leagues he is eligible in. This
#'   helps indicate how the public views a player.
#'   * "ROST" = Rostered Percentage shows the number of fantasy leagues in
#'   which a player is on a roster divided by the total number of fantasy
#'   leagues. This helps indicate how the public views a player.
#'   * "CHANGE" = Plus/Minus shows the change in %ROST over the last week. This
#'   will help show which players are hot and cold at a given moment.
#'   * "PRK" = Position Rank shows how a player stacks up against other players
#'   at his position. No. 1 is best.
#'   * "FPTS" = Total fantasy points scored thus far in the season.
#'   * "AVG" = Average fantasy points scored in each game started.
#'   * "LAST" = Last shows the player’s fantasy score in his team’s last game.
#' @param position Abbreviation of player positions to filter, `NULL` for all:
#'   * "QB" = Quarterback
#'   * "RB" = Running Back
#'   * "WR" = Wide Receiver
#'   * "TE" = Tight End
#'   * "FLEX" = Running Backs, Wide Receivers and Tight Ends can be used in this
#'   position
#'   * "D/ST" = Defense and Special Teams
#'   * "K" = Kicker
#' @param status Availability status of player, one or more from:
#'   * "ALL"
#'   * "AVAILABLE" (default)
#'   * "FREEAGENT"
#'   * "WAIVERS"
#'   * "ONTEAM"
#' @param injured Whether to return only injured or healthy players. Use `NULL`
#'   (default) for all players, `TRUE` for injured players, and `FALSE` for
#'   healthy players.
#' @param proTeam The abbreviation or ID of the professional team from which
#'   players should be returned. See `pro_teams()` for a list of all possible
#'   team abbreviations.
#' @param scoreType The type of scoring used: "STANDARD" or "PPR."
#' @param limit The limit of players to return. Use `""` or `NULL` to return
#'   all. Defaults to 50, which is the default limit used by ESPN. Removing the
#'   limit can make the request take a long time.
#' @return A data frame of players. If no players meet the filter criteria
#'   (e.g., `status = "FREEAGENT"` while all players are locked on waivers), a
#'   data frame with zero rows and the same columns.
#' @examples
#' list_players("42654852", proTeam = "MIA", sort = "START", limit = 3)
#' @importFrom jsonlite toJSON fromJSON unbox
#' @importFrom httr RETRY add_headers accept_json content
#' @importFrom httr http_type http_error status_code
#' @family player functions
#' @export
list_players <- function(leagueId = ffl_id(),
                         sort = "ROST",
                         position = NULL,
                         status = "AVAILABLE",
                         injured = NULL,
                         proTeam = NULL,
                         scoreType = c("STANDARD", "PPR"),
                         limit = 50) {
  scoringPeriodId <- ffl_week()
  if (is.null(limit)) limit <- ""
  resp <- httr::RETRY(
    verb = "GET",
    url = paste0(
      "https://lm-api-reads.fantasy.espn.com",
      "/apis/v3/games/ffl/seasons/2026/segments/0/leagues/",
      leagueId
    ),
    query = list(view = "kona_player_info"),
    httr::accept_json(),
    httr::add_headers(
      `X-Fantasy-Filter` = fantasy_filter(
        sort = sort,
        position = position,
        status = status,
        injured = injured,
        scoringPeriodId = scoringPeriodId,
        proTeam = proTeam,
        scoreType = scoreType,
        limit = limit
      )
    )
  )
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return JSON", call. = FALSE)
  }
  raw <- httr::content(resp, as = "text", encoding = "UTF-8")
  parsed <- jsonlite::fromJSON(raw)
  if (httr::http_error(resp) && any(grepl("message", names(parsed)))) {
    stop(
      sprintf(
        "ESPN Fantasy API request failed [%s]\n%s",
        httr::status_code(resp), parsed$message
      ),
      call. = FALSE
    )
  }
  pl <- parsed$players
  if (length(pl) == 0) {
    return(empty_players(scoringPeriodId))
  }
  z <- data.frame(
    id = pl$player$id,
    projectedScore = NA_real_,
    lastScore = NA_real_,
    lastSeason = NA_real_,
    currentSeason = NA_real_
  )
  y <- max(pl$player$stats[[1]]$seasonId)
  for (i in seq_along(pl$player$stats)) {
    s <- pl$player$stats[[i]][-2]
    if (is.null(s)) {
      next # player states are null can skip
    }
    if (length(unique(s$scoringPeriodId)) < 3) {
      next # player doesn't have stats from last week
    }
    # if (sum(s$seasonId == y - 1) > 1) {
    #   next # player has more than one from previous season
    # }
    w <- max(s$scoringPeriodId[s$seasonId == y])
    w_last <- which(s$statSourceId == 0 &
                      s$statSplitTypeId == 1 &
                      s$scoringPeriodId == w - 1)
    if (length(w_last) == 1) {
      z$lastScore[i] <- s$appliedTotal[w_last]
    } else {
      z$lastScore[i] <- NA
    }
    w_next <- which(s$statSourceId == 1 &
                      s$statSplitTypeId == 1 &
                      s$scoringPeriodId == w)
    if (length(w_next) == 1) {
      z$projectedScore[i] <- s$appliedTotal[w_next]
    } else {
      z$projectedScore[i] <- NA
    }
    z$currentSeason[i] <- s$appliedTotal[s$id == paste0("00", y)]
    if (length(unique(s$seasonId)) > 1) {
      which_last <- which(s$id == paste0("00", y - 1))
      if (length(which_last) < 1) {
        z$lastSeason[i] <- NA_real_
      } else {
        z$lastSeason[i] <- s$appliedTotal[which_last]
      }
    } else {
      z$lastSeason[i] <- NA_real_
    }
  }
  out <- as_tibble(pl$player)
  out$draftRanksByRankType <- NULL
  out$rankings <- NULL
  out$proTeamId <- pro_abbrev(out$proTeamId)
  out$defaultPosition <- pos_abbrev(out$defaultPositionId)
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
    defaultPosition = pos_abbrev(pl$player$defaultPositionId),
    injuryStatus = substr(pl$player$injuryStatus, 1, 1),
    percentStarted = pl$player$ownership$percentStarted / 100,
    percentOwned = pl$player$ownership$percentOwned / 100,
    percentChange = pl$player$ownership$percentChange,
    # positionalRanking = pl$ratings$`0`$positionalRanking,
    # totalRating = pl$ratings$`0`$totalRating,
    auctionValueAverage = pl$player$ownership$auctionValueAverage,
    averageDraftPosition = pl$player$ownership$averageDraftPosition
  )

  out <- merge(out, z, by = "id", sort = FALSE)
  out <- cbind(seasonId = y, scoringPeriodId, out)
  as_tibble(out)
}

# -------------------------------------------------------------------------

#' All fantasy players (deprecated)
#'
#' See [list_players()].
#'
#' @param ... Arguments passed to the new [list_players()] function.
#' @examples
#' \dontrun{
#' all_players()
#' }
#' @family player functions
#' @export
all_players <- function(...) {
  .Deprecated("list_players")
  list_players(...)
}

# -------------------------------------------------------------------------

empty_players <- function(scoringPeriodId) {
  as_tibble(
    data.frame(
      stringsAsFactors = FALSE,
      seasonId = integer(),
      scoringPeriodId = scoringPeriodId[0],
      id = integer(),
      firstName = character(),
      lastName = character(),
      proTeam = pro_abbrev(integer()),
      defaultPosition = pos_abbrev(integer()),
      injuryStatus = character(),
      percentStarted = double(),
      percentOwned = double(),
      percentChange = double(),
      auctionValueAverage = double(),
      averageDraftPosition = double(),
      projectedScore = double(),
      lastScore = double(),
      lastSeason = double(),
      currentSeason = double()
    )
  )
}

U <- function(x) {
  jsonlite::unbox(x)
}

fantasy_filter <- function(sort, position, status, injured, scoringPeriodId,
                           proTeam, scoreType, limit) {
  if (is.null(position)) {
    position <- c(0:19, 23:24)
  }
  status <- match.arg(
    arg = status,
    choices = c("ALL", "AVAILABLE", "FREEAGENT", "WAIVERS", "ONTEAM"),
    several.ok = TRUE
  )
  if ("AVAILABLE" %in% status) {
    status <- union(setdiff(status, "AVAILABLE"), c("FREEAGENT", "WAIVERS"))
  }
  scoreType <- match.arg(scoreType, c("STANDARD", "PPR"))
  sort_choice <- filter_sort(sort = sort, scoringPeriodId)
  out <- list(
    players = list(
      filterStatus = NULL,
      filterSlotIds = list(
        value = slot_unabbrev(position)
      ),
      filterRanksForScoringPeriodIds = list(
        value = scoringPeriodId
      ),
      filterProTeamIds = NULL,
      filterInjured = NULL,
      limit = U(limit),
      offset = U(0),
      sortPlacehold = list(),
      sortDraftRanks = list(
        sortPriority = U(100),
        sortAsc = U(TRUE),
        value = U("STANDARD")
      ),
      filterRanksForRankTypes = list(
        value = scoreType
      ),
      filterRanksForSlotIds = list(
        value = c(0, 2, 4, 6, 17, 16)
      ),
      filterStatsForTopScoringPeriodIds = list(
        value = U(2),
        additionalValue = c(
          "002026",
          "102026",
          "002020",
          paste0("112026", scoringPeriodId),
          "022026"
        )
      )
    )
  )
  if (is.null(proTeam)) {
    out$players$filterProTeamIds <- NULL
  } else {
    out$players$filterProTeamIds <- list(
      value = pro_unabbrev(proTeam)
    )
  }
  if (is.null(injured)) {
    out$players$filterInjured <- NULL
  } else {
    stopifnot(is.logical(injured))
    out$players$filterInjured <- list(
      value = U(injured)
    )
  }
  if ("ALL" %in% status) {
    out$players$filterStatus <- NULL
  } else {
    out$players$filterStatus <- list(
      value = status
    )
  }
  out$players$sortPlacehold <- sort_choice$sort[[1]]
  names(out$players)[names(out$players) == "sortPlacehold"] <- sort_choice$name
  jsonlite::toJSON(out, auto_unbox = FALSE)
}

# -------------------------------------------------------------------------

filter_sort <- function(sort = "ROST", scoringPeriodId) {
  sort_short <- c(
    "PLAYER", "PROJ", "SCORE", "OPRK", "START",
    "ROST", "CHANGE", "PRK", "FPTS", "AVG", "LAST"
  )
  sort <- match.arg(sort, sort_short)
  sort_n <- match(sort, sort_short)

  sort_opt <- list(
    sortName = list( # PLAYER
      sortAsc = FALSE,
      sortPriority = 3
    ),
    sortAppliedStatTotal = list( # PROJ
      sortAsc = FALSE,
      sortPriority = 1,
      value = paste0("112026", scoringPeriodId)
    ),
    sortAppliedStatTotalForScoringPeriodId = list( # SCORE
      sortAsc = FALSE,
      sortPriority = 1,
      value = scoringPeriodId
    ),
    sortOpponentVsPositionRank = list( # OPRK
      sortAsc = FALSE,
      sortPriority = 1,
      value = scoringPeriodId
    ),
    sortPercStarted = list( # %ST
      sortAsc = FALSE,
      sortPriority = 1
    ),
    sortPercOwned = list( # %ROST
      sortAsc = FALSE,
      sortPriority = 1
    ),
    sortPercChanged = list( # +/-
      sortAsc = FALSE,
      sortPriority = 1
    ),
    sortRatingPositional = list( # PRK
      sortAsc = FALSE,
      sortPriority = 1,
      value = 0
    ),
    sortAppliedStatTotal = list( # FPTS
      sortAsc = FALSE,
      sortPriority = 1,
      value = "002026"
    ),
    sortAppliedStatAverage = list( # AVG
      sortAsc = FALSE,
      sortPriority = 1,
      value = "002026"
    ),
    sortAppliedStatTotalForScoringPeriodId = list( # LAST
      sortAsc = FALSE,
      sortPriority = 1,
      value = scoringPeriodId - 1
    ),
    sortRanks = list(
      sortAsc = TRUE,
      sortPriority = 1,
      value = 2
      # Berry: 2
      # Karabell: 3
      # Yates: 6
      # Cockcroft: 5
      # Clay: 7
      # Average: 0
    )
  )
  sort_opt <- lapply(
    X = sort_opt,
    FUN = function(x) {
      lapply(x, jsonlite::unbox)
    }
  )
  list(
    name = names(sort_opt)[sort_n],
    sort = sort_opt[sort_n]
  )
}

# -------------------------------------------------------------------------

#' Individual player information
#'
#' @param playerId A single player ID number.
#' @return A list or row of a single player's information.
#' @examples
#' player_info(playerId = 15847)
#' @importFrom tibble as_tibble
#' @family player functions
#' @export
player_info <- function(playerId) {
  if (as.numeric(playerId) < 0) {
    stop("no information available for defenses")
  }
  dat <- try_json(
    url = paste0(
      "http://sports.core.api.espn.com/",
      "v2/sports/football/leagues/nfl/seasons/2026/athletes/", playerId
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

# -------------------------------------------------------------------------

#' Look up players by ID
#'
#' Player detail for any player ID in the league -- rostered, free agent, or
#' on waivers, including defenses -- shaped like a row from [team_roster()].
#'
#' [player_info()] can't do this: it 404s on defenses, whose IDs are
#' negative, and its upstream source drops fields inconsistently. This asks
#' the same `kona_player_info` view [list_players()] uses, filtered to
#' exactly these IDs with an `X-Fantasy-Filter` header, so it works for any
#' player regardless of which team, if any, rosters them -- the building
#' block for simulating a roster that doesn't exist yet, as [evaluate_trade()]
#' does.
#'
#' @inheritParams ffl_api
#' @param playerId Integer vector of player IDs. Defense IDs are negative. An
#'   error is raised if any ID doesn't match a player.
#' @return A tibble, one row per unique `playerId` in the order given, shaped
#'   like a [team_roster()] row but without `teamId`, `abbrev`, or `lineupSlot` -- a looked-up
#'   player isn't rostered by, or slotted on, any one team.
#' @examples
#' \dontrun{
#' player_lookup(playerId = c(4427366, -16027))
#' }
#' @importFrom jsonlite toJSON
#' @family player functions
#' @export
player_lookup <- function(playerId, leagueId = ffl_id(), seasonId = ffl_year(),
                          scoringPeriodId = ffl_week(), cookie = ffl_cookie()) {
  playerId <- as.integer(playerId)
  filter <- list(players = list(filterIds = list(value = as.list(playerId))))
  parsed <- try_json(
    url = "https://lm-api-reads.fantasy.espn.com",
    path = sprintf(
      "apis/v3/games/ffl/seasons/%i/segments/0/leagues/%s",
      seasonId, leagueId
    ),
    query = list(view = "kona_player_info", scoringPeriodId = scoringPeriodId),
    cookie = cookie,
    headers = c(
      `X-Fantasy-Filter` = as.character(
        jsonlite::toJSON(filter, auto_unbox = TRUE)
      )
    ),
    simplifyVector = FALSE
  )
  found <- vapply(parsed$players, function(p) as.integer(p$player$id), integer(1))
  missing <- setdiff(playerId, found)
  if (length(missing) > 0) {
    stop(
      sprintf("no player found for ID(s) %s", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }
  rows <- lapply(
    X = parsed$players[match(unique(playerId), found)],
    FUN = out_lookup,
    wk = scoringPeriodId,
    yr = seasonId
  )
  bind_df(rows)
}

out_lookup <- function(p, wk, yr) {
  player <- p$player
  proj <- NA_real_
  score <- NA_real_
  has_week <- FALSE
  for (s in player$stats) {
    if (is.null(s$scoringPeriodId) || is.null(s$statSplitTypeId) || is.null(s$statSourceId)) {
      next
    }
    if (s$scoringPeriodId != wk || s$statSplitTypeId != 1) {
      next
    }
    has_week <- TRUE
    if (s$statSourceId == 1) proj <- s$appliedTotal
    if (s$statSourceId == 0) score <- s$appliedTotal
  }
  # match `out_roster()`: a defense with no stats that week is on bye
  if (!has_week && player$defaultPositionId == 16) {
    proj <- 0
    score <- 0
  }
  injury_status <- player$injuryStatus
  if (is.null(injury_status) || !nzchar(injury_status)) {
    injury_status <- "ACTIVE"
  }
  own <- player$ownership
  data.frame(
    seasonId = yr,
    scoringPeriodId = wk,
    playerId = player$id,
    firstName = player$firstName,
    lastName = player$lastName,
    proTeam = pro_abbrev(player$proTeamId),
    position = pos_abbrev(player$defaultPositionId),
    injuryStatus = abbreviate(injury_status, minlength = 1),
    projectedScore = proj,
    actualScore = score,
    percentStarted = null_na(own$percentStarted),
    percentOwned = null_na(own$percentOwned),
    percentChange = round(null_na(own$percentChange), digits = 3),
    eligibleSlots = I(list(unlist(player$eligibleSlots)))
  )
}

null_na <- function(x) {
  if (is.null(x)) NA_real_ else x
}
