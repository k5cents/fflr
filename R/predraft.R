is_predraft <- function(dat) {
  if ("draftDetail" %in% names(dat)) {
    if (!dat$draftDetail$drafted) {
      message("League has not yet drafted this season")
      return(TRUE)
    }
  }
  return(FALSE)
}

skip_predraft <- function(dat) {
  if (is_installed("testthat") & "draftDetail" %in% names(dat)) {
    if (!dat$draftDetail$drafted) {
      testthat::skip(message = "League has not drafted")
    }
  }
}
