#' Convert team ID to abbreviation
#'
#' @param teamId A integer vector of team numbers to convert.
#' @param teams A table of teams, like that from [league_teams()].
#' @return A factor vector of team abbreviations.
#' @examples
#' team_abbrev(teamId = 2, teams = league_teams(leagueId = "42654852"))
#' @export
team_abbrev <- function(teamId, teams = league_teams(leagueId = ffl_id())) {
  if (!(all(c("abbrev", "teamId") %in% names(teams)))) {
    stop("team data lacks `abbrev` and `teamId` columns")
  }
  stopifnot(is.data.frame(teams))
  teams$abbrev[match(teamId, teams$teamId)]
}

team_unabbrev <- function(abbrev, teams = league_teams(leagueId = ffl_id())) {
  if (all(could_be_numeric(abbrev))) {
    return(as.integer(abbrev))
  } else if (is.character(abbrev) && abbrev %in% teams$abbrev) {
    teams$teamId[match(abbrev, teams$abbrev)]
  } else {
    stop("Abbreviation not found for this team ID")
  }
}


# -------------------------------------------------------------------------

slot_abbrev <- function(slot) {
  stopifnot(could_be_numeric(slot))
  factor(slot, levels = pos_ids$slot, labels = pos_ids$abbrev)
}

slot_unabbrev <- function(abbrev) {
  if (all(could_be_numeric(abbrev))) {
    return(as.integer(abbrev))
  } else if (is.character(abbrev) && abbrev %in% pos_ids$abbrev) {
    pos_ids$slot[match(abbrev, pos_ids$abbrev)]
  } else {
    stop("Abbreviation not found for this roster slot")
  }
}

# -------------------------------------------------------------------------

pos_abbrev <- function(pos) {
  pos_abbrev <- pos_ids$abbrev[!is.na(pos_ids$position)]
  stopifnot(could_be_numeric(pos))
  factor(pos, levels = pos_ids$position, labels = pos_abbrev)
}

pos_unabbrev <- function(abbrev) {
  if (all(could_be_numeric(abbrev))) {
    return(as.integer(abbrev))
  } else if (is.character(abbrev) && abbrev %in% pos_ids$abbrev) {
    pos_ids$position[match(abbrev, pos_ids$abbrev)]
  } else {
    stop("Abbreviation not found for position")
  }
}

# -------------------------------------------------------------------------

pro_abbrev <- function(proTeamId) {
  fflr::nfl_teams$abbrev[match(proTeamId, fflr::nfl_teams$proTeamId)]
}

pro_unabbrev <- function(abbrev) {
  if (all(could_be_numeric(abbrev))) {
    return(as.integer(abbrev))
  } else if (is.character(abbrev) && abbrev %in% fflr::nfl_teams$abbrev) {
    fflr::nfl_teams$proTeamId[match(abbrev, fflr::nfl_teams$abbrev)]
  } else {
    stop("Abbreviation not found for professional team")
  }
}

# -------------------------------------------------------------------------

stat_abbrev <- function(statId) {
  stat_abbrev <- stat_ids$statAbbrev[!is.na(stat_ids$statAbbrev)]
  stopifnot(could_be_numeric(statId))
  stat_ids$statAbbrev[match(statId, stat_ids$statId)]
}

stat_unabbrev <- function(abbrev) {
  if (all(could_be_numeric(abbrev))) {
    return(as.integer(abbrev))
  } else if (is.character(abbrev) && abbrev %in% stat_ids$statAbbrev) {
    stat_ids$statId[match(abbrev, stat_ids$statAbbrev)]
  } else {
    stop("Abbreviation not found for position")
  }
}
