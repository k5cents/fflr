#' fflr: A package for collecting ESPN fantasy football data
#'
#' The fflr package parses the JSON data returned by the ESPN v3 API into tidy
#' data frames for easy analysis. The package also includes data objects for the
#' NFL with players, teams, and the 2021 schedule. The league must first be made
#' viewable to the public by the league manager, which can be done on the basic
#' settings page on the ESPN website. Functions can then take the numeric league
#' ID found in the URL to return data from the API. This league ID can be set as
#' a global option named "fflr.leagueId" with `options()`.
#'
#' @docType package
#' @name fflr
NULL
#> NULL
