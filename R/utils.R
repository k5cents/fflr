ffl_date <- function(date) {
  as.POSIXct(date/1000, origin = "1970-01-01")
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
