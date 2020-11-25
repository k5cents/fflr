#' Roster moves
#'
#' The individual proposed and executed transactions, trades, and waiver moves.
#'
#' @inheritParams draft_picks
#' @return A tibble of transactions and roster moves.
#' @examples
#' roster_moves(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
roster_moves <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = "mTransactions2", ...)
  if (old) {
    stop("not currently supported for past seasons")
  } else {
    parse_moves(data$transactions, y = data$seasonId)
  }
}

ffl_date <- function(date) {
  as.POSIXct(date/1000, origin = "1970-01-01")
}

parse_moves <- function(t, y = NULL) {
  for (i in seq_along(t$items)) {
    if (!is.null(t$items[[i]])) {
      t$items[[i]] <- cbind(tx = t$id[i], t$items[[i]])
    }
  }
  i <- do.call("rbind", t$items)[, c(-4, -5)]
  i_nm <- c("from_slot", "from_team", "id", "to_slot", "to_team", "move")
  names(i)[2:7] <- i_nm
  i$from_slot[i$from_slot == -1L] <- NA_integer_
  i$from_slot <- slot_abbrev(i$from_slot)
  i$to_slot <- slot_abbrev(i$to_slot)
  i$from_team[i$from_team == 0] <- NA_integer_
  i$to_slot[i$to_slot == -1L] <- NA_integer_
  i$to_team[i$to_team == 0] <- NA_integer_
  t <- data.frame(
    stringsAsFactors = FALSE,
    week = t$scoringPeriodId,
    type = t$type,
    bid = t$bidAmount,
    status = t$status,
    date = ffl_date(t$proposedDate),
    team = t$teamId,
    tx = t$id
  )
  t$bid[t$bid == 0] <- NA_integer_
  t$status[grep("^FAILED", t$status)] <- "FAILED"
  t <- cbind(year = y, t)
  x <- merge(t, i, by = "tx")
  x$tx <- substr(x$tx, start = 1, stop = 8)
  return(tibble::as_tibble(x))
}
