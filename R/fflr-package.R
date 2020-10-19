#' fflr: A package for collecting ESPN fantasy football data
#'
#' The fflr package parses the JSON data returned by the ESPN v3 API into tidy
#' dataframes for easy analysis. The package also includes data objects for the
#' NFL with players, teams, and the 2020 schedule. The league first be made
#' viewable to the public by the league manager, which can be done on the basic
#' settings page on the ESPN website. Functions can then take the numeric league
#' ID found in the URL to return data from the API. This league ID can be set
#' as a global option named "lid" with `options()`.
#'
#' @docType package
#' @name fflr
NULL
#> NULL
