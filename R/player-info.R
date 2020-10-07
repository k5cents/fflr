#' Individual player information
#'
#' @param id A single player ID number.
#' @param row Should list be converted to a single row data frame?
#' @return A tibble of players.
#' @examples
#' str(player_info(15847))
#' @importFrom tibble as_tibble
#' @importFrom jsonlite fromJSON
#' @export
player_info <- function(id, row = FALSE) {
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
  out <- out[!sapply(out, is.null)]
  out <- out[sapply(out, function(x) length(x) > 0)]
  if ("birth_date" %in% names(out)) {
    out$birth_date <- as.Date(out$birth_date)
  }
  if (row) {
    out <- tibble::as_tibble(out)
  }
  return(out)
}
