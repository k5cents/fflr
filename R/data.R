#' Fantasy Football Players
#'
#' All available ESPN fantasy football players week 3 of the 2020 season.
#'
#' @format A data frame with 1,056 rows and 5 variables:
#' \describe{
#'   \item{id}{Unique ESPN player ID}
#'   \item{first}{First name}
#'   \item{last}{Last name}
#'   \item{pro}{Professional NFL team}
#'   \item{pos}{Position: QB, RB, WR, TE, D/ST}
#'   ...
#' }
#' @source \url{https://fantasy.espn.com/apis/v3/games/ffl/seasons/2020/segments/0/leagues/252353?view=kona_player_info}
"players"

#' Team abbreviations in the NFL
#'
#' @format A data frame with 1,056 rows and 5 variables:
#' \describe{
#'   \item{team}{Unique yearly team ID}
#'   \item{abbrev}{Team abbreviation}
#'   ...
#' }
"nfl_teams"

#' Team abbreviations in the GAA
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
