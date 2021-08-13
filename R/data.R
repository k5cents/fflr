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
