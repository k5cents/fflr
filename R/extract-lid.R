#' Extract ESPN league ID.
#'
#' From any ESPN league page URL (e.g.,
#' https://fantasy.espn.com/football/team?leagueId=252353&teamId=6&seasonId=2019),
#' extract the league ID digits.
#'
#' @param url Any ESPN leuage page URL.
#' @return An ESPN league ID.
#' @examples
#' extract_lid("https://fantasy.espn.com/football/team?leagueId=252353&teamId=6&seasonId=2019")
#' @importFrom stringr str_extract
#' @export
extract_lid <- function(url) {
  stringr::str_extract(url, "(?<=leagueId=)\\d{6}")
}
