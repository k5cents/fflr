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
#'   \item{jersey}{Jersey number}
#'   \item{weight}{Weight in even pounds}
#'   \item{height}{Weight in even inches}
#'   \item{age}{Current age in year}
#'   \item{birth}{Date of birth}
#'   \item{debut}{Season debuted in league}
#'   ...
#' }
#' @source \url{http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2020/athletes/}
"nfl_players"

#' 2020 NFL Schedule
#'
#' The 2020 NFL season schedule by team, as of October 5th. Due to COVID-19 game
#' delays, the schedule is more in flux than usual. See [pro_schedule()] for the
#' most current version.
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
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2020?view=proTeamSchedules_wl}
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
#'   \item{conf}{NFL conference}
#'   ...
#' }
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2020?view=proTeamSchedules_wl}
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
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2020/segments/0/leagues/252353}
"gaa_teams"
