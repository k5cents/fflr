#' Roster moves
#'
#' The individual proposed and executed transactions, trades, and waiver moves.
#'
#' @inheritParams ffl_api
#' @return A data frame of transactions and roster moves.
#' @examples
#' roster_moves(leagueId = "42654852")
#' @export
roster_moves <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    view = "mTransactions2",
    ...
  )
  if (leagueHistory) {
    stop("not currently supported for past seasons")
  } else {
    t <- as_tibble(dat$transactions)
    for (i in seq_along(t$items)) {
      if (!is.null(t$items[[i]])) {
        if (is.matrix(t$items[[i]])) {

        }
        t$items[[i]] <- cbind(id = t$id[i], t$items[[i]])
      }
    }
    i <- do.call("rbind", t$items)[, -c(4, 5)]
    i$fromLineupSlotId[i$fromLineupSlotId == -1L] <- NA_integer_
    i$fromLineupSlotId <- slot_abbrev(i$fromLineupSlotId)
    i$toLineupSlotId <- slot_abbrev(i$toLineupSlotId)
    i$fromTeamId[i$fromTeamId == 0] <- NA_integer_
    i$toLineupSlotId[i$toLineupSlotId == -1L] <- NA_integer_
    i$toLineupSlotId[i$toLineupSlotId == 0] <- NA_integer_

    t$seaonId <- dat$seasonId
    t$bidAmount[t$bidAmount == 0] <- NA_integer_
    t$proposedDate = ffl_date(t$proposedDate)
    t <- t[, c(16, 10, 1, 11, 8, 12, 3)]

    t <- merge(t, i, by = "id")
    t$id <- substr(t$id, start = 1, stop = 8)
    as_tibble(t)
  }
}
