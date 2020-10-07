#' Stat corrections
#'
#' Weekly retroactive stat corrections by player.
#'
#' @param date A date in the scoring week to return. Defaults to system date.
#' @return A tibble of player corrections.
#' @examples
#' stat_correct()
#' @importFrom tibble as_tibble tibble
#' @importFrom jsonlite fromJSON
#' @export
stat_correct <- function(date = Sys.Date()) {
  if (!inherits(date, c("Date", "character"))) {
    stop("date must be date class or coercible character")
  }
  d <- fromJSON(
    txt = paste0(
      "https://sports.core.api.espn.com/",
      "v2/sports/football/leagues/nfl/seasons/2020/corrections",
      "?limit=100&date=", format(as.Date(date), "%Y%m%d")
    )
  )
  x <- d$items$splitStats$categories
  if (is.null(x)) {
    warning("no stat corrections for this week (yet)")
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
  player_id <- as.integer(sub(".*/(\\d+)\\?.*", "\\1", d$items$athlete[[1]]))
  out <- rep(list(NA), length(x))
  for (i in seq_along(x)) {
    for (k in seq_along(x[[i]]$stats)) {
      x[[i]]$stats[[k]]$type <- x[[i]]$abbreviation[k]
      x[[i]]$stats[[k]]$id <- player_id[i]
    }
    out[[i]] <- x[[i]]$stats
  }
  out <- tibble::as_tibble(do.call("rbind", do.call("rbind", out)))
  out$type <- toupper(out$type)
  out$date <- as.Date(date)
  out <- out[order(out$id), c(10, 9, 8, 5, 1, 6)]
  names(out)[4:6] <- c("stat", "name", "change")
  return(out)
}
