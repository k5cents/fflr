ffl_date <- function(date) {
  if (is.null(date)) {
    as.POSIXct(NA_real_)
  } else {
    as.POSIXct(date/1000, origin = "1970-01-01")
  }
}

ffl_timestamp <- function(x) {
  as.POSIXlt(x, tz = "UTC", format = "%Y-%m-%dT%H:%M:%S")
}

as_tibble <- function(x) {
  if (is_installed("tibble")) {
    tibble::as_tibble(x)
  } else {
    x
  }
}

is_installed <- function(pkg) {
  isTRUE(requireNamespace(pkg, quietly = TRUE))
}

slot_abbrev <- function(slot) {
  factor(
    x = slot,
    levels = c("0",  "2",  "4",  "6",  "23", "16", "17", "20", "21"),
    labels = c("QB", "RB", "WR", "TE", "FX", "DS", "PK", "BE", "IR")
  )
}

slot_unabbrev <- function(abbrev) {
  slot_int <- c(0, 2, 4, 6, 23, 16, 17, 20, 21)
  slot_abb <- c("QB", "RB", "WR", "TE", "FX", "DS", "PK", "BE", "IR")
  slot_int[match(abbrev, slot_abb)]
}

pos_abbrev <- function(pos) {
  factor(
    x = pos,
    levels = c("1",  "2",  "3",  "4",  "5",  "9",  "16"),
    labels = c("QB", "RB", "WR", "TE", "PK", "DT", "DS")
  )
}

pos_unabbrev <- function(abbrev) {
  pos_int <- c(1, 2, 3, 4, 5, 9, 16)
  pos_abb <- c("QB", "RB", "WR", "TE", "PK", "DT", "DS")
  pos_int[match(abbrev, pos_abb)]
}

pro_abbrev <- function(proTeamId) {
  fflr::nfl_teams$abbrev[match(proTeamId, fflr::nfl_teams$proTeamId)]
}

list_ifnot <- function(x) {
  if (!is.list(x)) {
    list(x)
  } else if (is.data.frame(x)) {
    list(x)
  } else {
    x
  }
}

ffl_merge <- function(x, y, ...) {
  out <- merge(x, y, sort = FALSE, ...)[, union(names(x), names(y))]
  as_tibble(out)
}

stop_predraft <- function(dat) {
  if ("draftDetail" %in% names(dat)) {
    if (!dat$draftDetail$drafted) {
      message("This league has not drafted and the information is unavailable")
      return(data.frame())
    }
  }
}

skip_predraft <- function(dat) {
  if (is_installed("testthat") & "draftDetail" %in% names(dat)) {
    if (!dat$draftDetail$drafted) {
      testthat::skip(message = "This league has not drafted")
    }
  }
}

order_df <- function(dat, col, decreasing = TRUE) {
  if (is.data.frame(dat) & is.vector(col)) {
    dat[order(col, decreasing = decreasing), ]
  }
}

bind_df <- function(l, .id = NULL) {
  if (!is.null(.id) & !is.null(names(l))) {
    l <- lapply(
      X = seq_along(l),
      FUN = function(i) {
        sid <- list(names(l)[i])
        names(sid) <- .id
        cbind(sid, l[[i]])
      }
    )
  }
  out <- do.call(what = "rbind", args = l)
  as_tibble(out)
}
