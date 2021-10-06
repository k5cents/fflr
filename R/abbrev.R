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
  stopifnot(is.numeric(slot))
  factor(slot, levels = pos_ids$slot, labels = pos_ids$abbrev)
}

slot_unabbrev <- function(abbrev) {
  stopifnot(is.character(abbrev))
  pos_ids$slot[match(abbrev, pos_ids$abbrev)]
}

pos_abbrev <- function(pos) {
  pos_abbrev <- pos_ids$abbrev[!is.na(pos_ids$position)]
  stopifnot(is.numeric(pos))
  factor(pos, levels = pos_ids$position, labels = pos_abbrev)
}

pos_unabbrev <- function(abbrev) {
  stopifnot(is.character(abbrev))
  pos_ids$position[match(abbrev, pos_ids$abbrev)]
}

pro_abbrev <- function(proTeamId) {
  fflr::nfl_teams$abbrev[match(proTeamId, fflr::nfl_teams$proTeamId)]
}

#' Convert team ID to abbreviation
#'
#' @param id A integer vector of team numbers to convert.
#' @param teams A table of teams from [league_teams()].
#' @return A factor vector of team abbreviations.
#' @examples
#' team_abbrev(id = 2, teams = league_teams(leagueId = "42654852"))
#' @export
team_abbrev <- function(teamId, teams = league_teams(leagueId = ffl_id())) {
  if (!(all(c("abbrev", "teamId") %in% names(team)))) {
    stop("team data lacks `abbrev` and `teamId` columns")
  }
  stopifnot(is.data.frame(teams))
  teams$abbrev[match(teamId, teams$teamId)]
}
