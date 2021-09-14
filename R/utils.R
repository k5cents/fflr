ffl_date <- function(date) {
  if (is.null(date)) {
    as.POSIXct(NA_real_)
  } else {
    as.POSIXct(date/1000, origin = "1970-01-01")
  }
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

pos_abbrev <- function(pos) {
  factor(
    x = pos,
    levels = c("1",  "2",  "3",  "4",  "5",  "9",  "16"),
    labels = c("QB", "RB", "WR", "TE", "PK", "DT", "DS")
  )
}

pro_abbrev <- function(proTeamId) {
  fflr::nfl_teams$abbrev[match(proTeamId, fflr::nfl_teams$team)]
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
