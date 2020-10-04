#' 2020 NFL Players
#'
#' All available ESPN fantasy football players as of the 2020 season, week 4.
#'
#' @format A data frame with 1,059 rows and 5 variables:
#' \describe{
#'   \item{id}{Unique ESPN player ID}
#'   \item{first}{First name}
#'   \item{last}{Last name}
#'   \item{pro}{Professional NFL team}
#'   \item{pos}{Position: QB, RB, WR, TE, D/ST}
#'   ...
#' }
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2020/segments/0/leagues/252353?view=kona_player_info}
"nfl_players"

#' 2020 NFL Schedule
#'
#' The initial 2020 NFL season schedule by team.
#'
#' @format A data frame with 1,059 rows and 5 variables:
#' \describe{
#'   \item{year}{Season year}
#'   \item{week}{Matchup period}
#'   \item{pro}{Team abbreviation}
#'   \item{opp}{Team opponent}
#'   \item{home}{Team the home?}
#'   \item{kickoff}{Match date and time}
#'   ...
#' }
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2020/segments/0/leagues/252353?view=kona_player_info}
"nfl_schedule"

#' 2020 NFL Teams
#'
#' The 32 professional NFL teams as of the 2020 season.
#'
#' @format A data frame with 1,056 rows and 5 variables:
#' \describe{
#'   \item{team}{Unique team ID}
#'   \item{abbrev}{Team abbreviation}
#'   \item{location}{Team geographic location}
#'   \item{name}{Team full nickname}
#'   \item{bye}{Bye week, no game played}
#'   \item{conf}{NFL confrence}
#'   ...
#' }
"nfl_teams"

#' 2015-2020 GAA Teams
#'
#' The GAA is the fantasy league of this package's author.
#'
#' @format A data frame with 13 rows and 3 variables:
#' \describe{
#'   \item{team}{Unique yearly team ID}
#'   \item{abbrev}{Team abbreviation}
#'   \item{years}{Nested list of active years}
#'   ...
#' }
"gaa_teams"
