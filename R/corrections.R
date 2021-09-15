#' Stat corrections
#'
#' Weekly retroactive stat corrections by player.
#'
#' @param date A date in the scoring week to return. Defaults to system date.
#' @param limit The limit of corrections to return. Use `""` or `NULL` to return
#'   all. Defaults to 100, which is the default limit used by ESPN. Removing the
#'   limit can make the request take a long time.
#' @return A data frame of stat corrections.
#' @examples
#' stat_correct()
#' @importFrom tibble as_tibble tibble
#' @export
stat_correct <- function(date = Sys.Date(), limit = 100) {
  if (!inherits(date, "Date")) {
    date <- tryCatch(expr = as.Date(date), error = function(e) date)
    if (!inherits(date, "Date")) {
      stop(paste(date, "is not a date object"))
    }
  }
  dat <- try_json(
    url = "https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2021/corrections",
    query = list(
      limit = limit,
      date = format(as.Date(date), "%Y%m%d")
    )
  )
  x <- dat$items$splitStats$categories
  if (is.null(x)) {
    warning("No stat corrections for this week (yet)")
    return(
      tibble::tibble(
        date = as.Date(date),
        id = integer(),
        type = character(),
        stat = character(),
        name = character(),
        change = double()
      )
    )
  }
  player_id <- as.integer(sub(".*/(\\d+)\\?.*", "\\1", dat$items$athlete[[1]]))
  out <- rep(list(NA), length(x))
  for (i in seq_along(x)) {
    for (k in seq_along(x[[i]]$stats)) {
      x[[i]]$stats[[k]] <- cbind(playerId = player_id, x[[i]]$stats[[k]])
    }
    out[[i]] <- x[[i]]$stats
  }
  out <- cbind(date, do.call("rbind", do.call("rbind", out)))
  as_tibble(out[order(out$playerId), c(1:2, 7, 3, 8)])
}
