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
