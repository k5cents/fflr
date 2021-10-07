# position                    abbrev  slot  pos
# Quarterback                 QB      0     1
# Team Quarterback            TQB     1
# Running Back                RB      2     2
# Running Back/Wide Receiver  RB/WR   3
# Wide Receiver               WR      4     3
# Wide Receiver/Tight End     WR/TE   5
# Tight End                   TE      6     4
# Flex                        FLEX    23
# Offensive Player Utility    OP      7
# Defensive Tackle            DT      8     9
# Defensive End               DE      9     10
# Linebacker                  LB      10    11
# Defensive Line              DL      11
# Cornerback                  CB      12    12
# Safety                      S       13    13
# Defensive Back              DB      14
# Defensive Player Utility    DP      15
# Team Defense/Special Teams  D/ST    16    16
# Place Kicker                K       17    5
# Punter                      P       18    7
# Head Coach                  HC      19    14
# Bench                       BE      20
# Injured Reserve             IR      21

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
