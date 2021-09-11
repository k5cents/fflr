#' 2021 NFL Players
#'
#' All available ESPN fantasy football players as of the 2021 season, week 1.
#'
#' @format A data frame with 1,063 rows and 11 variables:
#' \describe{
#'   \item{id}{Unique ESPN player ID}
#'   \item{firstName}{First name}
#'   \item{lastName}{Last name}
#'   \item{proTeam}{Professional NFL team}
#'   \item{defaultPositionId}{Position: QB, RB, WR, TE, D/ST}
#'   \item{jersey}{Jersey number}
#'   \item{weight}{Weight in integer pounds}
#'   \item{height}{Height in integer inches}
#'   \item{age}{Current age in integer year}
#'   \item{dateOfBirth}{Date of birth}
#'   \item{debutYear}{Season debuted in league}
#'   ...
#' }
#' @source \url{http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2021/athletes/}
"nfl_players"

#' 2021 NFL Teams
#'
#' The 32 professional NFL teams as of the 2021 season.
#'
#' @format A data frame with 33 rows and 6 columns:
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
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2021/segments/0/leagues/252353}
"gaa_teams"
