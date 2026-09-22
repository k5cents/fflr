#' Player outlooks
#'
#' All available weekly ESPN outlook writeups for NFL players.
#'
#' @inheritParams ffl_id
#' @param limit The limit of players to return. Use `""` or `NULL` to return
#'   all. Defaults to 50, which is the default limit used by ESPN. Removing the
#'   limit can make the request take a long time.
#' @return A data frame of player outlooks by scoring period.
#' @examples
#' player_outlook()
#' @importFrom tibble tibble
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom httr RETRY add_headers accept_json content
#' @family player functions
#' @export
player_outlook <- function(leagueId = ffl_id(), limit = 50) {
  if (is.null(leagueId)) leagueId <- "42654852"
  if (is.null(limit)) limit <- ""
  all_get <- httr::RETRY(
    verb = "GET",
    url = paste0(
      "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2026/segments/0/leagues/",
      leagueId
    ),
    query = list(view = "kona_player_info"),
    httr::accept_json(),
    httr::add_headers(
      `X-Fantasy-Filter` = jsonlite::toJSON(
        x = list(
          players = list(
            limit = limit,
            sortPercOwned = list(
              sortAsc = FALSE,
              sortPriority = 1
            )
          )
        ),
        auto_unbox = TRUE
      )
    )
  )
  pl <- jsonlite::fromJSON(httr::content(all_get, as = "text"))
  pl <- pl$players

  y <- max(pl$player$stats[[1]]$seasonId)
  w <- length(pl$player$outlooks$outlooksByWeek)
  if (!is.null(pl$player$outlooks)) {
    x <- pl$player$outlooks$outlooksByWeek
    # columns are named by the week they describe, which can skip weeks
    weeks <- c(0L, as.integer(names(x)))
    season <- pl$player$seasonOutlook
    if (is.null(season)) {
      season <- NA_character_
    }
    x <- cbind(season, as.matrix(x))
    outlooks <- as.vector(t(x))
    out <- tibble::tibble(
      seasonId = y,
      scoringPeriodId = rep(weeks, times = nrow(x)),
      id = rep(pl$player$id, each = w + 1),
      firstName = rep(pl$player$firstName, each = w + 1),
      lastName = rep(pl$player$lastName, each = w + 1),
      outlook = outlooks
    )
    out[!is.na(out$outlook), ]
  } else {
    tibble::tibble(
      seasonId = y,
      id = rep(pl$player$id, each = w + 1),
      firstName = rep(pl$player$firstName, each = w + 1),
      lastName = rep(pl$player$lastName, each = w + 1),
      outlook = NA_character_
    )
  }
}
