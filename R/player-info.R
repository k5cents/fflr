#' Individual player information
#'
#' @param id A single player ID number.
#' @return A tibble of players.
#' @examples
#' str(player_info(15847))
#' @importFrom tibble as_tibble
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom httr GET add_headers accept_json content
#' @export
player_info <- function(id) {
  if (as.numeric(id) < 0) {
    stop("no information available for defenses")
  }
  d <- jsonlite::fromJSON(
    txt = paste0(
      "http://sports.core.api.espn.com/",
      "v2/sports/football/leagues/nfl/seasons/2020/athletes/", id
    )
  )
  out <- list(
    id = id,
    first = d$firstName,
    last = d$lastName,
    pos = d$position$abbreviation,
    jersey = d$jersey,
    weight = d$weight,
    height = d$height,
    age = d$age,
    birth_date = d$dateOfBirth,
    birth_place = paste(
      d$birthPlace$city,
      d$birthPlace$state,
      sep = ", "
    ),
    debut = d$debutYear,
    draft = d$draft$selection
  )
  return(out)
}
