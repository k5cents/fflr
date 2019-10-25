#' The ESPN pro team IDs and their NFL abbreviations
#'
#' @format A data frame with 32 rows and 2 variables:
#' \describe{
#'   \item{team}{The ESPN team ID}
#'   \item{pro}{The NFL team abbreviation}
#'   ...
#' }
"pro_teams"

#' A team roster for week 3 of the 2019 season
#'
#' @format A tibble with 16 rows and 15 variables:
#' \describe{
#'   \item{year}{Season ID}
#'   \item{week}{Scoring period ID}
#'   \item{owner}{Current fantasy team owner abbreviation}
#'   \item{slot}{Lineup slot ID}
#'   \item{first}{Player first name}
#'   \item{last}{Player last name}
#'   \item{team}{Professional NFL team}
#'   \item{jersey}{Professional jersey number}
#'   \item{pos}{Default position ID}
#'   \item{status}{Injury status: "Active", "Questionable", "Doubtful", or "Out"}
#'   \item{proj}{Projected score}
#'   \item{score}{Actual score}
#'   \item{start}{Percent of teams started on}
#'   \item{rost}{Percent of leagues owned in}
#'   \item{change}{Change in ownership since last scoring period}
#'   ...
#' }
"roster"
