#' 2023 NFL Players
#'
#' All available ESPN fantasy football players as of the 2023 season, week 1.
#'
#' @format A data frame with 1,102 rows and 11 variables:
#' \describe{
#'   \item{playerId}{Unique ESPN player ID}
#'   \item{firstName}{First name}
#'   \item{lastName}{Last name}
#'   \item{proTeam}{Professional NFL team}
#'   \item{defaultPosition}{Position: QB, RB, WR, TE, D/ST}
#'   \item{jersey}{Jersey number}
#'   \item{weight}{Weight in integer pounds}
#'   \item{height}{Height in integer inches}
#'   \item{age}{Current age in integer year}
#'   \item{dateOfBirth}{Date of birth}
#'   \item{birthPlace}{Place of birth}
#'   \item{debutYear}{Season debuted in league}
#'   \item{draftSelection}{Overall pick number in the NFL draft}
#'   ...
#' }
#' @source \url{http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2023/athletes/}
"nfl_players"

#' 2023 NFL Teams
#'
#' The 32 professional NFL teams as of the 2023 season.
#'
#' @format A data frame with 33 rows and 6 columns:
#' \describe{
#'   \item{proTeamId}{Unique team ID}
#'   \item{abbrev}{Professional team abbreviation}
#'   \item{location}{Professional team geographic location}
#'   \item{name}{Professional team full nickname}
#'   \item{byeWeek}{Bye week, no game played}
#'   \item{conference}{NFL conference}
#'   ...
#' }
#' @source \url{https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2023?view=proTeamSchedules_wl}
"nfl_teams"

#' 2023 NFL Schedule
#'
#' The 2023 NFL season schedule by team, as of September 10th.
#'
#' @format A data frame with 544 rows and 6 variables:
#' \describe{
#'   \item{seasonId}{Season year}
#'   \item{scoringPeriodId}{Scoring period}
#'   \item{matchupId}{Unique ID for professional matchup}
#'   \item{proTeam}{Professional team abbreviation}
#'   \item{opponent}{Professional team opponent}
#'   \item{isHome}{Whether this is the home team}
#'   \item{date}{Matchup start date and time}
#'   ...
#' }
#' @source \url{https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2023?view=proTeamSchedules_wl}
"nfl_schedule"
