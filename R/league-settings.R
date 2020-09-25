#' League information
#'
#' @inheritParams draft_picks
#' @return A list or tibble of season settings.
#' @examples
#' league_info(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
league_info <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  x <- list(
    year = d$seasonId,
    name = unique(d$settings$name),
    id = unique(d$id),
    public = d$settings$isPublic,
    size = d$settings$size,
    length = d$status$finalScoringPeriod
  )
  if (old) {
    tibble::as_tibble(x)
  } else {
    return(x)
  }
}

#' League team size
#'
#' @inheritParams draft_picks
#' @return A named integer vector.
#' @examples
#' league_size(252353, old = TRUE)
#' @export
league_size <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  x <- d$settings$size
  names(x) <- d$seasonId
  return(x)
}

#' League name
#'
#' @inheritParams draft_picks
#' @return A character vector.
#' @examples
#' league_name(252353)
#' @export
league_name <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, ...)
  unique(d$settings$name)
}

#' League draft settings
#'
#' @inheritParams draft_picks
#' @return A list or tibble of season settings.
#' @examples
#' draft_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
draft_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$draftSettings[c(12, 1:2, 4:5, 10:11)]
  names(s) <- c("type", "budget", "date", "trading", "keepers", "order", "time")
  s$date <- ffl_date(s$date)
  s$budget[s$type == "SNAKE"] <- NA_character_
  if (old) {
    tibble::as_tibble(s)
  } else {
    return(s)
  }
}
